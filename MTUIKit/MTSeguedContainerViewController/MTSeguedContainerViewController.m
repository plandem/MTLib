//
// Created by Andrey on 27/06/15.
// Copyright (c) 2015 Melatonin LLC. All rights reserved.
//

#import <libextobjc/extobjc.h>
#import "MTSeguedContainerViewController.h"

@interface MTSeguedViewControllerState: NSObject {
@public
	NSTimeInterval duration;
	UIViewAnimationOptions options;
	void(^willTransit)(UIViewController *fromController, UIViewController *toController, NSString *segueIdentifier);
	void(^animations)(UIViewController *fromController, UIViewController *toController, NSString *segueIdentifier);
	void(^completion)(BOOL finished, UIViewController *fromController, UIViewController *toController, NSString *segueIdentifier);
	NSString* segue;
	BOOL active;
}
@end;

@implementation MTSeguedViewControllerState
@end;

@interface MTSeguedContainerViewController ()
@property (strong, nonatomic) MTSeguedViewControllerState *state;
@end

@implementation MTSeguedContainerViewController

- (void)viewDidLoad{
	[super viewDidLoad];

	self.state = [[MTSeguedViewControllerState alloc] init];
	self.state->active = NO;
}

- (void)showContentController:(UIViewController *) controller {
	// adjust the frame to fit in the container view
	controller.view.frame = self.view.bounds;
	// make sure that it resizes on rotation automatically
	controller.view.autoresizingMask = self.view.autoresizingMask;
	// add as child VC
	[self addChildViewController:controller];
	// add it to container view, calls willMoveToParentViewController for us
	[self.view addSubview:controller.view];
	// notify it that move is done
	[controller didMoveToParentViewController:self];
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
	//is there any child here?
	if([self.childViewControllers count]) {
		//same as already active?
		if([self.childViewControllers[0] isMemberOfClass:[segue.destinationViewController class]]) {
			self.state->active = NO;
			return;
		}

		 //ok, transit to new controller
		[self swapFromViewController:self.childViewControllers[0] toViewController:segue.destinationViewController];
		return;
	}

	//looks like there no any child yet, so just show it
	[self showContentController: segue.destinationViewController];
	self.state->active = NO;
}

- (void)swapFromViewController:(UIViewController *)fromViewController toViewController:(UIViewController *)toViewController {
	//fix frame size
	toViewController.view.frame = self.view.bounds;

	// make sure that it will resize on rotation automatically
	toViewController.view.autoresizingMask = self.view.autoresizingMask;

	[fromViewController willMoveToParentViewController:nil];
	[self addChildViewController:toViewController];

	if(self.state->willTransit) {
		self.state->willTransit(fromViewController, toViewController, self.state->segue);
	}

	@weakify(self);
	[self transitionFromViewController:fromViewController
					  toViewController:toViewController
							  duration:self.state->duration
							   options:self.state->options
							animations:^
			{
				@strongify(self);
			     if(self.state->animations) {
					 self.state->animations(fromViewController, toViewController, self.state->segue);
				 }
			}
							completion:^(BOOL finished)
			{
				@strongify(self);
				if(self.state->completion) {
					self.state->completion(finished, fromViewController, toViewController, self.state->segue);
				}

				[fromViewController removeFromParentViewController];
				[toViewController didMoveToParentViewController:self];
				self.state->active = NO;
			}];
}

- (void)switchViewControllerWithSegueIdentifier:(NSString *)segueIdentifier
									   duration:(NSTimeInterval)duration
										options:(UIViewAnimationOptions)options
									willTransit:(void (^)(UIViewController *fromController, UIViewController *toController, NSString *segueIdentifier))willTransit
									 animations:(void (^)(UIViewController *fromController, UIViewController *toController, NSString *segueIdentifier))animations
									 completion:(void (^)(BOOL finished, UIViewController *fromController, UIViewController *toController, NSString *segueIdentifier))completion
{
	if (self.state->active) {
		return;
	}

	self.state->active = YES;
	self.state->duration = duration;
	self.state->willTransit = willTransit;
	self.state->animations = animations;
	self.state->completion = completion;
	self.state->options = options;
	self.state->segue = [segueIdentifier copy];

	@try {
		[self performSegueWithIdentifier:segueIdentifier sender:self];
	} @catch(NSException *exception) {
		NSLog(@"Can't perform segue with identifier=%@. %@", segueIdentifier, exception);
		self.state->active = NO;
	}
}

- (void)switchViewControllerWithSegueIdentifier:(NSString *)segueIdentifier {
	[self switchViewControllerWithSegueIdentifier:segueIdentifier duration:0.0f options:UIViewAnimationOptionTransitionNone willTransit:nil animations:nil completion:nil];
}

-(BOOL)transitionInProgress {
	return self.state->active;
}

-(NSString *)currentSegueIdentifier {
	return self.state->segue;
}

- (BOOL)canPerformAction:(SEL)action withSender:(id)sender {
	if([self.parentViewController canPerformAction:action withSender:sender]) {
		return YES;
	}

	return [super canPerformAction:action withSender:sender];
}

- (id)targetForAction:(SEL)action withSender:(id)sender {
	if([self.parentViewController canPerformAction:action withSender:sender]) {
		return self.parentViewController;
	}

	return [super targetForAction:action withSender:sender];
}

@end