//
// Created by Andrey on 16/06/15.
// Copyright (c) 2015 Melatonin LLC. All rights reserved.
//

#import <MTLib/NSObject+Swizzle.h>
#import "FXFormBaseCell+MTStyleKit.h"

@implementation FXFormBaseCell (MTStyleKit)
+(void)load {
	[self swizzleInstanceSelector:@selector(setField:) withNewSelector:@selector(swizzle_setField:)];
}

#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wundeclared-selector"
-(id<MTStyleKit>)styleKit {
	FXFormController *controller = [self.field performSelector:@selector(formController)];

	if([controller.delegate respondsToSelector:@selector(styleKit)]) {
		return (id<MTStyleKit>)[controller.delegate performSelector:@selector(styleKit)];
	}

	return nil;
}
#pragma clang diagnostic pop

-(void)applyStyles {
	//by default do nothing
}

- (void)swizzle_setField:(FXFormField *)field {
	[self swizzle_setField:field];
	[self applyStyles];
};
@end