//
// Created by Andrey on 26/05/15.
// Copyright (c) 2015 Andrey Gayvoronsky. All rights reserved.
//

#import <libextobjc/extobjc.h>
#import <NLCoreData/NLCoreData.h>
#import "MTCoreDataProvider.h"
#import "MTCoreDataWatcher.h"
#import "MTCoreDataRepository.h"

@implementation MTCoreDataProvider {
	MTCoreDataWatcher *_watcher;
	NSPredicate *_previousPredicate;
}

-(instancetype)initWithModelClass:(Class)modelClass {
	return [self initWithModelClass:modelClass withContext:[NSManagedObjectContext mainContext] options:MTCoreDataProviderOptionWatchContext];
}

-(instancetype)initWithModelClass:(Class)modelClass withContext:(NSManagedObjectContext *)context {
	return [self initWithModelClass:modelClass withContext:context options:MTCoreDataProviderOptionWatchContext];
}

- (instancetype)initWithModelClass:(Class)modelClass withContext:(NSManagedObjectContext *)context options:(MTCoreDataProviderOptions)options {
	return [self initWithRepository:[(MTCoreDataRepository *)[[(id<MTDataObject>)modelClass repositoryClass] alloc] initWithModelClass:modelClass withContext:context] options:options];
}

-(instancetype)initWithRepository:(MTDataRepository *)repository {
	return [self initWithRepository:repository options:MTCoreDataProviderOptionWatchContext];
}

-(instancetype)initWithRepository:(MTDataRepository *)repository options:(MTCoreDataProviderOptions)options {
	if((self = [super initWithRepository:repository])) {
		self.options = options;
	}

	return self;
}

-(void)prepare:(BOOL)forceUpdate {
	if(_watcher && (_watcher.predicateToWatch == nil || _previousPredicate != self.query.predicate)) {
		_previousPredicate = ((self.query) ? self.query.predicate : nil);
		[_watcher reset];
		[_watcher addEntityToWatch:self.repository.modelClass withPredicate:_previousPredicate];
	}

	[super prepare:forceUpdate];
}

- (void)setOptions:(MTCoreDataProviderOptions)options {
	id watchObject = nil;

	if(self.repository) {
		if (options & MTCoreDataProviderOptionWatchStore) {
			watchObject = ((MTCoreDataRepository *) self.repository).context.persistentStoreCoordinator;
		} else if (options & MTCoreDataProviderOptionWatchContext) {
			watchObject = ((MTCoreDataRepository *) self.repository).context;
		}
	}

	[self setOptions:options withWatchObject:watchObject];
}

- (void)setOptions:(MTCoreDataProviderOptions)options withWatchObject:(id)object {
	_options = options;
	_watcher = nil;

	if (_options & MTCoreDataProviderOptionWatchStore) {
		NSAssert(object && [object isKindOfClass:[NSPersistentStoreCoordinator class]], @"%@ is not %@ class.", NSStringFromClass([object class]), NSStringFromClass([NSPersistentStoreCoordinator class]));
		_watcher = [[MTCoreDataWatcher alloc] initWithPersistentStoreCoordinator:object];
	} else if (_options & MTCoreDataProviderOptionWatchContext) {
		NSAssert(object && [object isKindOfClass:[NSManagedObjectContext class]], @"%@ is not %@ class.", NSStringFromClass([object class]), NSStringFromClass([NSManagedObjectContext class]));
		_watcher = [[MTCoreDataWatcher alloc] initWithManagedObjectContext:object];
	}

	if (_watcher) {
		_previousPredicate = nil;

		@weakify(self);
		_watcher.changesCallback = ^(NSDictionary *changes, NSManagedObjectContext *ctx) {
			@strongify(self);
				if ([self refreshBlock]) {
					[self refreshBlock](self);
			}
		};
	}
}
@end