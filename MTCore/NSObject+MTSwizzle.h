//
// Created by Andrey Gayvoronsky on 7/29/14.
// Copyright (c) 2014 Andrey Gayvoronsky. All rights reserved.
//
//
// more deep info/implementation at:
// http://blog.newrelic.com/2014/04/16/right-way-to-swizzle/

#import <Foundation/Foundation.h>

@interface NSObject (MTSwizzle)
+(void)swizzleInstanceSelector:(SEL)originalSelector withNewSelector:(SEL)newSelector;
+(void)swizzleClassSelector:(SEL)originalSelector withNewSelector:(SEL)newSelector;
@end