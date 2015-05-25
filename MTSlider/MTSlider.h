//
//  MTSlider.h
//  Slider
//
//  Created by Alexey Bukhtin on 01.04.15.
//  Copyright (c) 2015 MT. All rights reserved.
//

#import <UIKit/UIKit.h>

@class MTSlider;

typedef UIView *(^MTSliderItemViewsBlock)(MTSlider *slider, NSUInteger index, BOOL selected);
typedef void(^MTSliderAnimationBlock)(MTSlider *slider, UIView *selectedItemView, UIView *itemViewsContainer);
typedef void(^MTSliderIndexChangedBlock)(MTSlider *slider, NSUInteger index, BOOL dragging);

#pragma mark - Slider

@interface MTSlider : UISlider

@property (nonatomic) NSUInteger index;
@property (nonatomic, copy) NSArray *itemViews;
@property (nonatomic, copy) NSArray *selectedItemViews;
@property (nonatomic, copy) MTSliderItemViewsBlock itemViewsBlock;
@property (nonatomic) CGFloat itemViewsContainerOffsetY;
@property (nonatomic, copy) MTSliderAnimationBlock showSelectedItemViewAnimationBlock;
@property (nonatomic, copy) MTSliderAnimationBlock hideSelectedItemViewAnimationBlock;
@property (nonatomic, copy) MTSliderIndexChangedBlock onIndexChangeBlock;

- (void)updateItemViews;
- (void)updateItemViewAtIndex:(NSUInteger)index;

@end

#pragma mark - Slider Item Container Protocol

@protocol MTSlideItemContainerProtocol <NSObject>

@property (nonatomic) CGFloat pointerCenterX;

@end