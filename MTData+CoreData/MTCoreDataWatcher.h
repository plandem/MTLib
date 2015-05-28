//
// Created by Andrey on 26/05/15.
// Copyright (c) 2015 Melatonin LLC. All rights reserved.
//

#import <CoreData/CoreData.h>

typedef void (^MTCoreDataContextWatcherChangesCallback)(NSDictionary *changes, NSManagedObjectContext *context);

@interface MTCoreDataWatcher : NSObject
@property (nonatomic, readonly) NSPredicate *predicateToWatch;
@property (nonatomic, copy) MTCoreDataContextWatcherChangesCallback changesCallback;

- (instancetype)initWithManagedObjectContext:(NSManagedObjectContext *)contextToWatch;
- (instancetype)initWithPersistentStoreCoordinator:(NSPersistentStoreCoordinator *)coordinatorToWatch;
- (void)addEntityToWatch:(id)entity;
- (void)addEntityToWatch:(id)entity withPredicate:(NSPredicate *)predicate;
- (void)reset;
@end