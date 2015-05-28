//
// Created by Andrey on 29/04/15.
// Copyright (c) 2015 Melatonin LLC. All rights reserved.
//

#import <libextobjc/extobjc.h>
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
	@weakify(self);
	return ^MTDataSort *(NSString *attribute) {
		@strongify(self);
		[(NSMutableArray *)self.sorters addObject: [NSSortDescriptor sortDescriptorWithKey:attribute ascending:YES]];
		return self;
	};
}

-(MTDataSort *(^)(NSString *attribute))desc {
	@weakify(self);
	return ^MTDataSort *(NSString *attribute) {
		@strongify(self);
		[(NSMutableArray *)self.sorters addObject: [NSSortDescriptor sortDescriptorWithKey:attribute ascending:NO]];
		return self;
	};
}

@end