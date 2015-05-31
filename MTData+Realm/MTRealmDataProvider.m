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
	if((self = [self init])) {
		self.repository = [(MTRealmDataRepository *)[[[self class] repositoryClass] alloc] initWithModelClass:modelClass withRealm:realmName];
	}

	return self;
}

-(void)setRepository:(MTDataRepository *)repository {
	if(_notificationToken) {
		[((MTRealmDataRepository *)self.repository).realm removeNotification:_notificationToken];
	}

	[super setRepository:repository];

	if(self.repository) {
		@weakify(self);
		_notificationToken = [((MTRealmDataRepository *) self.repository).realm addNotificationBlock:^(NSString *note, RLMRealm *realm) {
			@strongify(self);
			if ([self refreshBlock]) {
				[self refreshBlock](self);
			}
		}];
	}
}

-(void)dealloc {
	if(_notificationToken) {
		[((MTRealmDataRepository *) self.repository).realm removeNotification:_notificationToken];
	}
}

+(Class)repositoryClass {
	return [MTRealmDataRepository class];
}
@end