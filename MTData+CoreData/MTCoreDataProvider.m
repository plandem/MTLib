//
// Created by Andrey on 26/05/15.
// Copyright (c) 2015 Andrey Gayvoronsky. All rights reserved.
//

#import <libextobjc/extobjc.h>
#import <NLCoreData/NLCoreData.h>
#import "MTCoreDataProvider.h"
#import "MTCoreDataWatcher.h"
#import "MTCoreDataRepository.h"
@interface MTCoreDataProvider()
@property (nonatomic, strong) MTCoreDataWatcher *watcher;
@end

@implementation MTCoreDataProvider {
	NSPredicate *_previousPredicate;
	MTCoreDataProviderOptions _options;
}

-(instancetype)initWithModelClass:(Class)modelClass {
	return [self initWithModelClass:modelClass withContext:[NSManagedObjectContext mainContext]];
}

-(instancetype)initWithModelClass:(Class)modelClass withContext:(NSManagedObjectContext *)context {
	return [self initWithModelClass:modelClass withContext:context options:MTCoreDataProviderOptionWatchStore];
}

- (instancetype)initWithModelClass:(Class)modelClass withContext:(NSManagedObjectContext *)context options:(MTCoreDataProviderOptions)options {
	return [self initWithRepository:[(MTCoreDataRepository *)[[(id<MTDataObject>)modelClass repositoryClass] alloc] initWithModelClass:modelClass withContext:context] options:options];
}

-(instancetype)initWithRepository:(MTDataRepository *)repository {
	return [self initWithRepository:repository options:MTCoreDataProviderOptionWatchStore];
}

-(instancetype)initWithRepository:(MTDataRepository *)repository options:(MTCoreDataProviderOptions)options {
	if((self = [super initWithRepository:repository])) {
		_options = options;
	}

	return self;
}

-(void)prepare:(BOOL)forceUpdate {
	if (_watcher && (_watcher.predicateToWatch == nil || _previousPredicate != self.query.predicate)) {
		_previousPredicate = ((self.query) ? self.query.predicate : nil);
		[_watcher reset];
		[_watcher addEntityToWatch:self.repository.modelClass withPredicate:_previousPredicate];
	}

	[super prepare:forceUpdate];
}

- (void)setOptions:(MTCoreDataProviderOptions)options {
	_options = options;
	_watcher = nil;
	[self setupRefresh];
}

-(MTCoreDataWatcher *)watcher {
	if(_watcher == nil) {
		_previousPredicate = nil;

		if (_options & MTCoreDataProviderOptionWatchStore) {
			_watcher = [[MTCoreDataWatcher alloc] initWithPersistentStoreCoordinator:((MTCoreDataRepository *) self.repository).context.persistentStoreCoordinator];
		} else if (_options & MTCoreDataProviderOptionWatchContext) {
			_watcher = [[MTCoreDataWatcher alloc] initWithManagedObjectContext:((MTCoreDataRepository *) self.repository).context];
		}
	}

	return _watcher;
}

-(void)setupRefresh {
	if([self refreshBlock]) {
		@weakify(self);
		self.watcher.changesCallback = ^(NSDictionary *changes, NSManagedObjectContext *ctx) {
			@strongify(self);
			if ([self refreshBlock]) {
				[self refreshBlock](self);
			}
		};
	} else {
		self.watcher.changesCallback = nil;
	}
}

-(void)setRefreshBlock:(MTDataProviderRefreshBlock)refreshBlock {
	[super setRefreshBlock:refreshBlock];
	[self setupRefresh];
}
@end