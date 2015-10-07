//
// Created by Andrey on 31/05/15.
// Copyright (c) 2015 Melatonin LLC. All rights reserved.
//

#import "UIView+Inspectable.h"

@implementation UIView (Inspectable)
@dynamic borderColor;
@dynamic borderWidth;
@dynamic cornerRadius;

- (void) setBorderColor:(UIColor *)borderColor {
	self.layer.borderColor = borderColor.CGColor;
}

- (UIColor *) borderColor {
	return [UIColor colorWithCGColor:self.layer.borderColor];
}

- (void) setBorderWidth:(CGFloat)borderWidth {
	self.layer.borderWidth = borderWidth;
}

- (CGFloat) borderWidth {
	return self.layer.borderWidth;
}

- (void)setCornerRadius:(CGFloat)cornerRadius {
	self.layer.cornerRadius = cornerRadius;
}

- (CGFloat)cornerRadius {
	return self.layer.cornerRadius;
}
@end

@implementation MTLiveView
@end