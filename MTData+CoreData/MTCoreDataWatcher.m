//
// Created by Andrey on 26/05/15.
// Copyright (c) 2015 Melatonin LLC. All rights reserved.
//

#import <objc/runtime.h>
#import "MTCoreDataWatcher.h"

@interface MTCoreDataWatcher ()
@property(nonatomic, strong) NSPredicate *predicateToWatch;
@property(nonatomic, strong) NSManagedObjectContext *contextToWatch;
@property(nonatomic, strong) NSPersistentStoreCoordinator *persistentStoreCoordinatorToWatch;
@end

@implementation MTCoreDataWatcher

- (id)initWithManagedObjectContext:(NSManagedObjectContext *)contextToWatch {
	if ((self = [super init])) {
		self.contextToWatch = contextToWatch;
		[self setup];
	}

	return self;
}

- (id)initWithPersistentStoreCoordinator:(NSPersistentStoreCoordinator *)coordinatorToWatch {
	if ((self = [super init])) {
		self.persistentStoreCoordinatorToWatch = coordinatorToWatch;
		[self setup];
	}

	return self;
}

- (void)setup {
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(contextDidUpdate:) name:NSManagedObjectContextDidSaveNotification object:nil];
}

- (void)dealloc {
	[[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)addEntityToWatch:(id)entity {
	[self addEntityToWatch:entity withPredicate:nil];
}

- (void)addEntityToWatch:(id)entity withPredicate:(NSPredicate *)predicate; {
	NSEntityDescription *description;

	if (class_isMetaClass(object_getClass(entity))) {
		entity = NSStringFromClass(entity);
	}

	if ([entity isKindOfClass:[NSString class]]) {
		if (_contextToWatch) {
			description = [NSEntityDescription entityForName:entity inManagedObjectContext:_contextToWatch];
		} else if (_persistentStoreCoordinatorToWatch) {
			NSManagedObjectModel *model = [_persistentStoreCoordinatorToWatch managedObjectModel];
			description = [model entitiesByName][entity];
		} else {
			NSAssert(false, @"Can't get NSEntityDescription via NSString, because watcher was initialized without NSPersistentStoreCoordinator or NSManagedObjectContext");
		}
	} else if ([entity isMemberOfClass:[NSEntityDescription class]]) {
		description = entity;
	} else {
		NSAssert(false, @"Only Class, NSString or NSEntityDescription are allowed as entity parameter.");
	}

	NSAssert(description != nil, @"Failed to resolve Entity=%@", entity);

	NSPredicate *newPredicate = [NSPredicate predicateWithFormat:@"entity.name == %@", [description name]];
	if (predicate) {
		newPredicate = [NSCompoundPredicate andPredicateWithSubpredicates:@[newPredicate, predicate]];
	}

	_predicateToWatch = (_predicateToWatch) ? [NSCompoundPredicate orPredicateWithSubpredicates:@[_predicateToWatch, newPredicate]] : newPredicate;
}

- (void)contextDidUpdate:(NSNotification *)notification {
	if(_changesCallback == nil) {
		return;
	}

	NSManagedObjectContext *incomingContext = [notification object];
	NSPersistentStoreCoordinator *incomingCoordinator = [incomingContext persistentStoreCoordinator];

	//skip any child context in case if we are watching for changes at store
	if(_persistentStoreCoordinatorToWatch && incomingContext.parentContext) {
		return;
	}

	// differ context / differ store?
	if ((_contextToWatch && incomingContext != _contextToWatch) || (_persistentStoreCoordinatorToWatch && incomingCoordinator != _persistentStoreCoordinatorToWatch)) {
		return;
	}

	// no any predicate to filter updated objects?
	if (_predicateToWatch == nil) {
		_changesCallback([notification userInfo], incomingContext);
		return;
	}

	NSMutableSet *inserted = [[notification userInfo][NSInsertedObjectsKey] mutableCopy];
	NSMutableSet *deleted = [[notification userInfo][NSDeletedObjectsKey] mutableCopy];
	NSMutableSet *updated = [[notification userInfo][NSUpdatedObjectsKey] mutableCopy];

	// filter updated objects with predicate
	// TODO: in case if we watch for advanced predicate (Entity + some properties) we can 'miss' some hits for updated objects, because of changes for 'watching' property.
	// E.g.: we watched for 'isActive = 1' and our model set isActive to 0, so this filter will fail. To handle this we must get set of updated properties at
	// NSManagedObjectContextWillSaveNotification notification via [context updatedObjects] and later here we must add additionally check for that properties.
	// N.B.: right now behaviour is almost same as at NSFetchedController and differ contexts - it has 'same' problems with objects outside context and faulted.

	[inserted filterUsingPredicate:_predicateToWatch];
	[deleted filterUsingPredicate:_predicateToWatch];
	[updated filterUsingPredicate:_predicateToWatch];

	// are there any watching objects?
	NSUInteger totalCount = [inserted count] + [deleted count] + [updated count];
	if (totalCount > 0) {
		NSMutableDictionary *results = [[NSMutableDictionary alloc] initWithCapacity:totalCount];

		if (inserted && [inserted count]) {
			results[NSInsertedObjectsKey] = inserted;
		}

		if (deleted && [deleted count]) {
			results[NSDeletedObjectsKey] = deleted;
		}

		if (updated && [updated count]) {
			results[NSUpdatedObjectsKey] = updated;
		}

		_changesCallback(results, incomingContext);
	}
}

- (void)reset {
	_predicateToWatch = nil;
}
@end