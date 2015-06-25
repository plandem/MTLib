//
// Created by Andrey on 23/06/15.
// Copyright (c) 2015 Andrey. All rights reserved.
//

#import "ContactListViewModel.h"

@implementation ContactListViewModel
-(id)initWithRepository:(MTDataRepository *)repository {
	if ((self = [super initWithRepository:repository])) {

		[self.dataProvider makeQuery:^(MTDataQuery *query, MTDataSort *sort) {
			query.condition(@"%K = %d", @"banned", NO);
			sort.asc(@"name");
		}];
	}

	return self;
}

@end