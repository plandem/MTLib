//
// Created by Andrey on 26/05/15.
// Copyright (c) 2015 Andrey Gayvoronsky. All rights reserved.
//

#import "MTCoreDataProvider.h"
#import "MTCoreDataQuery.h"
#import "NSManagedObjectContext+MTAddons.h"
#import "MTCoreDataContextWatcher.h"

@interface MTCoreDataProvider ()
@property (nonatomic, strong) NSManagedObjectContext *context;
@property (nonatomic, strong) MTCoreDataContextWatcher *watcher;
@end

@implementation MTCoreDataProvider

-(instancetype)initWithModelClass:(Class)modelClass withContext:(NSManagedObjectContext *)context {
	if((self = [super initWithModelClass:modelClass])) {
		self.context = context;
		self.limit = 0;
		self.offset = 0;
		self.batchSize = 0;
		self.includesPendingChanges = YES;
		self.includesPropertyValues = YES;
		self.shouldRefreshRefetchedObjects = YES;
		self.returnsObjectsAsFaults = YES;
		self.returnsDistinctResults = NO;
		self.resultType = NSManagedObjectResultType;

		__weak typeof(self) weakSelf = self;
		self.watcher = [[MTCoreDataContextWatcher alloc] initWithPersistentStoreCoordinator:[context persistentStoreCoordinator]];
		self.watcher.changesBlock = ^(NSDictionary *changes, NSManagedObjectContext *ctx) {
			NSLog(@"%@", changes);
			if([weakSelf refreshBlock]) {
				[weakSelf refreshBlock](weakSelf);
			}
		};
	}

	return self;
}

-(void)deleteAtIndexPath:(NSIndexPath *)indexPath {
//	[_realm beginWriteTransaction];
//	[_realm deleteObject:[self modelAtIndexPath:indexPath]];
//	[_realm commitWriteTransaction];
}

-(id<MTDataObject>)modelAtIndexPath:(NSIndexPath *)indexPath {
//	RLMResults *models = (RLMResults *)self.models;
//	return ((models && (indexPath.row < [models count] )) ? models[indexPath.row] : nil);
	return nil;
}

-(id<NSFastEnumeration>)prepareModels {

	[_watcher addEntityToWatch:NSStringFromClass(self.modelClass) withPredicate: self.query.predicate];

	__block NSError *error;
	__block NSArray *result;

	[_context performBlock:^{
		result = [_context executeFetchRequest:[self fetchRequest] error:&error];
	} async:NO];

	NSAssert(error == nil, @"Fetching error %@, %@", error, [error userInfo]);
	return result;
}

-(void)moveFromIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath {
	NSAssert(false, @"There is no any implementation for 'moveFromIndexPath'");
}

-(id<MTDataObject>)createModel {
	return (id<MTDataObject>)[self.modelClass createInContext:_context];
}

-(void)saveModel:(id<MTDataObject>)model {
	NSAssert(false, @"MTCoreDataProvider does not support saveModel...");
}

-(void)withTransaction:(MTDataProviderSaveBlock)saveBlock {
	NSAssert(false, @"MTCoreDataProvider does not support transactions...");
}

-(NSFetchRequest *)fetchRequest {
	NSEntityDescription *entity = [NSEntityDescription entityForName:NSStringFromClass(self.modelClass) inManagedObjectContext:_context];

	//That's strange, but exception is not catching, so another manual checking :(
	NSAssert(entity != nil && entity.name != nil && [entity.name length] > 1, @"There is no NSEntityDescription with name=%@ at provided context", NSStringFromClass(self.modelClass));

	NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName: entity.name];
	MTCoreDataQuery *query = (MTCoreDataQuery *)self.query;

	[request setFetchLimit:_limit];
	[request setFetchOffset:_offset];
	[request setFetchBatchSize:_batchSize];
	[request setResultType: _resultType];

	[request setIncludesPendingChanges:_includesPendingChanges];
	[request setIncludesPropertyValues:_includesPropertyValues];
	[request setShouldRefreshRefetchedObjects:_shouldRefreshRefetchedObjects];
	[request setReturnsObjectsAsFaults:_returnsObjectsAsFaults];

//	if(criteria.select && [criteria.select count]) {
//		[request setResultType: NSDictionaryResultType];
//		[request setPropertiesToFetch: criteria.select];
//		[request setReturnsDistinctResults:criteria.returnsDistinctResults];
//	}

//	if(query.groupList && [query.groupList count]) {
//		[request setResultType: NSDictionaryResultType];
//		[request setPropertiesToFetch: @[@"*"]];
//		[request setPropertiesToGroupBy: query.groupList];
//
//		if(criteria.having)
//			[request setHavingPredicate:criteria.having];
//	}
//
//	if(query.withList && [query.withList count])
//		[request setRelationshipKeyPathsForPrefetching:query.withList];
//
	if(query.predicate)
		[request setPredicate:query.predicate];

	if(self.sort && [self.sort.sorters count])
		[request setSortDescriptors:self.sort.sorters];

//	if([request resultType] == NSCountResultType) {
//		NSLog(@"You must use countByCriteria method to count entities. Aborting");
//		exit(-1);
//	}

	return request;
}

-(Class)queryClass {
	return [MTCoreDataQuery class];
}
@end