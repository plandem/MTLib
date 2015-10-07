//
// Created by Andrey on 07/10/15.
// Copyright (c) 2015 Melatonin LLC. All rights reserved.
//

#import "MTBouncyViewControllerAnimator.h"

@implementation MTBouncyViewControllerAnimator
- (NSTimeInterval)transitionDuration:(id <UIViewControllerContextTransitioning>)transitionContext {
	return 0.8f;
}

- (void)animateTransition:(id <UIViewControllerContextTransitioning>)transitionContext {
	UIView *presentedView = [transitionContext viewForKey:UITransitionContextToViewKey];

	if(presentedView != nil)	{
		CGPoint center = presentedView.center;
		presentedView.center = CGPointMake(center.x, - presentedView.bounds.size.height);

		[transitionContext.containerView addSubview:presentedView];

		[UIView animateWithDuration:[self transitionDuration:transitionContext] delay: 0 usingSpringWithDamping:0.6f initialSpringVelocity:10.0f options:nil animations:^{
			presentedView.center = center;
		} completion:^(BOOL finished){
			[transitionContext completeTransition:YES];
		}];
	}
}
@end