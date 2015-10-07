//
// Created by Andrey on 03/10/15.
// Copyright (c) 2015 Melatonin LLC. All rights reserved.
//
#import <objc/runtime.h>
#import "UIView+KeyboardAutoResign.h"
#import "UITextField+KeyboardAutoResign.h"

@implementation UITextField (KeyboardAutoResign)
- (void)setAutoResign:(BOOL)state {
	objc_setAssociatedObject(self, @selector(autoResign), @(state), OBJC_ASSOCIATION_COPY_NONATOMIC);

	//let's locate topmost superview
	UIView *view = self;
	while (view.superview != nil) {
		view = view.superview;
	}

	[view autoResignTextField:self process:state];
}

- (BOOL)autoResign {
	NSNumber *autoResign = objc_getAssociatedObject(self, @selector(autoResign));
	return autoResign ? [autoResign boolValue] : NO;
}
@end