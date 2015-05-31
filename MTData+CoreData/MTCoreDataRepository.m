//
// Created by Andrey on 28/05/15.
// Copyright (c) 2015 Andrey Gayvoronsky. All rights reserved.
//

#import <libextobjc/extobjc.h>
#import <NLCoreData/NLCoreData.h>
#import "MTCoreDataRepository.h"
#import "MTCoreDataFetchResult.h"
#import "MTCoreDataObject.h"
#import "MTDataSort.h"

@interface MTCoreDataRepository()
@property (nonatomic, strong) NSManagedObjectContext *context;
@end

@implementation MTCoreDataRepository
- (instancetype)initWithModelClass:(Class)modelClass withContext:(NSManagedObjectContext *)context {
	if((self = [self initWithModelClass:modelClass])) {
		_context = context;
	}

	return self;
}

-(id<MTDataObject>)createModel {
	return (id<MTDataObject>)[self.modelClass insertInContext:_context];
}

-(void)deleteModel:(id<MTDataObject>)model {
	[self ensureModelType:model];

	@weakify(self);
	[_context performBlock:^{
		@strongify(self);
		[self.context deleteObject:(NSManagedObject *)model];
		[self.context saveNested];
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

-(void)withTransaction:(MTDataRepositoryTransactionBlock)transaction {
	_context.undoEnabled = YES;
	NSAssert(_context.isUndoEnabled, @"Transaction is not supported.");
	@try {
		[_context.undoManager beginUndoGrouping];
		transaction(self);
		[_context.undoManager endUndoGrouping];
	} @catch(NSException *e) {
		[_context.undoManager endUndoGrouping];
		[_context.undoManager undo];
	}
}

-(void)deleteAllWithQuery:(MTDataQuery *)query {
	id<MTDataObjectCollection> models = [self fetchAllWithQuery:query];

	@weakify(self);
	[_context performBlock:^{
		@strongify(self);
		for(MTCoreDataObject *model in models) {
			[self.context deleteObject:model];
		}

		[self.context saveNested];
	}];
}
@end