//
// Created by Andrey on 11/04/15.
// Copyright (c) 2015 Melatonin LLC. All rights reserved.
//

#import "UISegmentedControl+MTi18n.h"

@implementation UISegmentedControl (MTi18n)
@dynamic i18nAuto;

-(void)i18nFromNib {
	NSString *title;
	for (NSUInteger segment_i = 0, segment_max = [self numberOfSegments]; segment_i < segment_max; segment_i++) {
		title = [self titleForSegmentAtIndex:segment_i];

		if([title length] > 0) {
		 	[self setTitle:MTi18nString(title, nil) forSegmentAtIndex:segment_i];
		}
	}
}
@end