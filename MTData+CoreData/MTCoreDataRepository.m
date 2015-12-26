//
// Created by Andrey on 28/05/15.
// Copyright (c) 2015 Andrey Gayvoronsky. All rights reserved.
//

#import <libextobjc/extobjc.h>
#import <NLCoreData/NLCoreData.h>
#import "MTCoreDataRepository.h"
#import "MTCoreDataFetchResult.h"
#import "MTCoreDataObject.h"
#import "MTLogger.h"

@interface MTCoreDataRepository()
@property (nonatomic, strong) NSManagedObjectContext *context;
@end

@implementation MTCoreDataRepository
-(instancetype)initWithModelClass:(Class)modelClass {
	return [self initWithModelClass:modelClass withContext:[NSManagedObjectContext mainContext]];
}

- (instancetype)initWithModelClass:(Class)modelClass withContext:(NSManagedObjectContext *)context {
	if((self = [super initWithModelClass:modelClass])) {
		_context = context;
	}

	return self;
}

-(id<MTDataObject>)createModel {
	return (id<MTDataObject>)[self.modelClass insertInContext:_context];
}

-(void)deleteModel:(id<MTDataObject>)model {
	NSAssert([self inTransaction], MTDataErrorNoActiveTransaction);
	[self ensureModelType:model];

	@weakify(self);
	[_context performBlockAndWait:^{
		@strongify(self);
		[self.context deleteObject:(NSManagedObject *)model];
	}];
}

-(id<MTDataObjectCollection>)fetchAllWithQuery:(MTDataQuery *)query {
	NSFetchRequest *fetchRequest = [NSFetchRequest fetchRequestWithEntity:self.modelClass context:_context];

	if(query.predicate) {
		[fetchRequest setPredicate:query.predicate];
	}

	if([query.sort.sorters count]) {
		[fetchRequest setSortDescriptors:query.sort.sorters];
	}

	[fetchRequest setFetchLimit:query.batchSize];

	return [[MTCoreDataFetchResult alloc] initWithFetchRequest:fetchRequest inContext:_context];
}

-(void)beginTransaction {
	if(![self inTransaction]) {
		_context.undoEnabled = YES;
		NSAssert(_context.isUndoEnabled, @"Transaction is not supported.");
		[_context.undoManager beginUndoGrouping];
	}
}

-(void)commitTransaction {
	NSAssert([self inTransaction], MTDataErrorNoActiveTransaction);

	[_context.undoManager endUndoGrouping];

	if(![_context saveNested]) {
		[_context.undoManager undo];
		DDLogError(@"Context was not saved due to errors.");
	}

	_context.undoEnabled = NO;
}

-(void)rollbackTransaction {
	NSAssert([self inTransaction], MTDataErrorNoActiveTransaction);

	[_context.undoManager endUndoGrouping];
	[_context.undoManager undo];
	_context.undoEnabled = NO;
}

-(BOOL)inTransaction {
	return _context.isUndoEnabled;
}

-(void)withTransaction:(MTDataRepositoryTransactionBlock)transaction {
	BOOL inTransaction = [self inTransaction];

	@try {
		if(!(inTransaction)) {
			[self beginTransaction];
		}

		[_context performBlockAndWait:^{
			transaction(self);
		}];

		if(!(inTransaction)) {
			[self commitTransaction];
		}
	} @catch(NSException *e) {
		DDLogError(@"%@", e.reason);
		if(!(inTransaction)) {
			[self rollbackTransaction];
		}
	}
}

-(void)deleteAllWithQuery:(MTDataQuery *)query {
	NSAssert([self inTransaction], MTDataErrorNoActiveTransaction);
	id<MTDataObjectCollection> models = [self fetchAllWithQuery:query];

	@weakify(self);
	[_context performBlockAndWait:^{
		@strongify(self);
		for(MTCoreDataObject *model in models) {
			[self.context deleteObject:model];
		}
	}];
}

-(void)undoModel:(id<MTDataObject>)model {
	NSAssert([self inTransaction], MTDataErrorNoActiveTransaction);
	[self ensureModelType:model];

	@weakify(self);
	[_context performBlockAndWait:^{
		@strongify(self);
		[self.context refreshObject:(id) model mergeChanges:NO];
	}];
}

-(void)saveModel:(id<MTDataObject>)model {
	//do nothing. in CoreData we can't save specific model - only context. For better code re-use, wrap required savings into the transaction!
}
@end