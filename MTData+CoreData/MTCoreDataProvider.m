//
// Created by Andrey on 26/05/15.
// Copyright (c) 2015 Andrey Gayvoronsky. All rights reserved.
//

#import <libextobjc/extobjc.h>
#import <NLCoreData/NLCoreData.h>
#import "MTCoreDataProvider.h"
#import "MTCoreDataQuery.h"
#import "MTCoreDataContextWatcher.h"
#import "MTCoreDataEnumerator.h"

@interface MTCoreDataProvider () <NSFetchedResultsControllerDelegate>
@property (nonatomic, strong) NSManagedObjectContext *context;
@property (nonatomic, strong) MTCoreDataContextWatcher *watcher;
@property (nonatomic, strong) NSFetchRequest *fetchRequest;
@end

@implementation MTCoreDataProvider

-(instancetype)initWithModelClass:(Class)modelClass withContext:(NSManagedObjectContext *)context {
	if((self = [super initWithModelClass:modelClass])) {
		self.context = context;
		self.batchSize = 0;

		@weakify(self);
		self.watcher = [[MTCoreDataContextWatcher alloc] initWithPersistentStoreCoordinator:context.persistentStoreCoordinator];
		self.watcher.changesCallback = ^(NSDictionary *changes, NSManagedObjectContext *ctx) {
			@strongify(self);
			if([self refreshBlock]) {
				[self refreshBlock](self);
			}
		};
	}

	return self;
}

-(void)deleteAtIndexPath:(NSIndexPath *)indexPath {
	@weakify(self);
	[_context performBlock:^{
		@strongify(self);
		NSManagedObject *model = (NSManagedObject *)[self modelAtIndexPath:indexPath];
		[self.context deleteObject:model];
		[self.context saveNested];
	}];
}

-(id<MTDataProviderCollection>)prepareModels {
	[_watcher addEntityToWatch:self.modelClass withPredicate: self.query.predicate];
	return [[MTCoreDataFetchResult alloc] initWithFetchRequest:[self fetchRequest] inContext:_context];
}

-(void)moveFromIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath {
	NSAssert(false, @"There is no any implementation for 'moveFromIndexPath'");
}

-(id<MTDataObject>)createModel {
	return (id<MTDataObject>) [self.modelClass insertInContext:_context];
}

-(void)saveModel:(id<MTDataObject>)model {
	NSAssert(false, @"MTCoreDataProvider does not support saveModel. Only entire context can be saved.");
}

-(void)withTransaction:(MTDataProviderSaveBlock)saveBlock {
	NSAssert(false, @"MTCoreDataProvider does not support transactions.");
}

-(NSFetchRequest *)fetchRequest {
	if(_fetchRequest == nil) {
		_fetchRequest = [NSFetchRequest fetchRequestWithEntity:self.modelClass context:_context];
		MTCoreDataQuery *query = (MTCoreDataQuery *)self.query;

		if(query.predicate) {
			[_fetchRequest setPredicate:query.predicate];
		}

		if(self.sort && [self.sort.sorters count]) {
			[_fetchRequest setSortDescriptors:self.sort.sorters];
		}

		[_fetchRequest setFetchLimit:self.batchSize];
	}

	return _fetchRequest;
}

-(void)setQuery:(MTDataQuery *)query {
	[super setQuery:query];
	_fetchRequest = nil;
}

-(void)setSort:(MTDataSort *)sort {
	_fetchRequest = nil;
}

-(MTDataProvider *)makeQuery:(void(^)(MTDataQuery *query, MTDataSort *sort))block {
	[super makeQuery:block];
	_fetchRequest = nil;
	return self;
}

-(Class)queryClass {
	return [MTCoreDataQuery class];
}
@end