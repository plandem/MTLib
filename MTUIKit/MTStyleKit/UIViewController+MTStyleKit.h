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
-(void)registerStylesForClass:(Class)className withCallback:(id)callback;
-(void)applyStylesForView:(UIView *)view;
-(void)applyStylesForView:(UIView *)view withObject:(id)object;
-(void)applyStylesForView:(UIView *)view withObject:(id)object1 withObject:(id)object2;

//same as 'applyStylesForView' but 'className' will be used instead of class of 'view'
-(void)applyStylesForClass:(Class)className view:(UIView *)view;
-(void)applyStylesForClass:(Class)className view:(UIView *)view withObject:(id)object;
-(void)applyStylesForClass:(Class)className view:(UIView *)view withObject:(id)object1 withObject:(id)object2;
@end