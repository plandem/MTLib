//
// Created by Andrey on 23/06/15.
// Copyright (c) 2015 Andrey. All rights reserved.
//

#import "RealmContact.h"

@implementation RealmContact

-(instancetype)init {
	if((self = [super init])) {
		self.id = [[NSUUID UUID] UUIDString];
	}

	return self;
}

+(NSString *)primaryKey {
	return @"id";
}
@end