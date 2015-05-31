//
// Created by Andrey on 28/05/15.
// Copyright (c) 2015 Andrey Gayvoronsky. All rights reserved.
//

#import "MTRealmDataRepository.h"
#import "MTRealmDataObject.h"
#import "MTRealmDataQuery.h"
#import "MTRealmDataSort.h"

@interface MTRealmDataRepository()
@property (nonatomic, strong) NSString *realmName;
@property (nonatomic, strong) NSString *realmPath;
@property (nonatomic, strong) RLMRealm *realm;
@end

@implementation MTRealmDataRepository
-(instancetype)initWithModelClass:(Class)modelClass {
	return [self initWithModelClass:modelClass withRealm:@"default"];
}

-(instancetype)initWithModelClass:(Class)modelClass withRealm:(NSString *)realmName {
	if((self = [super initWithModelClass:modelClass])) {
		self.realmName = realmName;
		self.realmPath = [NSString stringWithFormat:@"%@.realm", [[[RLMRealm defaultRealmPath] stringByDeletingLastPathComponent] stringByAppendingPathComponent:self.realmName]];
		self.realm = [RLMRealm realmWithPath:self.realmPath readOnly:NO error:nil];
	}

	return self;
}

-(void)withTransaction:(MTDataRepositoryTransactionBlock)transactionBlock {
	@try {
		[_realm beginWriteTransaction];
		transactionBlock(self);
		[_realm commitWriteTransaction];
	} @catch(NSException *e) {
		[_realm cancelWriteTransaction];
	}
}

-(void)saveModel:(id<MTDataObject>)model {
	[self ensureModelType:model];

	RLMObjectSchema *schema = ((MTRealmDataObject *)model).objectSchema;
	BOOL inWriteTransaction = _realm.inWriteTransaction;

	if(!(inWriteTransaction)) {
		[_realm beginWriteTransaction];
	}

	if (schema.primaryKeyProperty) {
		[self.modelClass createOrUpdateInRealm:_realm withValue:(id) model];
	} else {
		[_realm addObject:(id) model];
	}

	if(!(inWriteTransaction)) {
		[_realm commitWriteTransaction];
	}
}

-(void)deleteModel:(id <MTDataObject>)model {
	[self ensureModelType:model];

	BOOL inWriteTransaction = _realm.inWriteTransaction;
	if(!(inWriteTransaction)) {
		[_realm beginWriteTransaction];
	}

	[_realm deleteObject:(MTRealmDataObject *)model];

	if(!(inWriteTransaction)) {
		[_realm commitWriteTransaction];
	}
}

-(void)deleteAllWithQuery:(MTDataQuery *)query {
	BOOL inWriteTransaction = _realm.inWriteTransaction;
	if(!(inWriteTransaction)) {
		[_realm beginWriteTransaction];
	}

	[_realm deleteObjects:[self fetchAllWithQuery:query]];

	if(!(inWriteTransaction)) {
		[_realm commitWriteTransaction];
	}
}

-(id<MTDataObjectCollection>)fetchAllWithQuery:(MTDataQuery *)query {
	RLMResults *result = ((query.predicate)
			? [self.modelClass objectsInRealm:_realm withPredicate:query.predicate]
			: [self.modelClass allObjectsInRealm:_realm]);


	NSArray *sorters = query.sort.sorters;

	if(sorters && [sorters count]) {
		result = [result sortedResultsUsingDescriptors:sorters];
	}

	return (id<MTDataObjectCollection>)result;
}

+(Class)queryClass {
	return [MTRealmDataQuery class];
}
@end