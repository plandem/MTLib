//
// Created by Andrey on 13/06/15.
// Copyright (c) 2015 Melatonin LLC. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface MTDynamicModel : NSObject
@property (nonatomic, readonly, copy) NSArray *allKeys;

- (id)initWithCoder:(NSCoder *)decoder;
- (id)initWithValues:(NSDictionary *)values;
- (void)encodeWithCoder:(NSCoder *)encoder;
- (void)removeObjectForKeyPath:(NSString *)keyPath;
- (id)objectForKeyedSubscript:(id)key;
- (void)setObject:(id)obj forKeyedSubscript:(id <NSCopying>)key;
@end