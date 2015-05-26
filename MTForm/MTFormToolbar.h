//
// Created by Andrey on 22/04/15.
// Copyright (c) 2015 Melatonin LLC. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef void (^MTFormBaseCellToolbarActionBlock)();

@interface MTFormToolbar : UIToolbar
@property (nonatomic, readonly) UILabel *titleLabel;
@property (nonatomic, readonly) UIBarButtonItem *closeButton;
@property (nonatomic, copy) MTFormBaseCellToolbarActionBlock action;
@end