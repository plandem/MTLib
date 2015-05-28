//
// Created by Andrey on 28/05/15.
//

#import <libextobjc/extobjc.h>
#import <NLCoreData/NLCoreData.h>
#import "MTCoreDataRepository.h"
#import "MTCoreDataFetchResult.h"
#import "MTDataSort.h"

@interface MTCoreDataRepository()
@property (nonatomic, strong) NSManagedObjectContext *context;
@end

@implementation MTCoreDataRepository
- (instancetype)initWithModelClass:(Class)modelClass withContext:(NSManagedObjectContext *)context {
	if((self = [self initWithModelClass:modelClass])) {
		_context = context;
	}

	return self;
}

-(id<MTDataObject>)createModel {
	return (id<MTDataObject>)[self.modelClass insertInContext:_context];
}

-(void)deleteModel:(id<MTDataObject>)model {
	@weakify(self);
	[_context performBlock:^{
		@strongify(self);
		[self.context deleteObject:(NSManagedObject *)model];
		[self.context saveNested];
	}];
}

-(id<MTDataObjectCollection>)fetchAllWithQuery:(MTDataQuery *)query {
	NSFetchRequest *fetchRequest = [NSFetchRequest fetchRequestWithEntity:self.modelClass context:_context];

	if(query.predicate) {
		[fetchRequest setPredicate:query.predicate];
	}

	if([query.sort.sorters count]) {
		[fetchRequest setSortDescriptors:query.sort.sorters];
	}

	[fetchRequest setFetchLimit:query.batchSize];

	return [[MTCoreDataFetchResult alloc] initWithFetchRequest:fetchRequest inContext:_context];
}

//-(void)withTransaction:(MTDataRepositoryTransactionBlock)transaction {
//	[self notImplemented:_cmd];
//}

//-(void)saveModel:(id<MTDataObject>)model {
//	[self notImplemented:_cmd];
//}

//-(void)deleteAll {
//	[self notImplemented:_cmd];
//}

//-(void)deleteAllWithQuery:(MTDataQuery *)query {
//	[self notImplemented:_cmd];
//}

@end