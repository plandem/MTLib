//
// Created by Andrey on 16/06/15.
// Copyright (c) 2015 Melatonin LLC. All rights reserved.
//

#import "MTDataObject.h"
#import "NSObject+MTDataObjectQuery.h"

@implementation NSObject (MTDataObjectQuery)
+(MTDataQuery *)query {
	return (MTDataQuery *)[[[[self class] queryClass] alloc] init];
}
@end