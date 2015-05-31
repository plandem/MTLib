//
// Created by Andrey on 28/05/15.
// Copyright (c) 2015 Andrey Gayvoronsky. All rights reserved.
//

#import "MTRealmDataQuery.h"
#import "MTRealmDataSort.h"

@implementation MTRealmDataQuery
+(Class)sortClass {
	return [MTRealmDataSort class];
}
@end