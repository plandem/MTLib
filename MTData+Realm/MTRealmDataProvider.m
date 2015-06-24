//
// Created by Andrey on 28/04/15.
// Copyright (c) 2015 Melatonin LLC. All rights reserved.
//

#import <libextobjc/extobjc.h>
#import "MTRealmDataObject.h"
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
	return [self initWithRepository:[(MTRealmDataRepository *)[[(id<MTDataObject>)modelClass repositoryClass] alloc] initWithModelClass:modelClass withRealm:realmName]];
}

-(void)dealloc {
	if(_notificationToken) {
		[((MTRealmDataRepository *) self.repository).realm removeNotification:_notificationToken];
	}
}

-(void)setupWatcher {
	if(_notificationToken) {
		[((MTRealmDataRepository *)self.repository).realm removeNotification:_notificationToken];
	}

	if([self refreshBlock] && self.repository) {
		@weakify(self);
		_notificationToken = [((MTRealmDataRepository *) self.repository).realm addNotificationBlock:^(NSString *note, RLMRealm *realm) {
			@strongify(self);
			if ([self refreshBlock]) {
				[self refreshBlock](self);
			}
		}];
	}
}

@end