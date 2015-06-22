//
// Created by Andrey on 19/06/15.
// Copyright (c) 2015 Melatonin LLC. All rights reserved.
//

#import <objc/runtime.h>
#import "MTLib/NSObject+Swizzle.h"
#import "MTRouterProtocol.h"
#import "UIViewController+MTListViewModel.h"

@implementation UIViewController (MTListViewModel)
@dynamic viewModel;

+ (void)load {
	[self swizzleInstanceSelector:@selector(viewWillAppear:) withNewSelector:@selector(swizzle_viewWillAppearListViewModel:)];
	[self swizzleInstanceSelector:@selector(viewWillDisappear:) withNewSelector:@selector(swizzle_viewWillDisappearListViewModel:)];
	[self swizzleInstanceSelector:@selector(viewDidLoad) withNewSelector:@selector(swizzle_viewDidLoadListViewModel)];
}

-(void)swizzle_viewWillAppearListViewModel:(BOOL)animated {
	[self swizzle_viewWillAppearListViewModel:animated];
	if([self conformsToProtocol:@protocol(MTListViewModelProtocol)]) {
		[[self viewModel] setActive:YES];
	}
}

-(void)swizzle_viewWillDisappearListViewModel:(BOOL)animated {
	[self swizzle_viewWillDisappearListViewModel:animated];
	if([self conformsToProtocol:@protocol(MTListViewModelProtocol)]) {
		[[self viewModel] setActive:NO];
	}
}

-(void)swizzle_viewDidLoadListViewModel {
	[self swizzle_viewDidLoadListViewModel];

#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wundeclared-selector"
	if([self respondsToSelector:@selector(router)]) {
		id router = [self performSelector:@selector(router)];

		if(router != nil && [self viewModel] == nil && [router respondsToSelector:@selector(viewModelForViewController:)]) {
			[self setViewModel:[router viewModelForViewController:self]];
		}
	}
#pragma clang diagnostic pop

	if([self conformsToProtocol:@protocol(MTListViewModelProtocol)]) {
		@weakify(self);
		[[[self viewModel] updatedContentSignal] subscribeNext:^(id x) {
			@strongify(self);
			[self reload];
		}];
	}
}

-(void)reload {
	// Nothing to do by default. Put any code that will refresh UIViewController when viewModel had been changed.
}

-(MTListViewModel *)viewModel {
	return objc_getAssociatedObject(self, @selector(viewModel));
}

- (void)setViewModel:(MTListViewModel *)viewModel {
	objc_setAssociatedObject(self, @selector(viewModel), viewModel, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}
@end