//
// Created by Andrey on 07/10/15.
// Copyright (c) 2015 Melatonin LLC. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface MTBouncyViewControllerAnimator : NSObject <UIViewControllerAnimatedTransitioning>
- (NSTimeInterval)transitionDuration:(id <UIViewControllerContextTransitioning>)transitionContext;
- (void)animateTransition:(id <UIViewControllerContextTransitioning>)transitionContext;
@end