//
// Created by Andrey on 19/06/15.
// Copyright (c) 2015 Melatonin LLC. All rights reserved.
//

#import <objc/runtime.h>
#import <ReactiveCocoa/ReactiveCocoa.h>
#import "MTLib/NSObject+Swizzle.h"
#import "MTRouterProtocol.h"
#import "UIViewController+MTViewModel.h"
#import "MTListViewModel.h"

@implementation UIViewController (MTViewModel)
@dynamic viewModel;

+ (void)load {
	[self swizzleInstanceSelector:@selector(viewWillAppear:) withNewSelector:@selector(swizzle_viewWillAppearViewModel:)];
	[self swizzleInstanceSelector:@selector(viewWillDisappear:) withNewSelector:@selector(swizzle_viewWillDisappearViewModel:)];
	[self swizzleInstanceSelector:@selector(viewDidLoad) withNewSelector:@selector(swizzle_viewDidLoadViewModel)];
}

-(void)swizzle_viewWillAppearViewModel:(BOOL)animated {
	[self swizzle_viewWillAppearViewModel:animated];

	if([self viewModel]) {
		[[self viewModel] setActive:YES];
	}
}

-(void)swizzle_viewWillDisappearViewModel:(BOOL)animated {
	[self swizzle_viewWillDisappearViewModel:animated];

	if([self viewModel]) {
		[[self viewModel] setActive:NO];
	}
}

-(void)swizzle_viewDidLoadViewModel {
	[self swizzle_viewDidLoadViewModel];

#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wundeclared-selector"
	if([self respondsToSelector:@selector(router)]) {
		id router = [self performSelector:@selector(router)];

		if(router != nil && [self viewModel] == nil && [router respondsToSelector:@selector(viewModelForViewController:)]) {
			[self setViewModel:[router viewModelForViewController:self]];
		}
	}
#pragma clang diagnostic pop
}

-(void)reload {
	// Nothing to do by default. Put any code that will refresh UIViewController when viewModel had been changed.
}

-(RVMViewModel *)viewModel {
	return objc_getAssociatedObject(self, @selector(viewModel));
}

- (void)setViewModel:(RVMViewModel *)viewModel {
	objc_setAssociatedObject(self, @selector(viewModel), viewModel, OBJC_ASSOCIATION_RETAIN_NONATOMIC);

	if(viewModel && [viewModel isKindOfClass:[MTListViewModel class]]) {
		@weakify(self);
		[[(MTListViewModel *)viewModel updatedContentSignal] subscribeNext:^(id x) {
			@strongify(self);
			[self reload];
		}];
	}
}
@end