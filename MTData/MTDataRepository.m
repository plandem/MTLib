//
// Created by Andrey on 28/04/15.
// Copyright (c) 2015 Melatonin LLC. All rights reserved.
//

#import "MTDataRepository.h"

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

-(void)notImplemented:(SEL)method {
	NSAssert(false, @"There is no default implementation for %@", NSStringFromSelector(method));
}

-(void)withTransaction:(MTDataRepositoryTransactionBlock)transaction {
	[self notImplemented:_cmd];
}

-(void)saveModel:(id<MTDataObject>)model {
	[self notImplemented:_cmd];
}

-(void)deleteModel:(id<MTDataObject>)model {
	[self notImplemented:_cmd];
}

-(void)deleteAll {
	[self notImplemented:_cmd];
}

-(void)deleteAllWithQuery:(MTDataQuery *)query {
	[self notImplemented:_cmd];
}

-(NSUInteger)countAll {
	MTDataQuery *query = (MTDataQuery *)[[[[self class] queryClass] alloc] init];
	return [[self fetchAllWithQuery:query] count];
}

-(NSUInteger)countWithQuery:(MTDataQuery *)query {
	return [[self fetchAllWithQuery:query] count];
}

-(id<MTDataObject>)fetchWithQuery:(MTDataQuery *)query {
	id<MTDataObjectCollection> all = [self fetchAllWithQuery:query];
	return all[0];
}

-(id<MTDataObjectCollection>)fetchAllWithQuery:(MTDataQuery *)query {
	[self notImplemented:_cmd];
//	return nil;
}

+(Class)queryClass {
	return [MTDataQuery class];
}
@end