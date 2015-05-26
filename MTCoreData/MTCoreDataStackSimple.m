//
// Created by Andrey on 26/05/15.
// Copyright (c) 2015 Melatonin LLC. All rights reserved.
//

#import "MTLogger.h"
#import "MTCoreDataStackSimple.h"
/*
@implementation NSManagedObject (SimpleAddons)

+ (instancetype)createEntity {
	NSEntityDescription *entity = [NSEntityDescription entityForName:NSStringFromClass([self class]) inManagedObjectContext:[MTCoreDataStackSimple privateQueueContext]];
	return  [[[self class] alloc] initWithEntity:entity insertIntoManagedObjectContext:[MTCoreDataStackSimple privateQueueContext]];
}
@end
*/

@interface MTCoreDataStackSimple ()
@property (strong, nonatomic) NSManagedObjectContext *mainQueueContext;
@property (strong, nonatomic) NSManagedObjectContext *privateQueueContext;
@end

@implementation MTCoreDataStackSimple

+ (NSManagedObjectContext *)mainQueueContext {
    return [[self defaultStack] mainQueueContext];
}

+ (NSManagedObjectContext *)privateQueueContext {
    return [[self defaultStack] privateQueueContext];
}

+ (NSManagedObjectContext *)newMainQueueContext {
	return [[self defaultStack] newMainQueueContext];
}
- (id)init {
    self = [super init];

	if (self) {
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(contextDidSavePrivateQueueContext:)name:NSManagedObjectContextDidSaveNotification object:[self privateQueueContext]];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(contextDidSaveMainQueueContext:) name:NSManagedObjectContextDidSaveNotification object:[self mainQueueContext]];
    }

    return self;
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

// Fault in all updated objects
- (void)faultObjects:(NSSet *)objects inContext:(NSManagedObjectContext *)context{
	for (NSManagedObject *unsafeManagedObject in objects) {
		NSManagedObject *managedObject = [context objectWithID:[unsafeManagedObject objectID]];
		if (managedObject != nil)
			[[context objectWithID:[unsafeManagedObject objectID]] willAccessValueForKey:nil];
	}
}

// refresh in all updated objects
- (void)refreshObjects:(NSSet *)objects inContext:(NSManagedObjectContext *)context{
	for (NSManagedObject *unsafeManagedObject in objects) {
		NSManagedObject *managedObject = [context existingObjectWithID:unsafeManagedObject.objectID error:NULL];
		if (managedObject != nil)
			[context refreshObject:managedObject mergeChanges:NO];
	}
}

- (void)contextDidSavePrivateQueueContext:(NSNotification *)notification {
    @synchronized(self) {
        [self.mainQueueContext performBlock:^{
			DDLogDebug(@"contextDidSavePrivateQueueContext");
			//Fault in all updated objects
//			[self faultObjects:[notification userInfo][NSDeletedObjectsKey] inContext:self.mainQueueContext];
//			[self faultObjects:[notification userInfo][NSUpdatedObjectsKey] inContext:self.mainQueueContext];
//			for (NSManagedObject *object in [notification userInfo][NSUpdatedObjectsKey]) {
//				// The objects can't be a fault. -existingObjectWithID:error: is a
//				// nice easy way to achieve that in a single swoop.
//				[self.mainQueueContext existingObjectWithID:object.objectID error:NULL];
//			}
//			for (NSManagedObject *object in [notification userInfo][NSDeletedObjectsKey]) {
//				// The objects can't be a fault. -existingObjectWithID:error: is a
//				// nice easy way to achieve that in a single swoop.
//				[self.mainQueueContext existingObjectWithID:object.objectID error:NULL];
//			}
			//Merge changes
            [self.mainQueueContext mergeChangesFromContextDidSaveNotification:notification];
			//Refresh
//			[self refreshObjects:[notification userInfo][NSDeletedObjectsKey] inContext:self.mainQueueContext];
//			[self refreshObjects:[notification userInfo][NSUpdatedObjectsKey] inContext:self.mainQueueContext];
        }];
    }
}

- (void)contextDidSaveMainQueueContext:(NSNotification *)notification {
    @synchronized(self) {
        [self.privateQueueContext performBlock:^{
			DDLogDebug(@"contextDidSaveMainQueueContext");
			// Fault in all updated objects
//			[self faultObjects:[notification userInfo][NSDeletedObjectsKey] inContext:self.privateQueueContext];
//			[self faultObjects:[notification userInfo][NSUpdatedObjectsKey] inContext:self.privateQueueContext];
			for (NSManagedObject *object in [notification userInfo][NSUpdatedObjectsKey]) {
				// The objects can't be a fault. -existingObjectWithID:error: is a
				// nice easy way to achieve that in a single swoop.
				[self.mainQueueContext existingObjectWithID:object.objectID error:NULL];
			}
			for (NSManagedObject *object in [notification userInfo][NSDeletedObjectsKey]) {
				// The objects can't be a fault. -existingObjectWithID:error: is a
				// nice easy way to achieve that in a single swoop.
				[self.mainQueueContext existingObjectWithID:object.objectID error:NULL];
			}
			//Merge changes
            [self.privateQueueContext mergeChangesFromContextDidSaveNotification:notification];
			//Refresh
//			[self refreshObjects:[notification userInfo][NSDeletedObjectsKey] inContext:self.privateQueueContext];
//			[self refreshObjects:[notification userInfo][NSUpdatedObjectsKey] inContext:self.privateQueueContext];
        }];
    }
}

- (NSManagedObjectContext *)mainQueueContext {
    if (!_mainQueueContext) {
        _mainQueueContext = [[NSManagedObjectContext alloc] initWithConcurrencyType:NSMainQueueConcurrencyType];
        _mainQueueContext.persistentStoreCoordinator = self.persistentStoreCoordinator;
    }

    return _mainQueueContext;
}

- (NSManagedObjectContext *)newMainQueueContext {
	NSManagedObjectContext *context = [[NSManagedObjectContext alloc] initWithConcurrencyType:NSMainQueueConcurrencyType];
	context.parentContext = [self mainQueueContext];
	return context;
}

- (NSManagedObjectContext *)privateQueueContext {
    if (!_privateQueueContext) {
        _privateQueueContext = [[NSManagedObjectContext alloc] initWithConcurrencyType:NSPrivateQueueConcurrencyType];
        _privateQueueContext.persistentStoreCoordinator = self.persistentStoreCoordinator;
    }

    return _privateQueueContext;
}

@end
