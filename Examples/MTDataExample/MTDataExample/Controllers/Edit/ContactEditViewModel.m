//
// Created by Andrey on 23/06/15.
// Copyright (c) 2015 Andrey. All rights reserved.
//

#import "ContactProtocol.h"
#import "ContactEditViewModel.h"

@implementation ContactEditViewModel
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
@end