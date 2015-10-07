//
// Created by Andrey on 07/10/15.
// Copyright (c) 2015 Melatonin LLC. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface MTOverlayTransitioningDelegate : NSObject <UIViewControllerTransitioningDelegate>
- (UIPresentationController *)presentationControllerForPresentedViewController:(UIViewController *)presented presentingViewController:(UIViewController *)presenting sourceViewController:(UIViewController *)source;
- (id <UIViewControllerAnimatedTransitioning>)animationControllerForPresentedController:(UIViewController *)presented presentingController:(UIViewController *)presenting sourceController:(UIViewController *)source;
@end