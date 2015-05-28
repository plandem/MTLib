//
// Created by Andrey on 26/05/15.
// Copyright (c) 2015 Andrey Gayvoronsky. All rights reserved.
//

#import <libextobjc/extobjc.h>
#import <NLCoreData/NLCoreData.h>
#import "MTCoreDataProvider.h"
#import "MTCoreDataWatcher.h"
#import "MTCoreDataRepository.h"

@interface MTCoreDataProvider () <NSFetchedResultsControllerDelegate>
@property (nonatomic, strong) MTCoreDataWatcher *watcher;
@end

@implementation MTCoreDataProvider

-(instancetype)initWithModelClass:(Class)modelClass {
	return [self initWithModelClass:modelClass withContext:[NSManagedObjectContext mainContext]];
}

-(instancetype)initWithModelClass:(Class)modelClass withContext:(NSManagedObjectContext *)context {
	if((self = [super initWithModelClass:modelClass])) {
		self.repository = [(MTCoreDataRepository *)[[[self class] repositoryClass] alloc] initWithModelClass:modelClass withContext:context];

		@weakify(self);
		self.watcher = [[MTCoreDataWatcher alloc] initWithPersistentStoreCoordinator:context.persistentStoreCoordinator];
		self.watcher.changesCallback = ^(NSDictionary *changes, NSManagedObjectContext *ctx) {
			@strongify(self);
			if([self refreshBlock]) {
				[self refreshBlock](self);
			}
		};
	}

	return self;
}

-(void)prepare:(BOOL)forceUpdate {
	[_watcher reset];
	[_watcher addEntityToWatch:self.repository.modelClass withPredicate:self.query.predicate];
	[super prepare:forceUpdate];
}

+(Class)repositoryClass {
	return [MTCoreDataRepository class];
}
@end