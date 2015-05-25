//
// Created by Andrey on 11/04/15.
// Copyright (c) 2015 Andrey Gayvoronsky. All rights reserved.
//

#import <objc/runtime.h>
#import "NSObject+MTi18n.h"
#import "NSObject+MTSwizzle.h"

@implementation NSObject (MTi18n)
@dynamic i18nAuto;

-(void)i18nFromNib {
}

+ (void)load {
	[self swizzleInstanceSelector:@selector(awakeFromNib) withNewSelector:@selector(swizzle_awakeFromNib)];
}

-(void)swizzle_awakeFromNib {
	[self swizzle_awakeFromNib];

	if([self i18nAuto]) {
		[self i18nFromNib];
	}
}

-(BOOL)i18nAuto {
	NSNumber *flag = objc_getAssociatedObject(self, @selector(i18nAuto));
	return (flag ? [flag boolValue] : (BOOL)MT_LOCALIZATION_AUTO);
}

- (void)setI18nAuto:(BOOL)flag {
	objc_setAssociatedObject(self, @selector(i18nAuto), @(flag), OBJC_ASSOCIATION_COPY_NONATOMIC);
}

@end