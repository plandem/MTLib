//
// Created by Andrey on 08/06/15.
// Copyright (c) 2015 Melatonin LLC. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MTStyleKit.h"

typedef void(^MTStyleKitForCellCallback)(id<MTStyleKit>styleKit, id cell, NSIndexPath *indexPath);

@interface UIViewController (MTStyleKit) <MTStyleKit>
//implement it if you use FXForms and want to style fields
//-(void)applyStylesForFieldCell:(FXFormBaseCell *)fieldCell;

-(void)registerStylesForCell:(Class)className withCallback:(MTStyleKitForCellCallback)callback;
-(void)applyStylesForCell:(UIView *)cell atIndexPath:(NSIndexPath *)indexPath;
@end