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
	NSAssert([values isKindOfClass:[NSDictionary class]], @"Only NSDictionary is allowed as values to init model.");

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
	[_values setValue:value forKeyPath:keyPath];
}

- (id)valueForUndefinedKey:(NSString *)key {
	return _values[key];
}

- (id)valueForKeyPath:(NSString *)keyPath {
	return [_values valueForKeyPath:keyPath];
}

-(NSString *)description {
	return [NSString stringWithFormat:@"%@", _values];
}
@end