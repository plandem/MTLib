//
// Created by Andrey on 16/06/15.
// Copyright (c) 2015 Melatonin LLC. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UITextView (Underline)
@property (nonatomic, assign) IBInspectable BOOL underlineText UI_APPEARANCE_SELECTOR;
@property (nonatomic, copy) IBInspectable UIColor *underlineColor UI_APPEARANCE_SELECTOR;
@end