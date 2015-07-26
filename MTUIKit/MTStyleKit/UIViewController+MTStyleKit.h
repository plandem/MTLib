//
// Created by Andrey on 08/06/15.
// Copyright (c) 2015 Melatonin LLC. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MTStyleKit.h"

@interface UIViewController (MTStyleKit)
//this method (if implemented) will be called once at 'viewWillAppear'
//-(void)applyStyles;

//this method is called each time after setting a new style kit for UIApplication
-(void)refreshStyles;

//implement it if you use FXForms and want to style fields
//-(void)applyStylesForFieldCell:(FXFormBaseCell *)fieldCell;
@end