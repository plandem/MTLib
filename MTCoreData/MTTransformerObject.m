//
// Created by Andrey Gayvoronsky on 6/13/14.
// Copyright (c) 2014 Andrey Gayvoronsky. All rights reserved.
//

#import "MTTransformerObject.h"

@implementation MTTransformerObject

+(Class)transformedValueClass {
	return [NSData class];
}

+(BOOL) allowsReverseTransformation {
	return YES;
}

-(id)transformedValue:(id) value {
	return [NSKeyedArchiver archivedDataWithRootObject:value];
}

-(id)reverseTransformedValue:(id) value {
	return [NSKeyedUnarchiver unarchiveObjectWithData:value];
}
@end