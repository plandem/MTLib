//
// Created by Andrey on 28/05/15.
// Copyright (c) 2015 Melatonin LLC. All rights reserved.
//

#import "MTCoreDataProvider.h"

@interface MTCoreDataFetchResult : NSObject <MTDataProviderCollection>
@property (readonly) NSUInteger count;

- (instancetype)initWithFetchRequest:(NSFetchRequest *)fetchRequest inContext:(NSManagedObjectContext *)context;
- (id)objectAtIndex:(NSUInteger)index;
- (id)objectAtIndexedSubscript:(NSUInteger)index;
- (void)enumerateObjectsUsingBlock:(void (^)(id obj, NSUInteger index, BOOL *stop))block;
- (NSEnumerator *)objectEnumerator;
@end