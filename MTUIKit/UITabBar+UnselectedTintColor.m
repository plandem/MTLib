//
// Created by Andrey on 10/06/15.
// Copyright (c) 2015 Melatonin LLC. All rights reserved.
//

#import <objc/runtime.h>
#import "UIImage+Addons.h"
#import "UITabBar+UnselectedTintColor.h"

@implementation UITabBar (UnselectedTintColor)
-(UIColor *)unselectedTintColor {
	return objc_getAssociatedObject(self, @selector(unselectedTintColor));
}

- (void)setUnselectedTintColor:(UIColor *)color {
	if(color) {
		objc_setAssociatedObject(self, @selector(unselectedTintColor), color, OBJC_ASSOCIATION_COPY_NONATOMIC);

		for (UITabBarItem *item in [self items]) {
			item.image = [[item.selectedImage imageWithColor:color] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
		}
	}
}
@end