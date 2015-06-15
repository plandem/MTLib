//
// Created by Andrey on 16/06/15.
// Copyright (c) 2015 Melatonin LLC. All rights reserved.
//

#import "MTDataQuery.h"

@interface NSObject (MTDataObjectQuery) <MTDataObject>
+(MTDataQuery *)query;
@end