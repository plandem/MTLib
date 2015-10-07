//
// Created by Andrey on 31/05/15.
// Copyright (c) 2015 Melatonin LLC. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIView (Inspectable)
@property (nonatomic, assign) IBInspectable CGFloat cornerRadius UI_APPEARANCE_SELECTOR;
@property (nonatomic, assign) IBInspectable CGFloat borderWidth UI_APPEARANCE_SELECTOR;
@property (nonatomic, strong) IBInspectable UIColor *borderColor UI_APPEARANCE_SELECTOR;
@end

IB_DESIGNABLE @interface MTLiveView: UIView
@end