//
// Created by Andrey on 07/10/15.
// Copyright (c) 2015 Melatonin LLC. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface MTOverlayPresentationController : UIPresentationController
- (instancetype)initWithPresentedViewController:(UIViewController *)presentedViewController presentingViewController:(UIViewController *)presentingViewController;
-(void)presentationTransitionWillBegin;
-(void)dismissalTransitionWillBegin;
-(CGRect)frameOfPresentedViewInContainerView;
-(void)containerViewWillLayoutSubviews;
@end