//
// Created by Andrey on 31/05/15.
// Copyright (c) 2015 Melatonin LLC. All rights reserved.
//

#import "UIImage+Addons.h"

@implementation UIImage (Addons)
+ (UIImage *)backgroundImageWithColor:(UIColor *)backgroundColor {
	CGRect rect = CGRectMake(0.0f, 0.0f, 1.0f, 1.0f);
	UIGraphicsBeginImageContext(rect.size);
	CGContextRef context = UIGraphicsGetCurrentContext();

	CGContextSetFillColorWithColor(context, [backgroundColor CGColor]);
	CGContextFillRect(context, rect);

	UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
	UIGraphicsEndImageContext();

	return image;
}

- (UIImage *)imageWithColor:(UIColor *)tintColor {
	CGSize size = [self size];

	UIGraphicsBeginImageContextWithOptions(size, NO, 0.0);
	CGRect bounds = CGRectMake(0, 0, size.width, size.height);

	[tintColor setFill];

	UIRectFill(bounds);
	[self drawInRect:bounds blendMode:kCGBlendModeDestinationIn alpha:1.0];

	UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
	UIGraphicsEndImageContext();

	return image;
}

+ (UIImage *)imageWithColor:(UIColor *)color forSize:(CGSize)size withCornerRadius:(CGFloat)radius {
	CGRect rect = CGRectMake(0, 0, size.width, size.height);
	UIGraphicsBeginImageContext(rect.size);

	CGContextRef context = UIGraphicsGetCurrentContext();
	CGContextSetFillColorWithColor(context, [color CGColor]);
	CGContextFillRect(context, rect);

	UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
	UIGraphicsEndImageContext();

	// Begin a new image that will be the new image with the rounded corners
	// (here with the size of an UIImageView)
	UIGraphicsBeginImageContext(size);

	// Add a clip before drawing anything, in the shape of an rounded rect
	[[UIBezierPath bezierPathWithRoundedRect:rect cornerRadius:radius] addClip];
	// Draw your image
	[image drawInRect:rect];

	// Get the image, here setting the UIImageView image
	image = UIGraphicsGetImageFromCurrentImageContext();

	// Lets forget about that we were drawing
	UIGraphicsEndImageContext();

	return image;
}
@end