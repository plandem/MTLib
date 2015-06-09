//
// Created by Andrey on 31/05/15.
// Copyright (c) 2015 Melatonin LLC. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIImage (Addons)
+ (UIImage *)backgroundImageWithColor:(UIColor *)backgroundColor;
- (UIImage *)imageWithColor:(UIColor *)tintColor;
+ (UIImage *)imageWithColor:(UIColor *)color forSize:(CGSize)size withCornerRadius:(CGFloat)radius;
@end