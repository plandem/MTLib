//
// Created by Andrey on 08/06/15.
// Copyright (c) 2015 Melatonin LLC. All rights reserved.
//

#import <objc/runtime.h>
#import "NSObject+Swizzle.h"
#import "UIApplication+MTStyleKit.h"
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
	if(!objc_getAssociatedObject(self, @selector(refreshStyles:))) {
		objc_setAssociatedObject(self, @selector(refreshStyles:), [[MTStyleKitObserver alloc] initWithViewController:self], OBJC_ASSOCIATION_RETAIN_NONATOMIC);
	}

	[self refreshStyles:NO];
}

-(void)refreshStylesOfViewInHierarchy:(UIView *)view {
	UIView *superview = [view superview];
	[view removeFromSuperview];
	[superview addSubview:view];
}

-(void)setNeedsRefreshStyles {
	self.isStyleKitApplied = NO;
}

-(void)refreshStyles:(BOOL)reload {
	if(self.isStyleKitApplied) {
		return;
	}

	self.isStyleKitApplied = YES;

	if([self respondsToSelector:@selector(applyStyles:)]) {
		id<MTStyleKit>styleKit = [[UIApplication sharedApplication] styleKit];

		//reset 'isStyleKitApplied' flag if needed
		self.isStyleKitApplied = [self applyStyles:styleKit];
	}

	if(reload) {
		if ([self isKindOfClass:[UITableViewController class]]) {
			[((UITableViewController *) self).tableView reloadData];
		} else if ([self isKindOfClass:[UICollectionViewController class]]) {
			[((UICollectionViewController *) self).collectionView reloadData];
		} else {
			[self.view setNeedsDisplay];

			for (UIView *child in self.view.subviews) {
				if ([child isKindOfClass:[UITableView class]]) {
					[(UITableView *) child reloadData];
				} else if ([child isKindOfClass:[UICollectionView class]]) {
					[(UICollectionView *) child reloadData];
				}
			}
		}
	}

	[self refreshStylesOfViewInHierarchy:[[self navigationController] navigationBar]];
	[self setNeedsStatusBarAppearanceUpdate];
}

-(NSMutableDictionary *)registeredStylesForCells {
	NSMutableDictionary *styles = objc_getAssociatedObject(self, @selector(registeredStylesForCells));
	if(styles == nil) {
		styles = [NSMutableDictionary dictionary];
		objc_setAssociatedObject(self, @selector(registeredStylesForCells), styles, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
	}

	return styles;
}

-(void)registerStylesForCell:(Class)className withCallback:(MTStyleKitForCellCallback)callback {
	NSString *key = NSStringFromClass(className);
	NSMutableDictionary *styles = [self registeredStylesForCells];
	if(!styles[key]) {
		styles[key] = [callback copy];
	}
}

-(void)applyStylesForCell:(id)view atIndexPath:(NSIndexPath *)indexPath {
	NSString *key = NSStringFromClass([view class]);
	MTStyleKitForCellCallback callback = [self registeredStylesForCells][key];
	if(callback) {
		id<MTStyleKit>styleKit = [[UIApplication sharedApplication] styleKit];
		callback(styleKit, view, indexPath);
	}
};

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
	[self.viewController setNeedsRefreshStyles];
	[self.viewController refreshStyles:YES];
}

-(void)dealloc {
	[[NSNotificationCenter defaultCenter] removeObserver:self
													name:(NSString *) MTStyleKitChangedNotification
												  object:nil];
}

@end