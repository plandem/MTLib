//
// Created by Andrey on 29/04/15.
// Copyright (c) 2015 Andrey Gayvoronsky. All rights reserved.
//

#import <Realm/Realm.h>
#import "MTRealmDataSort.h"

@implementation MTRealmDataSort
-(MTDataSort *(^)(NSString *attribute))asc {
	__weak typeof(self) weakSelf = self;
	return ^MTDataSort *(NSString *attribute) {
		[(NSMutableArray *)weakSelf.sorters addObject: [RLMSortDescriptor sortDescriptorWithProperty:attribute ascending:YES]];
		return weakSelf;
	};
}

-(MTDataSort *(^)(NSString *attribute))desc {
	__weak typeof(self) weakSelf = self;
	return ^MTDataSort *(NSString *attribute) {
		[(NSMutableArray *)weakSelf.sorters addObject: [RLMSortDescriptor sortDescriptorWithProperty:attribute ascending:NO]];
		return weakSelf;
	};
}
@end