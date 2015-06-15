//
// Created by Andrey on 12/06/15.
// Copyright (c) 2015 Melatonin LLC. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef NS_OPTIONS(NSInteger, UIViewCustomBorderType) {
	UIViewCustomBorderTypeNone = 0,
	UIViewCustomBorderTypeTop = 1 << 0,
	UIViewCustomBorderTypeRight = 1 << 1,
	UIViewCustomBorderTypeBottom = 1 << 2,
	UIViewCustomBorderTypeLeft = 1 << 3,
	UIViewCustomBorderTypeAll = UIViewCustomBorderTypeTop | UIViewCustomBorderTypeRight | UIViewCustomBorderTypeBottom | UIViewCustomBorderTypeLeft,
};

@interface UIView (CustomBorder)
@property (nonatomic) UIViewCustomBorderType customBorderType UI_APPEARANCE_SELECTOR;
@property (nonatomic) UIColor *customBorderColor UI_APPEARANCE_SELECTOR;
@end