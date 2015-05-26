//
// Created by Andrey on 26/05/15.
// Copyright (c) 2015 Melatonin LLC. All rights reserved.
//

#import <CoreData/CoreData.h>

@interface MTCoreDataContextWatcher : NSObject
@property (nonatomic, assign) id delegate;
@property (nonatomic, assign) SEL action;
@property (nonatomic, readonly, strong) NSPredicate *conditionToWatch;

- (id)initWithManagedObjectContext:(NSManagedObjectContext *)contextToWatch;
- (id)initWithPersistentStoreCoordinator:(NSPersistentStoreCoordinator *)coordinatorToWatch;
- (void)addEntityToWatch:(id)entity;
- (void)addEntityToWatch:(id)entity withPredicate:(NSPredicate *)predicate;
- (void)resetCondition;
@end