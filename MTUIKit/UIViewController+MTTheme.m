//
// Created by Andrey on 08/06/15.
// Copyright (c) 2015 Melatonin LLC. All rights reserved.
//

#import <objc/runtime.h>
#import "NSObject+Swizzle.h"
#import "UIViewController+MTTheme.h"

@implementation UIViewController (MTTheme)

+ (void)load {
	[self swizzleInstanceSelector:@selector(viewWillAppear:) withNewSelector:@selector(swizzle_viewWillAppear:)];
}

-(id<MTTheme>)theme {
	id<MTTheme> theme = objc_getAssociatedObject(self, @selector(theme));
	if(theme) {
		return theme;
	}

	id application = [[UIApplication sharedApplication] delegate];
	if([application respondsToSelector:@selector(theme)]) {
		theme = [application performSelector:@selector(theme)];
		[self setTheme:theme];
	}

	return theme;
}

- (void)setTheme:(id<MTTheme>)theme {
	if(theme && theme != objc_getAssociatedObject(self, @selector(theme))) {
		objc_setAssociatedObject(self, @selector(theme), theme, OBJC_ASSOCIATION_ASSIGN);
		objc_setAssociatedObject(self, @selector(applyTheme), @(NO), OBJC_ASSOCIATION_ASSIGN);
	}
}

-(void)swizzle_viewWillAppear:(BOOL)animated {
	[self swizzle_viewWillAppear:animated];

	if(!([objc_getAssociatedObject(self, @selector(applyTheme)) boolValue])) {
		[self applyTheme];
		objc_setAssociatedObject(self, @selector(applyTheme), @(YES), OBJC_ASSOCIATION_ASSIGN);
	}
}

-(void)applyTheme {
	// Nothing to do by default. Put any code that will style UIViewController here.
}
@end