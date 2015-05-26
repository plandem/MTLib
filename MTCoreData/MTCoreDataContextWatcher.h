//
// Created by Andrey on 26/05/15.
// Copyright (c) 2015 Melatonin LLC. All rights reserved.
//

#import <CoreData/CoreData.h>

typedef void (^MTCoreDataContextWatcherChangesBlock)(NSMutableDictionary *changes, NSManagedObjectContext *context);

@interface MTCoreDataContextWatcher : NSObject
@property (nonatomic, readonly) NSPredicate *conditionToWatch;
@property (nonatomic, copy) MTCoreDataContextWatcherChangesBlock changesBlock;

- (instancetype)initWithManagedObjectContext:(NSManagedObjectContext *)contextToWatch;
- (instancetype)initWithPersistentStoreCoordinator:(NSPersistentStoreCoordinator *)coordinatorToWatch;
- (void)addEntityToWatch:(id)entity;
- (void)addEntityToWatch:(id)entity withPredicate:(NSPredicate *)predicate;
- (void)reset;
@end