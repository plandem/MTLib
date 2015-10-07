//
// Created by Andrey on 03/10/15.
// Copyright (c) 2015 Melatonin LLC. All rights reserved.
//

#import <objc/runtime.h>
#import "UIView+KeyboardAutoResign.h"

@implementation UIView (KeyboardAutoResign)
- (void)setAutoResignSubviews:(BOOL)state {
	UITapGestureRecognizer *recognizer = objc_getAssociatedObject(self, (@selector(autoResignSubviewsTap:)));

	if(state) {
		if(!(recognizer)) {
			recognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(autoResignSubviewsTap:)];
			[recognizer setCancelsTouchesInView: NO];
			objc_setAssociatedObject(self, @selector(autoResignSubviewsTap:), recognizer, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
			[self addGestureRecognizer:recognizer];
		}
	} else {
		if(recognizer) {
			[self removeGestureRecognizer:recognizer];
		}
	}

	objc_setAssociatedObject(self, @selector(autoResignSubviews), @(state), OBJC_ASSOCIATION_COPY_NONATOMIC);
}

- (BOOL)autoResignSubviews {
	NSNumber *autoResign = objc_getAssociatedObject(self, @selector(autoResignSubviews));
	return autoResign ? [autoResign boolValue] : NO;
}

- (void)autoResignSubviewsTap:(UITapGestureRecognizer *)recognizer {
	for (UIView *view in self.subviews) {
		if ([view isKindOfClass:[UITextField class]] && [view isFirstResponder]) {
			[view resignFirstResponder];
			break;
		}
	}
}

- (void)autoResignTextFieldTap:(UITapGestureRecognizer *)recognizer {
	NSMutableArray *fields = objc_getAssociatedObject(self, (@selector(autoResignTextField:process:)));
	for (UITextField *textField in fields) {
		if ([textField isFirstResponder]) {
			[textField resignFirstResponder];
			break;
		}
	}
}

-(void)autoResignTextField:(UITextField *)textField process:(BOOL)process {
	NSMutableArray *fields = objc_getAssociatedObject(self, (@selector(autoResignTextField:process:)));
	if(!(fields)) {
		fields = [NSMutableArray array];
		objc_setAssociatedObject(self, @selector(autoResignTextField:process:), fields, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
	}

	UITapGestureRecognizer *recognizer = objc_getAssociatedObject(self, (@selector(autoResignTextFieldTap:)));
	if(!(recognizer)) {
		recognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(autoResignTextFieldTap:)];
		[recognizer setCancelsTouchesInView: NO];
		objc_setAssociatedObject(self, @selector(autoResignTextFieldTap:), recognizer, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
		[self addGestureRecognizer:recognizer];
	}

	NSInteger index = [fields indexOfObject:textField];
	if(index == NSNotFound) {
		if(process) {
			[fields addObject:textField];
		}
	} else {
		if(!(process)) {
			[fields removeObject:textField];
		}
	}
}
@end