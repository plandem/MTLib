//
// Created by Andrey on 27/12/15.
// Copyright (c) 2015 Melatonin LLC. All rights reserved.
//

#import <UIKit/UIKit.h>
//
//extern NSString *const MTCornerRadiusAttributeName;
//extern NSString *const MTBorderWidthAttributeName;
//extern NSString *const MTBorderColorAttributeName;
//extern NSString *const MTEdgeInsetsAttributeName;
//extern NSString *const MTOpaqueAttributeName;
//
//@interface UIView (MTStyleKitAppearancePatch)
//- (void)setAttributes:(NSDictionary *)textAttributes UI_APPEARANCE_SELECTOR;
//@end

@interface UIButton (MTStyleKitAppearancePatch)
- (void)setTitleLabelFont:(UIFont *)titleFont UI_APPEARANCE_SELECTOR;
@end
