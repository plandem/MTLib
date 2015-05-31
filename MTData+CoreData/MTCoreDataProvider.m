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
	MTCoreDataProviderOptions _options;
}

-(instancetype)initWithModelClass:(Class)modelClass {
	return [self initWithModelClass:modelClass withContext:[NSManagedObjectContext mainContext] options:MTCoreDataProviderOptionWatchContext];
}

-(instancetype)initWithModelClass:(Class)modelClass withContext:(NSManagedObjectContext *)context {
	return [self initWithModelClass:modelClass withContext:context options:MTCoreDataProviderOptionWatchStore];
}

- (instancetype)initWithModelClass:(Class)modelClass withContext:(NSManagedObjectContext *)context options:(MTCoreDataProviderOptions)options {
	if((self = [super initWithModelClass:modelClass])) {
		_options = options;

		self.repository = [(MTCoreDataRepository *)[[[self class] repositoryClass] alloc] initWithModelClass:modelClass withContext:context];
	}

	return self;
}

-(void)setRepository:(MTDataRepository *)repository {
	[super setRepository:repository];

	if(self.repository) {
		if (_options & MTCoreDataProviderOptionWatchStore) {
			_watcher = [[MTCoreDataWatcher alloc] initWithPersistentStoreCoordinator:((MTCoreDataRepository *)self.repository).context.persistentStoreCoordinator];
		} else if (_options & MTCoreDataProviderOptionWatchContext) {
			_watcher = [[MTCoreDataWatcher alloc] initWithManagedObjectContext:((MTCoreDataRepository *)self.repository).context];
		} else {
			_watcher = nil;
		}

		if (_watcher) {
			@weakify(self);
			_watcher.changesCallback = ^(NSDictionary *changes, NSManagedObjectContext *ctx) {
				@strongify(self);
				if ([self refreshBlock]) {
					[self refreshBlock](self);
				}
			};
		}
	}
}

-(void)prepare:(BOOL)forceUpdate {
	if(_watcher) {
		[_watcher reset];
		[_watcher addEntityToWatch:self.repository.modelClass withPredicate:self.query.predicate];
	}

	[super prepare:forceUpdate];
}

+(Class)repositoryClass {
	return [MTCoreDataRepository class];
}
@end