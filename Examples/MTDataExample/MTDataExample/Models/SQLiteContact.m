//
// Created by Andrey on 23/06/15.
// Copyright (c) 2015 Andrey. All rights reserved.
//

#import <MTLib/NSObject+MTSQLiteDataObject.h>
#import "SQLiteContact.h"

@implementation SQLiteContact
+(NSString *)primaryKey {
	return @"id";
}
@end