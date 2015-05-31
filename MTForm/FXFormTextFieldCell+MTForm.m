//
// Created by Andrey on 23/04/15.
// Copyright (c) 2015 Melatonin LLC. All rights reserved.
//

#import "MTForm.h"
#import "NSObject+Swizzle.h"

@implementation FXFormTextFieldCell (MTForm)
+ (void)load {
	[self swizzleInstanceSelector:@selector(setUp) withNewSelector:@selector(swizzle_setUp)];
}

#pragma clang diagnostic push
#pragma ide diagnostic ignored "InfiniteRecursion"
-(void)swizzle_setUp {
	[self swizzle_setUp];

	self.textField.font = MTFormDetailFont;
}
#pragma clang diagnostic pop
@end