//
// Created by Andrey on 18/06/15.
// Copyright (c) 2015 Melatonin LLC. All rights reserved.
//

#import "LATheme.h"
#import "LASwipeButton.h"

@implementation LASwipeButton
+(instancetype)buttonWithImageName:(NSString *)imageName withStyleKit:(id<MTStyleKit>)styleKit {
	LATheme *theme = (LATheme *)styleKit;

	LASwipeButton *button = [LASwipeButton buttonWithType:UIButtonTypeCustom];
	[button setBackgroundColor: theme.backgroundColorDark];
	[button setTintColor: theme.tintColorOnDark];
	[button setImage:[[UIImage imageNamed:imageName] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate] forState:UIControlStateNormal];

	button.titleLabel.lineBreakMode = NSLineBreakByWordWrapping;
	button.titleLabel.textAlignment = NSTextAlignmentCenter;
	button.contentEdgeInsets = UIEdgeInsetsMake(0, 20, 0, 20);
	[button sizeToFit];

	return button;
}
@end