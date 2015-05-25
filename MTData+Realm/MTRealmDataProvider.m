//
// Created by Andrey on 28/04/15.
// Copyright (c) 2015 Andrey Gayvoronsky. All rights reserved.
//

#import <Realm/Realm.h>
#import "MTRealmDataProvider.h"
#import "MTRealmDataSort.h"

@interface MTRealmDataProvider ()
@property (nonatomic, strong) NSString *realmName;
@property (nonatomic, strong) NSString *realmPath;
@property (nonatomic, strong) RLMRealm *realm;
@property (nonatomic, strong) RLMNotificationToken *notificationToken;
@end

@implementation MTRealmDataProvider
-(instancetype)initWithModelClass:(Class)modelClass withRealm:(NSString *)realmName {
	if((self = [self initWithModelClass:modelClass])) {
		self.realmName = realmName;
		self.realmPath = [NSString stringWithFormat:@"%@.realm", [[[RLMRealm defaultRealmPath] stringByDeletingLastPathComponent] stringByAppendingPathComponent:self.realmName]];
		self.realm = [RLMRealm realmWithPath:self.realmPath readOnly:NO error:nil];

		__weak typeof(self) weakSelf = self;
		self.notificationToken = [weakSelf.realm addNotificationBlock:^(NSString *note, RLMRealm * realm) {
			if([weakSelf refreshBlock])
				[weakSelf refreshBlock]();
		}];

	}

	return self;
}

-(void)dealloc {
	[self.realm removeNotification:_notificationToken];
}

-(void)deleteAtIndexPath:(NSIndexPath *)indexPath {
	[_realm beginWriteTransaction];
	[_realm deleteObject:[self modelAtIndexPath:indexPath]];
	[_realm commitWriteTransaction];
}

-(id)modelAtIndexPath:(NSIndexPath *)indexPath {
	RLMResults *models = (RLMResults *)self.models;
	return ((models && (indexPath.row < [models count] )) ? models[indexPath.row] : nil);
}

-(id<NSFastEnumeration>)prepareModels {
	MTDataQuery *query = self.query;

	RLMResults *result = ((query.predicate)
			? [self.modelClass objectsInRealm:_realm withPredicate:self.query.predicate]
			: [self.modelClass allObjectsInRealm:_realm]);


	NSArray *sorters = self.sort.sorters;

	if(sorters && [sorters count]) {
		result = [result sortedResultsUsingDescriptors:sorters];
	}

	return result;
}

-(void)moveFromIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath {
	NSAssert(false, @"There is no any implementation for 'moveFromIndexPath'");
}

-(Class)sortClass {
	return [MTRealmDataSort class];
}

-(void)saveModel:(MTDataObject *)model {
	NSAssert([model isKindOfClass:self.modelClass], @"Model[%@] must be same class[%@] as model that was used to create DataProvider.", model.class, self.modelClass);

	RLMObjectSchema *schema = model.objectSchema;
	BOOL inWriteTransaction = _realm.inWriteTransaction;

	if(!(inWriteTransaction)) {
		[_realm beginWriteTransaction];
	}

	if (schema.primaryKeyProperty) {
		[self.modelClass createOrUpdateInRealm:_realm withValue:model];
	} else {
		[_realm addObject:model];
	}

	if(!(inWriteTransaction)) {
		[_realm commitWriteTransaction];
	}
}

-(void)withTransaction:(MTDataProviderSaveBlock)saveBlock {
	[_realm beginWriteTransaction];
	saveBlock(self);
	[_realm commitWriteTransaction];
}
@end