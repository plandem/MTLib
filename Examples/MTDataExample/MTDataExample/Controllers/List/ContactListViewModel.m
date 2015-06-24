//
// Created by Andrey on 23/06/15.
// Copyright (c) 2015 Andrey. All rights reserved.
//

#import <MTLib/MTListViewModel+Cache.h>
#import "ContactListViewModel.h"
#import "ContactProtocol.h"

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
-(NSString *)nameForIndexPath:(NSIndexPath *)indexPath {
	id<ContactProtocol> model = (id <ContactProtocol>)[self modelAtIndexPath:indexPath];
	return model.name;
}

-(NSString *)emailForIndexPath:(NSIndexPath *)indexPath {
	id<ContactProtocol> model = (id <ContactProtocol>)[self modelAtIndexPath:indexPath];
	return model.email;
}
@end