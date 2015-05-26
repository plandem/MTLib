//
// Created by Andrey on 23/04/15.
// Copyright (c) 2015 Melatonin LLC. All rights reserved.
//

#import "MTForm.h"
#import "NSObject+MTSwizzle.h"

@implementation FXFormDefaultCell (MTForm)
+ (void)load {
	[self swizzleInstanceSelector:@selector(update) withNewSelector:@selector(swizzle_update)];
}

#pragma clang diagnostic push
#pragma ide diagnostic ignored "InfiniteRecursion"
-(void)swizzle_update {
	[self swizzle_update];

	if(self.textLabel.textAlignment == NSTextAlignmentCenter) {
		self.indentationLevel = 0;
	}
}
#pragma clang diagnostic pop
@end