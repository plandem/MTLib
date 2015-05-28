//
// Created by Andrey on 26/04/15.
// Copyright (c) 2015 Melatonin LLC. All rights reserved.
//

#import "MTTransformerObject.h"

@implementation MTTransformerObject

+ (Class)transformedValueClass {
	return [NSData class];
}

+ (BOOL)allowsReverseTransformation {
	return YES;
}

- (id)transformedValue:(id)value {
	return [NSKeyedArchiver archivedDataWithRootObject:value];
}

- (id)reverseTransformedValue:(id)value {
	return [NSKeyedUnarchiver unarchiveObjectWithData:value];
}
@end