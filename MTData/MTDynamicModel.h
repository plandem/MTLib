//
// Created by Andrey on 13/06/15.
// Copyright (c) 2015 Melatonin LLC. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface MTDynamicModel : NSObject
- (id)initWithCoder:(NSCoder *)decoder;
- (id)initWithValues:(NSDictionary *)values;
- (void)encodeWithCoder:(NSCoder *)encoder;
@end