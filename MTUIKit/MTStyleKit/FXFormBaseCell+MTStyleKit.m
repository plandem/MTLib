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
- (void)swizzle_setField:(FXFormField *)field {
	[self swizzle_setField:field];

	FXFormController *controller = [self.field performSelector:@selector(formController)];

	if ([controller.delegate respondsToSelector:@selector(applyStylesForClass:view:)]) {
		//apply 'general' styles for any fields
		[controller.delegate performSelector:@selector(applyStylesForClass:view:) withObject:[FXFormBaseCell class] withObject:self];

		//apply styles cell's class
		[controller.delegate performSelector:@selector(applyStylesForView:) withObject:self];
	}
};

#pragma clang diagnostic pop
@end