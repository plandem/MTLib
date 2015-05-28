//
// Created by Andrey on 28/04/15.
// Copyright (c) 2015 Melatonin LLC. All rights reserved.
//

#import <libextobjc/extobjc.h>
#import "MTRealmDataObject.h"
#import "MTRealmDataSort.h"
#import "MTRealmDataProvider.h"

@interface MTRealmDataProvider ()
@property (nonatomic, strong) NSString *realmName;
@property (nonatomic, strong) NSString *realmPath;
@property (nonatomic, strong) RLMRealm *realm;
@property (nonatomic, strong) RLMNotificationToken *notificationToken;
@end

@implementation MTRealmDataProvider
-(instancetype)initWithModelClass:(Class)modelClass {
	return [self initWithModelClass:modelClass withRealm:@"default"];
}

-(instancetype)initWithModelClass:(Class)modelClass withRealm:(NSString *)realmName {
	if((self = [super initWithModelClass:modelClass])) {
		self.realmName = realmName;
		self.realmPath = [NSString stringWithFormat:@"%@.realm", [[[RLMRealm defaultRealmPath] stringByDeletingLastPathComponent] stringByAppendingPathComponent:self.realmName]];
		self.realm = [RLMRealm realmWithPath:self.realmPath readOnly:NO error:nil];

		@weakify(self);
		self.notificationToken = [self.realm addNotificationBlock:^(NSString *note, RLMRealm * realm) {
			@strongify(self);
			if([self refreshBlock]) {
				[self refreshBlock](self);
			}
		}];
	}

	return self;
}

-(void)dealloc {
	[self.realm removeNotification:_notificationToken];
}

-(void)deleteAtIndexPath:(NSIndexPath *)indexPath {
	[_realm beginWriteTransaction];
	[_realm deleteObject:(MTRealmDataObject *)[self modelAtIndexPath:indexPath]];
	[_realm commitWriteTransaction];
}

-(id<MTDataObject>)modelAtIndexPath:(NSIndexPath *)indexPath {
	RLMResults *models = (RLMResults *)self.models;
	return ((models && (indexPath.row < [models count])) ? models[(NSUInteger)indexPath.row] : nil);
}

-(id<MTDataProviderCollection>)prepareModels {
	MTDataQuery *query = self.query;

	RLMResults *result = ((query.predicate)
			? [self.modelClass objectsInRealm:_realm withPredicate:self.query.predicate]
			: [self.modelClass allObjectsInRealm:_realm]);


	NSArray *sorters = self.sort.sorters;

	if(sorters && [sorters count]) {
		result = [result sortedResultsUsingDescriptors:sorters];
	}

	return (id<MTDataProviderCollection>)result;
}

-(void)moveFromIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath {
	NSAssert(false, @"There is no any implementation for 'moveFromIndexPath'");
}

-(Class)sortClass {
	return [MTRealmDataSort class];
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

-(id<MTDataObject>)createModel {
	return (id<MTDataObject>)[[self.modelClass alloc] init];
}

-(void)withTransaction:(MTDataProviderSaveBlock)saveBlock {
	[_realm beginWriteTransaction];
	saveBlock(self);
	[_realm commitWriteTransaction];
}
@end