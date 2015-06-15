//
// Created by Andrey on 12/06/15.
// Copyright (c) 2015 Melatonin LLC. All rights reserved.
//
#import <objc/runtime.h>
#import "UIView+CustomBorder.h"

@implementation UIView (CustomBorder)
-(UIColor *)customBorderColor {
	UIColor *color = objc_getAssociatedObject(self, @selector(customBorderColor));

	if(color) {
		return color;
	}

	return [self tintColor];
}

-(void)setCustomBorderColor:(UIColor *)color {
	if(color) {
		objc_setAssociatedObject(self, @selector(customBorderColor), color, OBJC_ASSOCIATION_COPY_NONATOMIC);
	}
}

-(UIViewCustomBorderType)customBorderType {
	NSAssert(false, @"There is no getter for customBorderType.");
	return UIViewCustomBorderTypeNone;
}

-(void)setCustomBorderType:(UIViewCustomBorderType)type {
	CAShapeLayer *borderLayer;

	NSString *customBorderKey = NSStringFromSelector(@selector(setCustomBorderType:));

	CALayer *layer = [self layer];
	CGRect frame = [self frame];

	// non-atomic!
	if(!(borderLayer = [layer valueForKey:customBorderKey])) {
		borderLayer = [CAShapeLayer layer];
		[layer setValue:borderLayer forKey:customBorderKey];
	} else {
		[borderLayer removeFromSuperlayer];
		borderLayer = [CAShapeLayer layer];
		[layer setValue:borderLayer forKey:customBorderKey];
	}

	UIBezierPath *borderPath = [[UIBezierPath alloc] init];

	if(type & UIViewCustomBorderTypeTop) {
		[borderPath moveToPoint:CGPointMake(0.0, 0.0)];
		[borderPath addLineToPoint:CGPointMake(frame.size.width, 0.0)];
	}

	if(type & UIViewCustomBorderTypeRight) {
		[borderPath moveToPoint:CGPointMake(frame.size.width, 0.0)];
		[borderPath addLineToPoint:CGPointMake(frame.size.width, frame.size.height)];
	}

	if(type & UIViewCustomBorderTypeBottom) {
		[borderPath moveToPoint:CGPointMake(frame.size.width, frame.size.height)];
		[borderPath addLineToPoint:CGPointMake(0.0, frame.size.height)];
	}

	if(type & UIViewCustomBorderTypeLeft) {
		[borderPath moveToPoint:CGPointMake(0.0, frame.size.height)];
		[borderPath addLineToPoint:CGPointMake(0.0, 0.0)];
	}

	borderLayer.path = [borderPath CGPath];
	borderLayer.strokeColor = [[self customBorderColor] CGColor];
	borderLayer.fillColor = [[UIColor clearColor] CGColor];
	borderLayer.lineWidth = 1.0;

	[layer addSublayer:borderLayer];
}
@end