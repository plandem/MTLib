//
// Created by Andrey on 04/06/15.
// Copyright (c) 2015 Melatonin LLC. All rights reserved.
//

#import "MTSQLiteDataQuery.h"
#import "MTSQLiteDataSort.h"

@implementation MTSQLiteDataQuery
+(Class)sortClass {
	return [MTSQLiteDataSort class];
}
@end