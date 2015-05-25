//
// Created by Andrey on 29/04/15.
// Copyright (c) 2015 Andrey Gayvoronsky. All rights reserved.
//

#import "MTRealmDataSort.h"
#import <Realm/Realm.h>

@implementation MTRealmDataSort
-(MTDataSort *(^)(NSString *attribute))asc {
	@weakify(self);
	return ^MTDataSort *(NSString *attribute) {
		@strongify(self);
		[(NSMutableArray *)self.sorters addObject: [RLMSortDescriptor sortDescriptorWithProperty:attribute ascending:YES]];
		return self;
	};
}

-(MTDataSort *(^)(NSString *attribute))desc {
	@weakify(self);
	return ^MTDataSort *(NSString *attribute) {
		@strongify(self);
		[(NSMutableArray *)self.sorters addObject: [RLMSortDescriptor sortDescriptorWithProperty:attribute ascending:NO]];
		return self;
	};
}
@end