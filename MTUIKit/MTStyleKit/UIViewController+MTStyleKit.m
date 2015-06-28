//
// Created by Andrey on 08/06/15.
// Copyright (c) 2015 Melatonin LLC. All rights reserved.
//

#import <objc/runtime.h>
#import "NSObject+Swizzle.h"
#import "UIViewController+MTStyleKit.h"

@implementation UIViewController (MTStyleKit)
@dynamic styleKit;

+ (void)load {
	[self swizzleInstanceSelector:@selector(viewWillAppear:) withNewSelector:@selector(swizzle_viewWillAppearStyleKit:)];
}

-(id<MTStyleKit>)styleKit {
	//has already attached styleKit?
	id<MTStyleKit> styleKit = objc_getAssociatedObject(self, @selector(styleKit));
	if(styleKit) {
		return styleKit;
	}

	//ok, let's try to get styleKit from UIApplication
	id application = [[UIApplication sharedApplication] delegate];
	if([application respondsToSelector:@selector(styleKit)]) {
		styleKit = [application performSelector:@selector(styleKit)];
		[self setStyleKit:styleKit];
	}

	return styleKit;
}

- (void)setStyleKit:(id<MTStyleKit>)styleKit {
	if(styleKit && styleKit != objc_getAssociatedObject(self, @selector(styleKit))) {
		objc_setAssociatedObject(self, @selector(styleKit), styleKit, OBJC_ASSOCIATION_ASSIGN);
		objc_setAssociatedObject(self, @selector(applyStyles), @(NO), OBJC_ASSOCIATION_ASSIGN);
	}
}

-(void)swizzle_viewWillAppearStyleKit:(BOOL)animated {
	[self swizzle_viewWillAppearStyleKit:animated];

	if(!([objc_getAssociatedObject(self, @selector(applyStyles)) boolValue])) {
		[self applyStyles];
		objc_setAssociatedObject(self, @selector(applyStyles), @(YES), OBJC_ASSOCIATION_ASSIGN);
	}
}

-(void)applyStyles {
	// Nothing to do by default. Put any code that will style UIViewController here.
}
@end