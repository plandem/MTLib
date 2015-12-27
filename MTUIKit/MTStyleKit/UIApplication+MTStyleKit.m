//
// Created by Andrey on 25/07/15.
// Copyright (c) 2015 Melatonin LLC. All rights reserved.
//

#import <objc/runtime.h>
#import "UIApplication+MTStyleKit.h"

const NSString *MTStyleKitChangedNotification = @"MTStyleKitChangedNotification";

@implementation UIApplication (MTStyleKit)
-(id<MTStyleKit>)styleKit {
	return objc_getAssociatedObject(self, @selector(styleKit));
}

- (void)setStyleKit:(id<MTStyleKit>)styleKit {
	if(styleKit && styleKit != objc_getAssociatedObject(self, @selector(styleKit))) {
		objc_setAssociatedObject(self, @selector(styleKit), styleKit, OBJC_ASSOCIATION_RETAIN);

		//post notification about new styleKit
		[[NSNotificationCenter defaultCenter] postNotificationName:(NSString *)MTStyleKitChangedNotification object:styleKit userInfo:nil];

		//force windows to refresh their root controllers (some UIAppearance styles can be applied only if refresh controller)
		NSArray *windows = [UIApplication sharedApplication].windows;
		for (UIWindow *window in windows) {
			for (UIView *view in window.subviews) {
				[view removeFromSuperview];
				[window addSubview:view];
			}
		}
	}
}

@end