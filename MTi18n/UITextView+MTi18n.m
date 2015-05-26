//
// Created by Andrey on 11/04/15.
// Copyright (c) 2015 Melatonin LLC. All rights reserved.
//

#import "UITextView+MTi18n.h"

@implementation UITextView (MTi18n)
@dynamic i18nAuto;

-(void)i18nFromNib {
	if ([[self text] length] > 0) {
		[self setText: MTi18nString([self text], nil)];
	}
}
@end