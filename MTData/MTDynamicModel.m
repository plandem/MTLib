//
// Created by Andrey on 13/06/15.
// Copyright (c) 2015 Melatonin LLC. All rights reserved.
//

#import "MTDynamicModel.h"
@interface MTDynamicModel ()
@property (nonatomic, strong) NSMutableDictionary *values;
@end

@implementation MTDynamicModel
- (id)init {
	if((self = [super init])) {
		_values = [NSMutableDictionary dictionary];
	}

	return self;
}

- (id)initWithValues:(NSDictionary *)values {
	NSAssert([values isKindOfClass:[NSDictionary class]], @"Only NSDictionary is allowed as values to init model. Type of values is %@", NSStringFromClass([values class]));

	if((self = [super init])) {
		_values = [values mutableCopy];
	}

	return self;
}

- (id)initWithCoder:(NSCoder *)decoder {
	if ((self = [super init])) {
		_values = [decoder decodeObject];
	}

	return self;
}

- (void)encodeWithCoder:(NSCoder *)encoder {
	[encoder encodeObject:_values];
}

- (void)setValue:(id)value forUndefinedKey:(NSString *)key {
	if (value) {
		_values[key] = value;
	} else {
		[_values removeObjectForKey:key];
	}
}

-(void)setValue:(id)value forKeyPath:(NSString *)keyPath {
	if (value) {
		[_values setValue:value forKeyPath:keyPath];
	} else {
		[self removeObjectForKeyPath:keyPath];
	}
}

- (void)setObject:(id)value forKeyedSubscript:(id <NSCopying>)key {
	if (value) {
		_values[key] = value;
	} else {
		[_values removeObjectForKey:key];
	}
}

-(void)removeObjectForKeyPath:(NSString *)keyPath {
	NSArray *keyPathElements = [keyPath componentsSeparatedByString:@"."];
	NSUInteger numElements = [keyPathElements count];
	if (numElements == 1) {
		[_values removeObjectForKey:keyPath];
	} else {
		NSString *keyPathHead = [[keyPathElements subarrayWithRange:(NSRange){0, numElements - 1}] componentsJoinedByString:@"."];
		NSMutableDictionary *tailContainer = [_values valueForKeyPath:keyPathHead];
		[tailContainer removeObjectForKey:[keyPathElements lastObject]];
	}
}

- (id)valueForUndefinedKey:(NSString *)key {
	return _values[key];
}

- (id)objectForKeyedSubscript:(id)key {
	return _values[key];
}

- (id)valueForKeyPath:(NSString *)keyPath {
	return [_values valueForKeyPath:keyPath];
}

-(NSString *)description {
	return [NSString stringWithFormat:@"%@", _values];
}

-(NSArray *)allKeys {
	return [_values allKeys];
}
@end