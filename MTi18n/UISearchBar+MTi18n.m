//
// Created by Andrey on 11/04/15.
// Copyright (c) 2015 Melatonin LLC. All rights reserved.
//

#import "UISearchBar+MTi18n.h"

@implementation UISearchBar (MTi18n)
@dynamic i18nAuto;

-(void)i18nFromNib {
	if ([[self text] length] > 0) {
		[self setText: MTi18nString([self text], nil)];
	}

	if ([[self prompt] length] > 0) {
		[self setPrompt: MTi18nString([self prompt], nil)];
	}

	if ([[self placeholder] length] > 0) {
		[self setPlaceholder: MTi18nString([self placeholder], nil)];
	}
}
@end