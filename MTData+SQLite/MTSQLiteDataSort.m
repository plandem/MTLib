//
// Created by Andrey on 04/06/15.
// Copyright (c) 2015 Melatonin LLC. All rights reserved.
//

#import "MTSQLiteDataSort.h"

@implementation MTSQLiteDataSort
-(NSString *)description {
	if(![self.sorters count]) {
		return nil;
	}

	NSMutableArray  *parts = [NSMutableArray array];
	for(NSSortDescriptor *sort in self.sorters) {
		[parts addObject:(sort.ascending ? [NSString stringWithFormat:@"%@ ASC", sort.key] : [NSString stringWithFormat:@"%@ DESC", sort.key])];
	}

	return [NSString stringWithFormat:@" ORDER BY %@", [parts componentsJoinedByString:@", "]];
}
@end