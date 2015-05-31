//
// Created by Andrey on 31/05/15.
// Copyright (c) 2015 Melatonin LLC. All rights reserved.
//

#import "UIImage+MTAddons.h"

@implementation UIImage (MTAddons)
+ (UIImage *)backgroundImageWithColor:(UIColor *)color {
	CGRect rect = CGRectMake(0.0f, 0.0f, 1.0f, 1.0f);
	UIGraphicsBeginImageContext(rect.size);
	CGContextRef context = UIGraphicsGetCurrentContext();

	CGContextSetFillColorWithColor(context, [color CGColor]);
	CGContextFillRect(context, rect);

	UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
	UIGraphicsEndImageContext();

	return image;
}

@end