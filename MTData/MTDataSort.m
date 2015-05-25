//
// Created by Andrey on 29/04/15.
// Copyright (c) 2015 Andrey Gayvoronsky. All rights reserved.
//

#import "MTDataSort.h"
@interface MTDataSort()
@property (nonatomic, strong) NSArray *sort;
@end

@implementation MTDataSort
-(instancetype)init {
	if((self = [super init])) {
		_sorters = [NSMutableArray array];
	}

	return self;
}

-(MTDataSort *(^)(NSString *attribute))asc {
	__weak typeof(self) weakSelf = self;
	return ^MTDataSort *(NSString *attribute) {
		[(NSMutableArray *)weakSelf.sorters addObject: [NSSortDescriptor sortDescriptorWithKey:attribute ascending:YES]];
		return weakSelf;
	};
}

-(MTDataSort *(^)(NSString *attribute))desc {
	__weak typeof(self) weakSelf = self;
	return ^MTDataSort *(NSString *attribute) {
		[(NSMutableArray *)weakSelf.sorters addObject: [NSSortDescriptor sortDescriptorWithKey:attribute ascending:NO]];
		return weakSelf;
	};
}

@end