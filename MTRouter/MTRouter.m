//
// Created by Andrey on 10/06/15.
// Copyright (c) 2015 Melatonin LLC. All rights reserved.
//
// Based on http://etolstoy.ru/slim-routers/
//

#import "UIViewController+MTRouter.h"
#import "MTRouterProtocol.h"
#import "MTRouter.h"

@implementation MTRouter
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
	UIViewController *sourceViewController = segue.sourceViewController;
	MTRouterPreparationBlock block = [sourceViewController preparationBlockForSegue:segue];

	if (block) {
		block(segue);
	}
}

- (void)dismissViewController:(UIViewController *)viewController animated:(BOOL)animated {
	if (viewController.presentingViewController) {
		[viewController dismissViewControllerAnimated:animated completion:nil];
	} else {
		[viewController.navigationController popViewControllerAnimated:animated];
	}
}
@end