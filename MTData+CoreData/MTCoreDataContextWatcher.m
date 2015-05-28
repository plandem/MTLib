//
// Created by Andrey on 26/05/15.
// Copyright (c) 2015 Melatonin LLC. All rights reserved.
//

#import <objc/runtime.h>
#import "MTCoreDataContextWatcher.h"
#import "MTLogger.h"

@interface MTCoreDataContextWatcher ()
@property(nonatomic, strong) NSPredicate *predicateToWatch;
@property(nonatomic, strong) NSManagedObjectContext *contextToWatch;
@property(nonatomic, strong) NSPersistentStoreCoordinator *persistentStoreCoordinatorToWatch;
@end

@implementation MTCoreDataContextWatcher

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
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(contextUpdated:) name:NSManagedObjectContextDidSaveNotification object:nil];
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

- (void)contextUpdated:(NSNotification *)notification {
	if(_changesCallback == nil) {
		return;
	}

	NSManagedObjectContext *incomingContext = [notification object];
	NSPersistentStoreCoordinator *incomingCoordinator = [incomingContext persistentStoreCoordinator];

	DDLogDebug(@"i/w context = %@/%@", incomingContext, _contextToWatch);
	// differ context or differ store?
	if ((_contextToWatch && incomingContext != _contextToWatch) || (_persistentStoreCoordinatorToWatch && incomingCoordinator != _persistentStoreCoordinatorToWatch)) {
		return;
	}

	// no any predicate to filter updated objects?
	if (_predicateToWatch == nil) {
		DDLogDebug(@"watcher - without condition");
		_changesCallback([notification userInfo], incomingContext);
		return;
	}

	DDLogDebug(@"watcher - use condition");
	NSMutableSet *inserted = [[notification userInfo][NSInsertedObjectsKey] mutableCopy];
	NSMutableSet *deleted = [[notification userInfo][NSDeletedObjectsKey] mutableCopy];
	NSMutableSet *updated = [[notification userInfo][NSUpdatedObjectsKey] mutableCopy];

	// filter updated objects with predicate
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