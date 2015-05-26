//
// Created by Andrey on 29/04/15.
// Copyright (c) 2015 Melatonin LLC. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface MTDataSort : NSObject
//result info
@property (readonly) NSArray *sorters;

//chaining methods
@property (readonly) MTDataSort *(^asc)(NSString *attribute);
@property (readonly) MTDataSort *(^desc)(NSString *attribute);
@end