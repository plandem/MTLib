//
// Created by Andrey on 03/06/15.
// Copyright (c) 2015 Melatonin LLC. All rights reserved.
//

#import "MTDataObject.h"

@interface NSObject (MTSQLiteDataObject) <MTDataObject>
+(NSString *)tableName;
+(NSString *)primaryKey;
+(NSArray *)ignoredProperties;
@end