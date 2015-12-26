//
// Created by Andrey on 28/05/15.
// Copyright (c) 2015 Andrey Gayvoronsky. All rights reserved.
//

#import "MTRealmDataProvider.h"
#import "MTRealmDataRepository.h"
#import "MTRealmDataObject.h"
#import "MTRealmDataSort.h"
#import "MTLogger.h"

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
		_realmName = realmName;
		_realmPath = [NSString stringWithFormat:@"%@.realm", [[[[RLMRealmConfiguration defaultConfiguration] path] stringByDeletingLastPathComponent] stringByAppendingPathComponent:_realmName]];
		_realm = [RLMRealm realmWithPath:_realmPath];
	}

	return self;
}

-(void)beginTransaction {
	if(![self inTransaction]) {
		[_realm beginWriteTransaction];
	}
}

-(void)commitTransaction {
	NSAssert([self inTransaction], MTDataErrorNoActiveTransaction);
	[_realm commitWriteTransaction];
}

-(void)rollbackTransaction {
	NSAssert([self inTransaction], MTDataErrorNoActiveTransaction);
	[_realm cancelWriteTransaction];
}

-(BOOL)inTransaction {
	return _realm.inWriteTransaction;
}

-(void)saveModel:(id<MTDataObject>)model {
	[self ensureModelType:model];

	RLMObjectSchema *schema = ((MTRealmDataObject *)model).objectSchema;

	if (schema.primaryKeyProperty) {
		[self.modelClass createOrUpdateInRealm:_realm withValue:(id) model];
	} else {
		[_realm addObject:(id) model];
	}
}

-(void)deleteModel:(id <MTDataObject>)model {
	[self ensureModelType:model];
	[_realm deleteObject:(MTRealmDataObject *)model];
}

-(void)deleteAllWithQuery:(MTDataQuery *)query {
	[_realm deleteObjects:[self fetchAllWithQuery:query]];
}

-(void)undoModel:(id<MTDataObject>)model {
	//do nothing. In Realm we can ignore any changes - just don't save it.
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
@end