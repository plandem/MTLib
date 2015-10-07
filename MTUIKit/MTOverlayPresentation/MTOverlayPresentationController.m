//
// Created by Andrey on 07/10/15.
// Copyright (c) 2015 Melatonin LLC. All rights reserved.
//

#import <libextobjc/extobjc.h>
#import "MTOverlayPresentationController.h"

@interface MTOverlayPresentationController()
@property (nonatomic, strong) UIView *dimmingView;
@end

@implementation MTOverlayPresentationController
- (instancetype)initWithPresentedViewController:(UIViewController *)presentedViewController presentingViewController:(UIViewController *)presentingViewController {
	if(self = [super initWithPresentedViewController:presentedViewController presentingViewController:presentingViewController]) {
		self.dimmingView = [[UIView alloc] init];
		self.dimmingView.backgroundColor = [UIColor colorWithWhite:0.0f alpha:0.5f];
	}

	return self;
}

-(void)presentationTransitionWillBegin {
	self.dimmingView.frame = self.containerView.bounds;
	self.dimmingView.alpha = 0.0f;

	[self.containerView insertSubview:self.dimmingView atIndex:0];

	@weakify(self);
	[self.presentedViewController.transitionCoordinator animateAlongsideTransition:^(id<UIViewControllerTransitionCoordinatorContext> context){
		@strongify(self);
		self.dimmingView.alpha = 1.0f;
	} completion:nil];
}

-(void)dismissalTransitionWillBegin {
	@weakify(self);
	[self.presentedViewController.transitionCoordinator animateAlongsideTransition:^(id<UIViewControllerTransitionCoordinatorContext> context){
		@strongify(self);
		self.dimmingView.alpha = 0.0f;
	} completion:^(id<UIViewControllerTransitionCoordinatorContext> context){
		@strongify(self);
		[self.dimmingView removeFromSuperview];
	}];
}

-(CGRect)frameOfPresentedViewInContainerView {
	return CGRectInset(self.containerView.bounds, 30.0f, 30.0f);
}

-(void)containerViewWillLayoutSubviews {
	self.dimmingView.frame = self.containerView.bounds;
	self.presentedView.frame = self.frameOfPresentedViewInContainerView;
}
@end