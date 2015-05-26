//
// Created by Andrey on 11/04/15.
// Copyright (c) 2015 Melatonin LLC. All rights reserved.
//

#import "UINavigationItem+MTi18n.h"

@implementation UINavigationItem (MTi18n)
@dynamic i18nAuto;

-(void)i18nFromNib {
	if ([[self title] length] > 0) {
		[self setTitle: MTi18nString([self title], nil)];
	}

	if ([[self prompt] length] > 0) {
		[self setPrompt: MTi18nString([self prompt], nil)];
	}
}
@end