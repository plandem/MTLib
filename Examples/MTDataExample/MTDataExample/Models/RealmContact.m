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

//added for demo purposes only, because ContactEditViewModel does not use properties directly
- (id)valueForUndefinedKey:(NSString *)key {
	if([key isEqual:@"name"]) {
		return self.name;
	} else if([key isEqual:@"email"]) {
		return self.email;
	} else if([key isEqual:@"banned"]) {
		return @(self.banned);
	}

	return nil;
}

//added for demo purposes only, because ContactEditViewModel does not use properties directly
- (void)setValue:(id)value forUndefinedKey:(NSString *)key {
	if ([key isEqual:@"name"]) {
		self.name = value;
	} else if ([key isEqual:@"email"]) {
		self.email = value;
	} else if ([key isEqual:@"banned"]) {
		self.banned = [value integerValue];
	}
}

+(NSString *)primaryKey {
	return @"id";
}
@end