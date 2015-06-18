//
// Created by Andrey on 18/06/15.
// Copyright (c) 2015 Melatonin LLC. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef void (^UIActionSheetOnClickBlock) (UIActionSheet *actionSheet, NSInteger buttonIndex);

@interface UIActionSheet (Blocks)

- (instancetype)initWithTitle:(NSString *)title
					 delegate:(id<UIActionSheetDelegate>)delegate
			cancelButtonTitle:(NSString *)cancelButtonTitle
	   destructiveButtonTitle:(NSString *)destructiveButtonTitle
			otherButtonTitles:(NSArray *)otherButtonTitles
					  onClick:(UIActionSheetOnClickBlock)onClickBlock;

@property (nonatomic, copy) UIActionSheetOnClickBlock onClick;
@end