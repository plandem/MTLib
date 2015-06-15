//
// Created by Andrey on 03/06/15.
// Copyright (c) 2015 Melatonin LLC. All rights reserved.
//

#import "NSObject+MTSQLiteDataObject.h"
#import "NSObject+MTDataObjectQuery.h"
#import "MTSQLiteDataRepository.h"
#import "MTSQLiteDataProvider.h"
#import "MTSQLiteDataQuery.h"

@implementation NSObject (MTSQLiteDataObject)
+(Class)repositoryClass {
	return [MTSQLiteDataRepository class];
}

+(Class)dataProviderClass {
	return [MTSQLiteDataProvider class];
}

+(Class)queryClass {
	return [MTSQLiteDataQuery class];
}

+(NSString *)tableName {
	return NSStringFromClass([self class]);
}

+(NSString *)primaryKey {
	return nil;
}

+(NSArray *)ignoredProperties {
	return nil;
}
@end