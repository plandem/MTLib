//
// Created by Andrey on 28/04/15.
// Copyright (c) 2015 Melatonin LLC. All rights reserved.
//

#import <libextobjc/extobjc.h>
#import "MTRealmDataObject.h"
#import "MTRealmDataSort.h"
#import "MTRealmDataRepository.h"
#import "MTRealmDataProvider.h"

@interface MTRealmDataProvider ()
@property (nonatomic, strong) RLMNotificationToken *notificationToken;
@end

@implementation MTRealmDataProvider
-(instancetype)initWithModelClass:(Class)modelClass {
	return [self initWithModelClass:modelClass withRealm:@"default"];
}

-(instancetype)initWithModelClass:(Class)modelClass withRealm:(NSString *)realmName {
	if((self = [super initWithModelClass:modelClass])) {
		self.repository = [(MTRealmDataRepository *)[[[self class] repositoryClass] alloc] initWithModelClass:modelClass withRealm:realmName];

		@weakify(self);
		self.notificationToken = [((MTRealmDataRepository *)self.repository).realm addNotificationBlock:^(NSString *note, RLMRealm * realm) {
			@strongify(self);
			if([self refreshBlock]) {
				[self refreshBlock](self);
			}
		}];
	}

	return self;
}

-(void)dealloc {
	[((MTRealmDataRepository *)self.repository).realm removeNotification:_notificationToken];
}

+(Class)repositoryClass {
	return [MTRealmDataRepository class];
}
@end