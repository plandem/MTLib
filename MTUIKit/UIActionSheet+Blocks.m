//
// Created by Andrey on 18/06/15.
// Copyright (c) 2015 Melatonin LLC. All rights reserved.
//

#import <objc/runtime.h>
#import "UIActionSheet+Blocks.h"

@implementation UIActionSheet (Blocks)
- (id)initWithTitle:(NSString *)title
					 delegate:(id<UIActionSheetDelegate>)delegate
			cancelButtonTitle:(NSString *)cancelButtonTitle
	   destructiveButtonTitle:(NSString *)destructiveButtonTitle
			otherButtonTitles:(NSArray *)otherButtonTitles
					  onClick:(UIActionSheetOnClickBlock)onClickBlock
{
	if(self) {
		self = [self initWithTitle:title delegate:delegate cancelButtonTitle:cancelButtonTitle destructiveButtonTitle:destructiveButtonTitle otherButtonTitles:nil];

		if (delegate)
			self.delegate = delegate;

		for (NSString *text in otherButtonTitles)
			[self addButtonWithTitle:text];

		if (onClickBlock)
			self.onClick = onClickBlock;
	}

	return self;
}

- (void)checkDelegate {
	if (self.delegate != (id<UIActionSheetDelegate>)self) {
		objc_setAssociatedObject(self, @selector(checkDelegate), self.delegate, OBJC_ASSOCIATION_ASSIGN);
		self.delegate = (id<UIActionSheetDelegate>)self;
	}
}

- (UIActionSheetOnClickBlock)onClick {
	return objc_getAssociatedObject(self, @selector(onClick));
}

- (void)setOnClick:(UIActionSheetOnClickBlock)onClickBlock {
   [self checkDelegate];
	objc_setAssociatedObject(self, @selector(onClick), onClickBlock, OBJC_ASSOCIATION_COPY);
}

#pragma mark - UIActionSheetDelegate
- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex {
	UIActionSheetOnClickBlock callback = actionSheet.onClick;

	if (callback)
		callback(actionSheet, buttonIndex);

	id originalDelegate = objc_getAssociatedObject(self, @selector(checkDelegate));

	if (originalDelegate && [originalDelegate respondsToSelector:@selector(actionSheet:clickedButtonAtIndex:)])
		[originalDelegate actionSheet:actionSheet clickedButtonAtIndex:buttonIndex];
}

- (void)actionSheetCancel:(UIActionSheet *)actionSheet {
	id originalDelegate = objc_getAssociatedObject(self, @selector(checkDelegate));

	if (originalDelegate && [originalDelegate respondsToSelector:@selector(actionSheetCancel:)])
		[originalDelegate actionSheetCancel:actionSheet];
}

- (void)willPresentActionSheet:(UIActionSheet *)actionSheet {
	id originalDelegate = objc_getAssociatedObject(self, @selector(checkDelegate));

	if (originalDelegate && [originalDelegate respondsToSelector:@selector(willPresentActionSheet:)])
		[originalDelegate willPresentActionSheet:actionSheet];
}

- (void)didPresentActionSheet:(UIActionSheet *)actionSheet {
	id originalDelegate = objc_getAssociatedObject(self, @selector(checkDelegate));

	if (originalDelegate && [originalDelegate respondsToSelector:@selector(didPresentActionSheet:)])
		[originalDelegate didPresentActionSheet:actionSheet];
}

- (void)actionSheet:(UIActionSheet *)actionSheet willDismissWithButtonIndex:(NSInteger)buttonIndex {
	id originalDelegate = objc_getAssociatedObject(self, @selector(checkDelegate));

	if (originalDelegate && [originalDelegate respondsToSelector:@selector(actionSheet:willDismissWithButtonIndex:)])
		[originalDelegate actionSheet:actionSheet willDismissWithButtonIndex:buttonIndex];
}

- (void)actionSheet:(UIActionSheet *)actionSheet didDismissWithButtonIndex:(NSInteger)buttonIndex {
	id originalDelegate = objc_getAssociatedObject(self, @selector(checkDelegate));

	if (originalDelegate && [originalDelegate respondsToSelector:@selector(actionSheet:didDismissWithButtonIndex:)])
		[originalDelegate actionSheet:actionSheet didDismissWithButtonIndex:buttonIndex];
}
@end