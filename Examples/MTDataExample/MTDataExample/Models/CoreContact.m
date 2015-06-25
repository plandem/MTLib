//
// Created by Andrey on 23/06/15.
// Copyright (c) 2015 Andrey. All rights reserved.
//

#import "CoreContact.h"

@implementation CoreContact
@dynamic name;
@dynamic email;
@dynamic banned;

-(BOOL)validateValue:(id *)value forKey:(NSString *)key error:(NSError **)error {
	NSLog(@"validateValue");
	return [super validateValue:value forKey:key error:error];
}
@end