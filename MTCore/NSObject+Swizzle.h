//
// Created by Andrey on 26/04/15.
// Copyright (c) 2015 Melatonin LLC. All rights reserved.
//
// more deep info/implementation at:
// http://blog.newrelic.com/2014/04/16/right-way-to-swizzle/

#import <Foundation/Foundation.h>

@interface NSObject (Swizzle)
+(void)swizzleInstanceSelector:(SEL)originalSelector withNewSelector:(SEL)newSelector;
+(void)swizzleClassSelector:(SEL)originalSelector withNewSelector:(SEL)newSelector;
@end