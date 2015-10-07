//
// Created by Andrey on 03/10/15.
// Copyright (c) 2015 Melatonin LLC. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIView (KeyboardAutoResign)
@property (nonatomic, assign) IBInspectable BOOL autoResignSubviews;
-(void)autoResignTextField:(UITextField *)textField process:(BOOL)process;
@end