//
// Created by Andrey on 26/05/15.
// Copyright (c) 2015 Andrey Gayvoronsky. All rights reserved.
//

#import <CoreData/CoreData.h>
#import "MTDataQuery.h"

@interface MTCoreDataQuery : MTDataQuery
// result info
//@property (readonly) NSArray *withList;
//@property (readonly) NSArray *groupList;

//chaining properties
//@property (readonly) MTDataQuery *(^with)(NSString *relation);
//@property (readonly) MTDataQuery *(^group)(NSString *attribute);
@end