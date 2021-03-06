//
// Created by Andrey on 22/04/15.
// Copyright (c) 2015 Melatonin LLC. All rights reserved.
//

#import <libextobjc/extobjc.h>
#import "MTForm.h"
#import "NSObject+Swizzle.h"

NSString *const MTFormFieldToolbarTitle = @"toolbar.title";
NSString *const MTFormFieldToolbarButton = @"toolbar.button";

@implementation FXFormBaseCell (MTForm)
@dynamic toolbar;

-(UIView *)inputAccessoryView {
	return self.toolbar;
}

-(MTFormToolbar *)toolbar {
	MTFormToolbar *_toolbar = objc_getAssociatedObject(self, @selector(toolbar));

	if (_toolbar == nil) {
		_toolbar = [[MTFormToolbar alloc] initWithFrame:CGRectZero];

		@weakify(self);
		_toolbar.action = ^{
			@strongify(self);
			[self resignFirstResponder];
		};

		objc_setAssociatedObject(self, @selector(toolbar), _toolbar, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
	}

	return _toolbar;
}

+ (void)load {
	[self swizzleInstanceSelector:@selector(initWithStyle:reuseIdentifier:) withNewSelector:@selector(swizzle_initWithStyle:reuseIdentifier:)];
}

#pragma clang diagnostic push
#pragma ide diagnostic ignored "InfiniteRecursion"
- (instancetype)swizzle_initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
	id result;

	if((result = [self swizzle_initWithStyle:style reuseIdentifier:reuseIdentifier])) {
		((FXFormBaseCell *)result).textLabel.font = MT_FORM_FONT_TEXT;
		((FXFormBaseCell *)result).detailTextLabel.font = MT_FORM_FONT_DETAIL;
	}

	return result;
}
#pragma clang diagnostic pop
@end