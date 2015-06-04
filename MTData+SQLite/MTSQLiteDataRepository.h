//
// Created by Andrey on 03/06/15.
// Copyright (c) 2015 Melatonin LLC. All rights reserved.
//

#import <FMDB/FMDB.h>
#import "MTDataRepository.h"

@interface MTSQLiteDataRepository : MTDataRepository
@property (nonatomic, readonly) NSString *dbPath;
@property (nonatomic, readonly) NSString *dbName;
@property (nonatomic, readonly) FMDatabase *db;

+(NSString *)defaultDbName;
-(instancetype)initWithModelClass:(Class)modelClass withDB:(NSString *)dbName;
@end