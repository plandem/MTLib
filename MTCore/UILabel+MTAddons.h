//
// Created by Andrey on 20/09/14.
// Copyright (c) 2014 Andrey Gayvoronsky. All rights reserved.
//

@import UIKit;

@interface UILabel (MTAddons)
@property (nonatomic, assign) IBInspectable UIEdgeInsets edgeInsets;
- (void)swizzle_drawTextInRect:(CGRect)rect;
- (CGRect)swizzle_textRectForBounds:(CGRect)bounds limitedToNumberOfLines:(NSInteger)numberOfLines;

@end