//
// Created by Andrey on 03/06/15.
// Copyright (c) 2015 Melatonin LLC. All rights reserved.
//

#import <objc/runtime.h>
#import "MTLogger.h"
#import "MTSQLiteDataRepository.h"
#import "MTSQLitePredicateTransformer.h"
#import "NSObject+MTSQLiteDataObject.h"
#import "MTSQLiteDataFetchResult.h"

@interface MTSQLiteDataRepository()
@property (nonatomic, strong) NSString *dbPath;
@property (nonatomic, strong) NSString *dbName;
@property (nonatomic, strong) FMDatabase *db;
@property (nonatomic, strong) MTSQLitePredicateTransformer *predicateTransformer;
@property (nonatomic, strong) NSMutableArray *modelProperties;
@end

@implementation MTSQLiteDataRepository
-(instancetype)initWithModelClass:(Class)modelClass {
	return [self initWithModelClass:modelClass withDB:[MTSQLiteDataRepository defaultDbName]];
}

-(instancetype)initWithModelClass:(Class)modelClass withDB:(NSString *)dbName {
	if((self = [super initWithModelClass:modelClass])) {
		_dbName = dbName;
		_dbPath = [NSString stringWithFormat:@"%@.sqlite", [MTSQLiteDataRepository writablePathForFile:_dbName]];
		_db = [FMDatabase databaseWithPath:_dbPath];
		_db.logsErrors = YES;
		_db.crashOnErrors = YES;
		_predicateTransformer = [[MTSQLitePredicateTransformer alloc] init];

		//get properties of model
		_modelProperties = [NSMutableArray array];
		NSMutableArray *ignoredProperties = [NSMutableArray arrayWithArray:[self.modelClass ignoredProperties]];
		[ignoredProperties addObjectsFromArray:@[@"hash", @"superclass", @"description", @"debugDescription"]];

		NSUInteger numberOfProperties = 0;
		objc_property_t *propertyArray = class_copyPropertyList(self.modelClass, &numberOfProperties);

		for (NSUInteger i = 0; i < numberOfProperties; i++) {
			objc_property_t property = propertyArray[i];
			NSString *name = [[NSString alloc] initWithUTF8String:property_getName(property)];
			if([ignoredProperties indexOfObject:name] == NSNotFound) {
				[_modelProperties addObject:name];
			}
		} //for(prop_i)

		free(propertyArray);
	}

	return self;
}

-(void)dealloc {
	[_db close];
}

+(NSString *)writablePathForFile:(NSString *)fileName {
#if TARGET_OS_IPHONE
	// On iOS the Documents directory isn't user-visible, so put files there
	NSString *path = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES)[0];
#else
    // On OS X it is, so put files in Application Support. If we aren't running
    // in a sandbox, put it in a subdirectory based on the bundle identifier
    // to avoid accidentally sharing files between applications
    NSString *path = NSSearchPathForDirectoriesInDomains(NSApplicationSupportDirectory, NSUserDomainMask, YES)[0];
    if (![[NSProcessInfo processInfo] environment][@"APP_SANDBOX_CONTAINER_ID"]) {
        NSString *identifier = [[NSBundle mainBundle] bundleIdentifier];
        if ([identifier length] == 0) {
            identifier = [[[NSBundle mainBundle] executablePath] lastPathComponent];
        }
        path = [path stringByAppendingPathComponent:identifier];

        // create directory
        [[NSFileManager defaultManager] createDirectoryAtPath:path
                                  withIntermediateDirectories:YES
                                                   attributes:nil
                                                        error:nil];
#endif

	return [path stringByAppendingPathComponent:fileName];
}

+(NSString *)defaultDbName {
	static NSString *defaultName = nil;
	static dispatch_once_t onceToken;
	dispatch_once(&onceToken, ^{
		defaultName = [[NSBundle mainBundle] objectForInfoDictionaryKey:@"CFBundleName"];
	});

	return defaultName;
}

-(FMDatabase *)db {
	NSAssert([_db open], @"Can't open connection to database.");
	return _db;
}

-(void)withTransaction:(MTDataRepositoryTransactionBlock)transactionBlock {
	FMDatabase *db = self.db;

	@try {
		[db beginTransaction];
		transactionBlock(self);
		[db commit];
	} @catch(NSException *e) {
		[db rollback];
	}
}

-(id<MTDataObjectCollection>)fetchAllWithQuery:(MTDataQuery *)query {
	return [[MTSQLiteDataFetchResult alloc] initWithModelClass:self.modelClass withProperties:_modelProperties forQuery:query withDB:self.db];
}

-(void)deleteAllWithQuery:(MTDataQuery *)query {
	FMDatabase *db = self.db;

	[db beginTransaction];

	NSMutableString *sql = [NSMutableString stringWithFormat:@"DELETE FROM %@", [self.modelClass tableName]];
	NSString *condition = [_predicateTransformer transformedValue:query.predicate];
	if(condition) {
		[sql appendFormat:@" WHERE %@", condition];
	}

	[sql appendString:[query.sort description]];
	if(![db executeUpdate:sql]) {
		DDLogError(@"Error: %@", [db lastErrorMessage]);
	}

	[db commit];
}

-(void)undoModel:(id<MTDataObject>)model {
	//do nothing. In SQLite we can ignore any changes - just don't save it.
}

-(void)deleteModel:(id<MTDataObject>)model {
	[self ensureModelType:model];

	NSString *primaryKeyName = [self.modelClass primaryKey];
	if(primaryKeyName == nil) {
		DDLogError(@"Model %@ has no primary key. You can't delete models without primary keys.", NSStringFromClass(self.modelClass));
		return;
	}

	id primaryKeyValue = [(NSObject *)model valueForKey:primaryKeyName];
	if(primaryKeyValue == nil || [primaryKeyValue isEqual:[NSNull null]]) {
		//no need to delete model that was not saved yet
		return;
	}

	FMDatabase *db = self.db;
	BOOL inTransaction = db.inTransaction;

	if(!(inTransaction)) {
		[db beginTransaction];
	}

	if(![db executeUpdate:[NSString stringWithFormat:@"DELETE FROM %@ WHERE %@ = ?", [self.modelClass tableName], primaryKeyName], primaryKeyValue]) {
		DDLogError(@"Error: %@", [db lastErrorMessage]);
	}

	if(!(inTransaction)) {
		[db commit];
	}
}

-(void)saveModel:(id<MTDataObject>)model {
	[self ensureModelType:model];

	NSString *primaryKeyName = [self.modelClass primaryKey];

	FMDatabase *db = self.db;
	BOOL inTransaction = db.inTransaction;

	if(!(inTransaction)) {
		[db beginTransaction];
	}

	// prepare args
	NSMutableString *sqlValuesInsert = [NSMutableString string];
	NSMutableString *sqlValuesUpdate = [NSMutableString string];

	id value;
	for(NSString *propertyName in _modelProperties) {
		value = [(NSObject *)model valueForKey:propertyName];
		if(value == nil) {
			value = @"NULL";
		} else {
			if([value isKindOfClass:[NSNumber class]] && CFNumberIsFloatType((__bridge CFNumberRef)value)) {
				value = [value description];
			} else if([value isKindOfClass:[NSDate class]]) {
				if([db hasDateFormatter]) {
					value = [db stringFromDate:value];
				} else {
					value = @([(NSDate *)value timeIntervalSince1970]);
				}
			}

			if([value isKindOfClass:[NSString class]]) {
				value = [NSString stringWithFormat:@"'%@'", [value stringByReplacingOccurrencesOfString:@"'" withString:@"\\'"]];
			} else {
				value = [value description];
			}
		}

		[sqlValuesInsert appendFormat:@"%@,", value];
		[sqlValuesUpdate appendFormat:@"%@ = %@,", propertyName, value];
	}

	[sqlValuesInsert deleteCharactersInRange:NSMakeRange([sqlValuesInsert length] - 1, 1)];
	[sqlValuesUpdate deleteCharactersInRange:NSMakeRange([sqlValuesUpdate length] - 1, 1)];

	BOOL success;
	NSMutableString *sql = [NSMutableString stringWithFormat:@"INSERT OR IGNORE INTO %@ (%@) VALUES(%@);", [model.class tableName], [_modelProperties componentsJoinedByString:@","], sqlValuesInsert];
	if(primaryKeyName == nil) {
		//model has no primaryKey, so just INSERT it
		success = [db executeUpdate:sql];
	} else {
		//model has primaryKey, so UPSERT it
		id primaryKeyValue = [(NSObject *)model valueForKey:primaryKeyName];
		[sql appendFormat:@"UPDATE %@ SET %@ WHERE changes() == 0 AND %@ = %@;", [model.class tableName], sqlValuesUpdate, primaryKeyName, primaryKeyValue];
		[sql appendFormat:@"SELECT CASE changes() WHEN 0 THEN last_insert_rowid() ELSE %@ END AS pk;", primaryKeyValue];
		success = [db executeStatements:sql withResultBlock:^int(NSDictionary *dictionary) {
			[(NSObject *) model setValue:dictionary[@"pk"] forKey:primaryKeyName];
			return 0;
		}];
	}

	if(!success) {
		DDLogError(@"Error: %@", [db lastErrorMessage]);
	}

	if(!(inTransaction)) {
		[db commit];
	}
}
@end