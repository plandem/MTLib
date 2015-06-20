//
// Created by Andrey on 20/06/15.
// Copyright (c) 2015 Melatonin LLC. All rights reserved.
//

#import "UIApplication+StackTrace.h"

@implementation UIApplication (StackTrace)
+ (void)logStackTrace {
	@try {
		[[NSException exceptionWithName:@"Stack Trace" reason:@"Testing" userInfo:nil] raise];
	} @catch (NSException *e) {
		NSLog(@"%@", [NSThread callStackSymbols]);
	}
}

@end