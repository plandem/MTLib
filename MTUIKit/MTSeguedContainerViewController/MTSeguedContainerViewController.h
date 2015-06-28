//
// Created by Andrey on 27/06/15.
// Copyright (c) 2015 Melatonin LLC. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface MTSeguedContainerViewController : UIViewController

- (void)switchViewControllerWithSegueIdentifier:(NSString *)segueIdentifier
									   duration:(NSTimeInterval)duration
										options:(UIViewAnimationOptions)options
									willTransit:(void (^)(UIViewController *fromController, UIViewController *toController, NSString *segueIdentifier))willTransit
									 animations:(void (^)(UIViewController *fromController, UIViewController *toController, NSString *segueIdentifier))animations
									 completion:(void (^)(BOOL finished, UIViewController *fromController, UIViewController *toController, NSString *segueIdentifier))completion;

- (void)switchViewControllerWithSegueIdentifier:(NSString *)segueIdentifier;

@property (nonatomic, readonly, weak) NSString* currentSegueIdentifier;
@property (nonatomic, readonly) BOOL transitionInProgress;
@end