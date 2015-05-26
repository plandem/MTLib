//
// Created by Andrey on 26/05/15.
// Copyright (c) 2015 Melatonin LLC. All rights reserved.
//

#import "MTCoreDataContextWatcher.h"
#import "MTLogger.h"

@interface MTCoreDataContextWatcher ()
@property (nonatomic, strong) NSPredicate *conditionToWatch;
@property (nonatomic, strong) NSManagedObjectContext *contextToWatch;
@property (nonatomic, strong) NSPersistentStoreCoordinator *persistentStoreCoordinatorToWatch;
@end

@implementation MTCoreDataContextWatcher

- (id) initWithManagedObjectContext:(NSManagedObjectContext *)contextToWatch {
	self = [super init];
	if (self) {
		self.contextToWatch = contextToWatch;
		[self setup];
	}

	return self;
}

- (id) initWithPersistentStoreCoordinator:(NSPersistentStoreCoordinator *)coordinatorToWatch {
	self = [super init];
	if (self) {
		self.persistentStoreCoordinatorToWatch = coordinatorToWatch;
		[self setup];
	}

	return self;
}

- (void) setup {
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(contextUpdated:) name:NSManagedObjectContextDidSaveNotification object:nil];
}

- (void) dealloc {
	[[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void) addEntityToWatch:(id)entity {
	[self addEntityToWatch:entity withPredicate:nil];
}

- (void) addEntityToWatch:(id)entity withPredicate:(NSPredicate *)predicate; {
	NSEntityDescription *description;

	if([entity isKindOfClass:[NSString class]]) {
		if(self.contextToWatch) {
			description = [NSEntityDescription entityForName:entity inManagedObjectContext:self.contextToWatch];
		} else if(self.persistentStoreCoordinatorToWatch) {
			NSManagedObjectModel *model = [self.persistentStoreCoordinatorToWatch managedObjectModel];
			description = [[model entitiesByName] objectForKey:entity];
		} else {
			DDLogDebug(@"Can't get NSEntityDescription via NSString, because watcher was initialized without NSPersistentStoreCoordinator or NSManagedObjectContext");
			exit(-1);
		}
	} else if([entity isMemberOfClass:[NSEntityDescription class]]) {
		description = entity;
	} else {
		DDLogDebug(@"Only NSString and NSEntityDescription are allowed as entity parameter");
		exit(-1);
	}

	if(description == nil) {
		DDLogDebug(@"Failed to resolve Entity=%@", entity);
		exit(-1);
	}

	NSPredicate *new_predicate = [NSPredicate predicateWithFormat:@"entity.name == %@", [description name]];

	if(predicate)
		new_predicate = [NSCompoundPredicate andPredicateWithSubpredicates: @[new_predicate, predicate]];

	self.conditionToWatch = (self.conditionToWatch) ? [NSCompoundPredicate orPredicateWithSubpredicates:@[self.conditionToWatch, new_predicate]] : new_predicate;
}

//Fault in all updated objects
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

- (void) contextUpdated:(NSNotification *)notification {
	NSManagedObjectContext *incomingContext = [notification object];
	NSPersistentStoreCoordinator *incomingCoordinator = [incomingContext persistentStoreCoordinator];

	if ((self.contextToWatch && incomingContext != self.contextToWatch) || (self.persistentStoreCoordinatorToWatch && incomingCoordinator != self.persistentStoreCoordinatorToWatch))
		return;

	NSMutableSet *inserted = [[[notification userInfo] objectForKey:NSInsertedObjectsKey] mutableCopy];
	NSMutableSet *deleted = [[[notification userInfo] objectForKey:NSDeletedObjectsKey] mutableCopy];
	NSMutableSet *updated = [[[notification userInfo] objectForKey:NSUpdatedObjectsKey] mutableCopy];

	if (self.conditionToWatch) {
		[inserted filterUsingPredicate: self.conditionToWatch];
		[deleted filterUsingPredicate: self.conditionToWatch];
		[updated filterUsingPredicate: self.conditionToWatch];
	}

	NSInteger totalCount = [inserted count] + [deleted count]  + [updated count];

	if (totalCount < 1) {
		DDLogDebug(@"Unwatched content. %@", self.conditionToWatch);
		return;
	}

	NSMutableDictionary *results = [[NSMutableDictionary alloc] init];
	DDLogDebug(@"contextUpdated");

	//BUG FIX: When the notification is merged it only updates objects which are already registered in the context.
	void (^refreshUnsafe)(NSManagedObjectContext *context, NSSet *objects) = ^void(NSManagedObjectContext *context, NSSet *objects) {
//		for (NSManagedObject *unsafeManagedObject in objects) {
//			//Force the refresh of updated objects which may not have been registered in this context.
//			NSManagedObject *manangedObject = [context existingObjectWithID:unsafeManagedObject.objectID error:NULL];
//			if (manangedObject != nil)
//				[context refreshObject:manangedObject mergeChanges:YES];
//		}
	};

	if (inserted) {
		results[NSInsertedObjectsKey] = inserted;
//		[self faultObjects:[notification userInfo][NSDeletedObjectsKey] inContext:incomingContext];
//		[self refreshObjects:[notification userInfo][NSDeletedObjectsKey] inContext:incomingContext];
	}

	if (deleted) {
		results[NSDeletedObjectsKey] = deleted;
//		[self faultObjects:[notification userInfo][NSDeletedObjectsKey] inContext:incomingContext];
//		[self refreshObjects:[notification userInfo][NSDeletedObjectsKey] inContext:incomingContext];
	}

	if (updated) {
		results[NSUpdatedObjectsKey] = updated;
//		[self faultObjects:[notification userInfo][NSDeletedObjectsKey] inContext:incomingContext];
//		[self refreshObjects:[notification userInfo][NSDeletedObjectsKey] inContext:incomingContext];
	}

	if ([[self delegate] respondsToSelector:[self action]]) {
		[[self delegate] performSelectorOnMainThread:[self action] withObject:results waitUntilDone:YES];
	}
}

- (void)resetCondition {
	self.conditionToWatch = nil;
}
@end