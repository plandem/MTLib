//
// Created by Andrey on 11/04/15.
// Copyright (c) 2015 Andrey Gayvoronsky. All rights reserved.
//

#import "UIButton+MTi18n.h"

@implementation UIButton (MTi18n)
@dynamic i18nAuto;

-(void)i18nFromNib {
	static NSArray *states;
	static dispatch_once_t onceToken;
	dispatch_once(&onceToken, ^{
		states = @[
				@(UIControlStateHighlighted),
				@(UIControlStateDisabled),
				@(UIControlStateSelected),
		];
	});

	//translate default title
	NSString *titleNormal = [self titleForState:UIControlStateNormal];
	if([titleNormal length] > 0) {
		[self setTitle:MTi18nString(titleNormal, nil) forState:UIControlStateNormal];
		titleNormal = [self titleForState:UIControlStateNormal];
	}

	//now let's translate titles for each other state (if provided)
	NSString *titleOther;
	UIControlState state;

	for (NSNumber *obj in states) {
		state = (UIControlState)[obj integerValue];
		titleOther = [self titleForState:state];

		if (!([titleOther isEqual:titleNormal]) && [titleOther length] > 0) {
			[self setTitle:MTi18nString(titleOther, nil) forState:state];
		}
	}
}
@end