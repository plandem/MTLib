//
// Created by Andrey on 04/06/15.
// Copyright (c) 2015 Melatonin LLC. All rights reserved.
//

#import "MTDataObject.h"

@class MTDataQuery;
@class FMDatabase;

@interface MTSQLiteDataFetchResult : NSObject <MTDataObjectCollection>
@property (readonly) NSUInteger count;

- (instancetype)initWithModelClass:(Class)modelClass withProperties:(NSArray *)properties forQuery:(MTDataQuery *)query withDB:(FMDatabase *)db;
- (id)objectAtIndex:(NSUInteger)index;
- (id)objectAtIndexedSubscript:(NSUInteger)index;
- (void)enumerateObjectsUsingBlock:(void (^)(id obj, NSUInteger index, BOOL *stop))block;
- (NSEnumerator *)objectEnumerator;
@end