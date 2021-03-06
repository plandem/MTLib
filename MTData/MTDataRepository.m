//
// Created by Andrey on 28/04/15.
// Copyright (c) 2015 Melatonin LLC. All rights reserved.
//

#import "MTDataRepository.h"
#import "MTLogger.h"

NSString *MTDataErrorNoActiveTransaction = @"There is no any active transaction.";

@implementation MTDataRepository

-(instancetype)initWithModelClass:(Class)modelClass {
	NSAssert([modelClass conformsToProtocol:@protocol(MTDataObject)], @"Class must conforms to protocol %@", NSStringFromProtocol(@protocol(MTDataObject)));

	if ((self = [self init])) {
		_modelClass = modelClass;
	}

	return self;
}

-(id<MTDataObject>)createModel {
	return (id <MTDataObject>)[[[self modelClass] alloc] init];
}

-(void)ensureModelType:(id<MTDataObject>)model {
	NSAssert([model isKindOfClass:self.modelClass], @"Model[%@] must be same class[%@] as model that was used to create DataRepository/DataProvider.", model.class, self.modelClass);
}

-(void)notImplemented:(SEL)method {
	NSAssert(false, @"There is no default implementation for %@", NSStringFromSelector(method));
}

-(void)beginTransaction {
	[self notImplemented:_cmd];
}

-(void)commitTransaction {
	[self notImplemented:_cmd];
}

-(void)rollbackTransaction {
	[self notImplemented:_cmd];
}

-(BOOL)inTransaction {
	[self notImplemented:_cmd];
	return NO;
}

-(void)withTransaction:(MTDataRepositoryTransactionBlock)transactionBlock {
	BOOL inTransaction = [self inTransaction];

	@try {
		if(!(inTransaction)) {
			[self beginTransaction];
		}

		transactionBlock(self);

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

-(void)saveModel:(id<MTDataObject>)model {
	[self notImplemented:_cmd];
}

-(void)deleteModel:(id<MTDataObject>)model {
	[self notImplemented:_cmd];
}

-(void)undoModel:(id<MTDataObject>)model {
	[self notImplemented:_cmd];
}

-(void)deleteAllWithQuery:(MTDataQuery *)query {
	[self notImplemented:_cmd];
}

-(void)deleteAll {
	[self deleteAllWithQuery:[(id<MTDataObject>)_modelClass query]];
}

-(NSUInteger)countAll {
	return [self countWithQuery:[(id<MTDataObject>)_modelClass query]];
}

-(NSUInteger)countWithQuery:(MTDataQuery *)query {
	return [[self fetchAllWithQuery:query] count];
}

-(id<MTDataObject>)fetchWithQuery:(MTDataQuery *)query {
	return [self fetchAllWithQuery:query][0];
}

-(id<MTDataObjectCollection>)fetchAllWithQuery:(MTDataQuery *)query {
	[self notImplemented:_cmd];
	return nil;
}
@end