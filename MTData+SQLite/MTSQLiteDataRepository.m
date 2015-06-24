//
// Created by Andrey on 03/06/15.
// Copyright (c) 2015 Melatonin LLC. All rights reserved.
//

#import <objc/runtime.h>
#import "MTLogger.h"
#import "MTSQLiteDataRepository.h"
#import "MTSQLitePredicateTransformer.h"
#import "MTSQLiteDataFetchResult.h"
#import "NSObject+MTSQLiteDataObject.h"

const NSString *MTSQLiteDataRepositoryUpdateNotification = @"MTSQLiteDataRepositoryUpdateNotification";

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

-(void)beginTransaction {
	if(![self inTransaction]) {
		[self.db beginTransaction];
	}
}

-(void)commitTransaction {
	[self.db commit];
	[self notifyForChanges];
}

-(void)rollbackTransaction {
	[self.db rollback];
}

-(BOOL)inTransaction {
	return self.db.inTransaction;
}

-(id<MTDataObjectCollection>)fetchAllWithQuery:(MTDataQuery *)query {
	return [[MTSQLiteDataFetchResult alloc] initWithModelClass:self.modelClass withProperties:_modelProperties forQuery:query withDB:self.db];
}

-(void)deleteAllWithQuery:(MTDataQuery *)query {
	FMDatabase *db = self.db;

	[self beginTransaction];

	NSMutableString *sql = [NSMutableString stringWithFormat:@"DELETE FROM %@", [self.modelClass tableName]];
	NSString *condition = [_predicateTransformer transformedValue:query.predicate];
	if(condition) {
		[sql appendFormat:@" WHERE %@", condition];
	}

	[sql appendString:[query.sort description]];
	#if MT_SQLITE_LOG_QUERY
	DDLogDebug(@"%@", sql);
	#endif
	if(![db executeUpdate:sql]) {
		DDLogError(@"Error: %@", [db lastErrorMessage]);
	}

	[self commitTransaction];
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
	BOOL inTransaction = [self inTransaction];

	if(!(inTransaction)) {
		[self beginTransaction];
	}

	NSString *sql = [NSString stringWithFormat:@"DELETE FROM %@ WHERE %@ = ?", [self.modelClass tableName], primaryKeyName];
	#if MT_SQLITE_LOG_QUERY
	DDLogDebug(@"%@", sql);
	#endif
	if(![db executeUpdate:sql, primaryKeyValue]) {
		DDLogError(@"Error: %@", [db lastErrorMessage]);
	}

	if(!(inTransaction)) {
		[self commitTransaction];
	}
}

-(void)saveModel:(id<MTDataObject>)model {
	[self ensureModelType:model];

	NSString *primaryKeyName = [self.modelClass primaryKey];

	FMDatabase *db = self.db;
	BOOL inTransaction = [self inTransaction];

	if(!(inTransaction)) {
		[self beginTransaction];
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
		#if MT_SQLITE_LOG_QUERY
		DDLogDebug(@"%@", sql);
		#endif
		//model has no primaryKey, so INSERT it
		success = [db executeUpdate:sql];
	} else {
		//model has primaryKey, so UPSERT it
		id primaryKeyValue = [(NSObject *)model valueForKey:primaryKeyName];
		[sql appendFormat:@"\nUPDATE %@ SET %@ WHERE changes() == 0 AND %@ = %@;", [model.class tableName], sqlValuesUpdate, primaryKeyName, primaryKeyValue];
		[sql appendFormat:@"\nSELECT CASE changes() WHEN 0 THEN last_insert_rowid() ELSE %@ END AS pk;", primaryKeyValue];
		#if MT_SQLITE_LOG_QUERY
		DDLogDebug(@"%@", sql);
		#endif
		success = [db executeStatements:sql withResultBlock:^int(NSDictionary *dictionary) {
			if(primaryKeyValue == nil) {
				[(NSObject *) model setValue:dictionary[@"pk"] forKey:primaryKeyName];
			}

			return 0;
		}];
	}

	if(!success) {
		DDLogError(@"Error: %@", [db lastErrorMessage]);
	}

	if(!(inTransaction)) {
		[self commitTransaction];
	}
}

-(void)notifyForChanges {
	[[NSNotificationCenter defaultCenter] postNotificationName:(NSString *) MTSQLiteDataRepositoryUpdateNotification object:self.modelClass];
}
@end