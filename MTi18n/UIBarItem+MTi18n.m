//
// Created by Andrey on 11/04/15.
// Copyright (c) 2015 Melatonin LLC. All rights reserved.
//

#import "UIBarItem+MTi18n.h"

@implementation UIBarItem (MTi18n)
@dynamic i18nAuto;

-(void)i18nFromNib {
	if ([[self title] length] > 0) {
		[self setTitle: MTi18nString([self title], nil)];
	}
}
@end