//
// Created by Andrey on 22/04/15.
// Copyright (c) 2015 Melatonin LLC. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <FXForms/FXForms.h>
@class MTFormToolbar;

UIKIT_EXTERN NSString *const MTFormFieldToolbarTitle;	//toolbar.title
UIKIT_EXTERN NSString *const MTFormFieldToolbarButton;	//toolbar.button

@interface FXFormBaseCell (MTForm)
@property (nonatomic, readonly) MTFormToolbar *toolbar;
@end