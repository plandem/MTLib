//
// Created by Andrey on 08/06/15.
// Copyright (c) 2015 Melatonin LLC. All rights reserved.
//

#import <objc/runtime.h>
#import "NSObject+Swizzle.h"
#import "UIViewController+MTStyleKit.h"

@interface MTStyleKitObserver : NSObject
@property (nonatomic, weak) UIViewController *viewController;
-(instancetype)initWithViewController:(UIViewController *)viewController;
@end

@implementation UIViewController (MTStyleKit)
+ (void)load {
	[self swizzleInstanceSelector:@selector(viewWillAppear:) withNewSelector:@selector(swizzle_viewWillAppearStyleKit:)];
}

-(BOOL)isStyleKitApplied {
	return [objc_getAssociatedObject(self, @selector(isStyleKitApplied)) boolValue];
}

-(void)setIsStyleKitApplied:(BOOL)applied {
	objc_setAssociatedObject(self, @selector(isStyleKitApplied), @(applied), OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

-(void)swizzle_viewWillAppearStyleKit:(BOOL)animated {
	[self swizzle_viewWillAppearStyleKit:animated];

	//attach observer for updates of style kit
	if(!objc_getAssociatedObject(self, @selector(refreshStyles))) {
		objc_setAssociatedObject(self, @selector(refreshStyles), [[MTStyleKitObserver alloc] initWithViewController:self], OBJC_ASSOCIATION_RETAIN_NONATOMIC);
	}

	//used only to prevent applyStyles at each viewWillAppear - we must call it only once and we can't call it at viewDidLoad
	if(!self.isStyleKitApplied) {
		self.isStyleKitApplied = YES;

		if([self respondsToSelector:@selector(applyStyles)]) {
			[self performSelector:@selector(applyStyles)];
		}
	}
}

-(void)refreshStyles {
	if([self respondsToSelector:@selector(applyStyles)]) {
		[self performSelector:@selector(applyStyles)];
	}

	if([self isKindOfClass:[UITableViewController class]]) {
		[((UITableViewController *)self).tableView reloadData];
	} else if([self isKindOfClass:[UICollectionViewController class]]) {
		[((UICollectionViewController *)self).collectionView reloadData];
	} else {
		[self.view setNeedsDisplay];

		for(UIView *child in self.view.subviews) {
			if([child isKindOfClass:[UITableView class]]) {
				[(UITableView *)child reloadData];
			} else if([child isKindOfClass:[UICollectionView class]]) {
				[(UICollectionView *)child reloadData];
			}
		}
	}
}

@end

@implementation MTStyleKitObserver
-(instancetype)initWithViewController:(UIViewController *)viewController {
	if((self = [super init])) {
		self.viewController = viewController;

		[[NSNotificationCenter defaultCenter] addObserver:self
												 selector:@selector(handleStyleKitChangeNotification:)
													 name:(NSString *)MTStyleKitChangedNotification
												   object:nil];
	}

	return self;
}

-(void)handleStyleKitChangeNotification:(NSNotification *)notification {
	[self.viewController refreshStyles];
}

-(void)dealloc {
	[[NSNotificationCenter defaultCenter] removeObserver:self
													name:(NSString *) MTStyleKitChangedNotification
												  object:nil];
}

@end