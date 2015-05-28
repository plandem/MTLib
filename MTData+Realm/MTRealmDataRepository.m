//
// Created by Andrey on 28/05/15.
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

-(void)withTransaction:(MTDataRepositoryTransactionBlock)saveBlock {
	[_realm beginWriteTransaction];
	saveBlock(self);
	[_realm commitWriteTransaction];
}

-(void)saveModel:(id<MTDataObject>)model {
	NSAssert([model isKindOfClass:self.modelClass], @"Model[%@] must be same class[%@] as model that was used to create DataProvider.", model.class, self.modelClass);

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
	[_realm beginWriteTransaction];
	[_realm deleteObject:(MTRealmDataObject *)model];
	[_realm commitWriteTransaction];
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