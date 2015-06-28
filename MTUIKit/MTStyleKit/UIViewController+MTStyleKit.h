//
// Created by Andrey on 08/06/15.
// Copyright (c) 2015 Melatonin LLC. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MTStyleKit.h"

@interface UIViewController (MTStyleKit)
@property(nonatomic, weak) id<MTStyleKit> styleKit;
-(void)applyStyles;
@end