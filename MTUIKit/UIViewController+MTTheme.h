//
// Created by Andrey on 08/06/15.
// Copyright (c) 2015 Melatonin LLC. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MTTheme.h"

@interface UIViewController (MTTheme)
@property(nonatomic, weak) id<MTTheme> theme;
-(void)applyTheme;
@end