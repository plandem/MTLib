//
// Created by Andrey on 07/10/15.
// Copyright (c) 2015 Melatonin LLC. All rights reserved.
//

#import "MTOverlayTransitioningDelegate.h"
#import "MTOverlayPresentationController.h"
#import "MTBouncyViewControllerAnimator.h"

@implementation MTOverlayTransitioningDelegate

- (UIPresentationController *)presentationControllerForPresentedViewController:(UIViewController *)presented presentingViewController:(UIViewController *)presenting sourceViewController:(UIViewController *)source{
	return [[MTOverlayPresentationController alloc] initWithPresentedViewController:presented presentingViewController:presenting];
}

- (id <UIViewControllerAnimatedTransitioning>)animationControllerForPresentedController:(UIViewController *)presented presentingController:(UIViewController *)presenting sourceController:(UIViewController *)source {
	return [[MTBouncyViewControllerAnimator alloc] init];
}
@end