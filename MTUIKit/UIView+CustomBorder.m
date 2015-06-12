//
// Created by Andrey on 12/06/15.
// Copyright (c) 2015 Melatonin LLC. All rights reserved.
//

#import "UIView+CustomBorder.h"

@implementation UIView (CustomBorder)
-(UIViewCustomBorderType)customBorderType {
	NSAssert(false, @"There is no getter for customBorderType.");
	return UIViewCustomBorderTypeNone;
}

-(void)setCustomBorderType:(UIViewCustomBorderType)type {
	CAShapeLayer *borderLayer;

	NSString *customBorderKey = NSStringFromSelector(@selector(setCustomBorderType:));

	// non-atomic!
	if(!(borderLayer = [self.layer valueForKey:customBorderKey])) {
		borderLayer = [CAShapeLayer layer];
		[self.layer setValue:borderLayer forKey:customBorderKey];
	} else {
		[borderLayer removeFromSuperlayer];
		borderLayer = [CAShapeLayer layer];
		[self.layer setValue:borderLayer forKey:customBorderKey];
	}

	UIBezierPath *borderPath = [[UIBezierPath alloc] init];

	if(type & UIViewCustomBorderTypeTop) {
		[borderPath moveToPoint:CGPointMake(0.0, 0.0)];
		[borderPath addLineToPoint:CGPointMake(self.frame.size.width, 0.0)];
	}

	if(type & UIViewCustomBorderTypeRight) {
		[borderPath moveToPoint:CGPointMake(self.frame.size.width, 0.0)];
		[borderPath addLineToPoint:CGPointMake(self.frame.size.width, self.frame.size.height)];
	}

	if(type & UIViewCustomBorderTypeBottom) {
		[borderPath moveToPoint:CGPointMake(self.frame.size.width, self.frame.size.height)];
		[borderPath addLineToPoint:CGPointMake(0.0, self.frame.size.height)];
	}

	if(type & UIViewCustomBorderTypeLeft) {
		[borderPath moveToPoint:CGPointMake(0.0, self.frame.size.height)];
		[borderPath addLineToPoint:CGPointMake(0.0, 0.0)];
	}

//	[borderPath closePath];

	borderLayer.path = [borderPath CGPath];
	borderLayer.strokeColor = [[UIColor blackColor] CGColor];
	borderLayer.fillColor = [[UIColor clearColor] CGColor];
	borderLayer.lineWidth = 1.0;

	[self.layer addSublayer:borderLayer];
}
@end