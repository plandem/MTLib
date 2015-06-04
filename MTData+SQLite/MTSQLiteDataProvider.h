//
// Created by Andrey on 03/06/15.
// Copyright (c) 2015 Melatonin LLC. All rights reserved.
//

#import "MTDataProvider.h"

@interface MTSQLiteDataProvider : MTDataProvider
-(instancetype)initWithModelClass:(Class)modelClass withDB:(NSString *)dbName;
@end