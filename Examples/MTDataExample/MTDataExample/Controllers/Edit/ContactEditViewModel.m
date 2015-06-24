//
// Created by Andrey on 23/06/15.
// Copyright (c) 2015 Andrey. All rights reserved.
//

#import "ContactProtocol.h"
#import "ContactEditViewModel.h"

@implementation ContactEditViewModel

-(void)setup {
	id<ContactProtocol> contact = (id <ContactProtocol>)self.model;
//	RACChannelTo(self, name, @"") = RACChannelTo(contact, name);
//	RACChannelTo(self, email, @"") = RACChannelTo(contact, email);
//	RACChannelTo(self, banned, @NO) = RACChannelTo(contact, banned);
}

-(NSArray *)fields {
	return @[
			@"name",
			@"email",
			@"banned",
	];
}

-(NSDictionary *)emailField {
	return @{
			FXFormFieldType: FXFormFieldTypeEmail,
	};
}

-(NSDictionary *)bannedField {
	return @{
			FXFormFieldType: FXFormFieldTypeBoolean,
	};
}

- (id)valueForUndefinedKey:(NSString *)key {
	return [(NSObject *)self.model valueForKey:key];
}

- (void)setValue:(id)value forUndefinedKey:(NSString *)key {
	return 	[(NSObject *)self.model setValue:value forKey:key];
}

@end