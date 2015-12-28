//
// Created by Andrey on 08/06/15.
// Copyright (c) 2015 Melatonin LLC. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MTStyleKit.h"

typedef void(^MTStyleKitForViewCallback0)(id viewController, id<MTStyleKit>styleKit, id view);
typedef void(^MTStyleKitForViewCallback1)(id viewController, id<MTStyleKit>styleKit, id view, id object);
typedef void(^MTStyleKitForViewCallback2)(id viewController, id<MTStyleKit>styleKit, id view, id object1, id object2);

@interface UIViewController (MTStyleKit) <MTStyleKit>
//implement it if you use FXForms and want to style fields
//-(void)applyStylesForFieldCell:(FXFormBaseCell *)fieldCell;

-(void)registerStylesForView:(Class)className withCallback:(id)callback;
-(void)applyStylesForView:(UIView *)view;
-(void)applyStylesForView:(UIView *)view withObject:(id)object;
-(void)applyStylesForView:(UIView *)view withObject:(id)object1 withObject:(id)object2;
@end