//
// Created by Alexey Bukhtin on 01.04.15.
// Copyright (c) 2015 Melatonin LLC. All rights reserved.
//

#import "MTSlider.h"

@interface MTSliderItemContainerView : UIView <MTSlideItemContainerProtocol>

@property (nonatomic, readonly) UIView *itemView;
@property (nonatomic) BOOL pointerHidden;
@property (nonatomic) CGSize pointerSize;

- (instancetype)initWithItemView:(UIView *)itemView edgeInsets:(UIEdgeInsets)edgeInsets;

@end
