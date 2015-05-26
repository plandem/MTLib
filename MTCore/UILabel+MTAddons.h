//
// Created by Andrey on 26/04/15.
// Copyright (c) 2015 Melatonin LLC. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UILabel (MTAddons)
@property (nonatomic, assign) IBInspectable UIEdgeInsets edgeInsets;
- (void)swizzle_drawTextInRect:(CGRect)rect;
- (CGRect)swizzle_textRectForBounds:(CGRect)bounds limitedToNumberOfLines:(NSInteger)numberOfLines;

@end