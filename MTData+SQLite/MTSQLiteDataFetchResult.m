//
// Created by Andrey on 04/06/15.
// Copyright (c) 2015 Melatonin LLC. All rights reserved.
//

#import <FMDB/FMDatabase.h>
#import "MTLogger.h"
#import "MTDataQuery.h"
#import "MTSQLiteDataFetchResult.h"
#import "MTSQLitePredicateTransformer.h"
#import "NSObject+MTSQLiteDataObject.h"

#define INDEX2PAGE(_index) (_totalPages > 0 ? (NSUInteger)ceil((_index) / [_query batchSize]) : 0)
#define PAGE2INDEX(_page) ((_page) * [_query batchSize])

@interface MTSQLiteDataFetchResultEnumerator : NSEnumerator {
	MTSQLiteDataFetchResult *_result;
	NSUInteger _currentIndex;
}

- (id)initWithEnumerable:(MTSQLiteDataFetchResult *)result;
@end

@implementation MTSQLiteDataFetchResultEnumerator
- (id)initWithEnumerable:(MTSQLiteDataFetchResult *)fetchResult {
	self = [super init];

	if (self) {
		_result = fetchResult;
		_currentIndex = 0;
	}

	return self;
}

- (id)nextObject {
	if (_currentIndex >= [_result count]) {
		return nil;
	}

	return _result[_currentIndex++];
}
@end

@implementation MTSQLiteDataFetchResult {
	Class _modelClass;
	MTDataQuery *_query;
	FMDatabase *_db;
	FMResultSet *_currentPageData;
	NSUInteger _currentPageNumber;
	NSMutableArray *_retainedModel;

	NSUInteger _totalRows;
	NSUInteger _totalPages;
	MTSQLitePredicateTransformer *_predicateTransformer;
	NSString *_properties;
}

- (instancetype)initWithModelClass:(Class)modelClass withProperties:(NSArray *)properties forQuery:(MTDataQuery *)query withDB:(FMDatabase *)db {
	if ((self = [super init])) {
		_query = query;
		_properties = (properties && [properties count] ? [properties componentsJoinedByString:@","] : @"*");
		_db = db;
		_modelClass = modelClass;
		_predicateTransformer = [[MTSQLitePredicateTransformer alloc] init];
		_retainedModel = [NSMutableArray array];
		_totalRows = NSUIntegerMax;
		_totalPages = NSUIntegerMax;
		_currentPageNumber = 0;
	}

	return self;
}

- (NSUInteger)count {
	if(_totalRows == NSUIntegerMax) {
		NSMutableString *sql = [NSMutableString stringWithFormat:@"SELECT COUNT(*) FROM %@", [_modelClass tableName]];
		NSString *condition = [_predicateTransformer transformedValue:_query.predicate];
		if(condition) {
			[sql appendFormat:@" WHERE %@", condition];
		}

		#if MT_SQLITE_LOG_QUERY
		DDLogDebug(@"%@", sql);
		#endif

		FMResultSet *resultSet = [_db executeQuery:sql];
		if (resultSet && [resultSet next]) {
			_totalRows =  (NSUInteger)[resultSet intForColumnIndex:0];
			_totalPages = ([_query batchSize] ? (NSUInteger)ceil(_totalRows / [_query batchSize]) : 0);
		} else {
			DDLogError(@"Error: %@", [_db lastErrorMessage]);
		}
	}

	return _totalRows;
}

- (id)objectAtIndex:(NSUInteger)index {
	return [self objectAtIndexedSubscript:index];
}

- (id)objectAtIndexedSubscript:(NSUInteger)index {
	if(index >= [self count]) {
		[NSException raise:NSRangeException format:@"Index %d is beyond bounds [0, %d].", index, [self count]];
	}

	NSUInteger page = INDEX2PAGE(index);
	if([self fetchPage:page]) {
		index -= PAGE2INDEX(page);

		NSUInteger totalRetained = [_retainedModel count];
		if(index >= totalRetained) {
			for(NSUInteger i = totalRetained; i <= index; i++) {
				if([_currentPageData next]) {
					[self populateAndRetain];
				}
			}
		}

		return _retainedModel[index];
	}

	return nil;
}

- (void)enumerateObjectsUsingBlock:(void (^)(id object, NSUInteger index, BOOL *stop))block {
	BOOL stop = NO;

	for(NSUInteger i = 0, i_max = [self count]; i < i_max; i++) {
		block([self objectAtIndexedSubscript:i], i, &stop);

		if (stop) {
			break;
		}
	}
}

- (NSEnumerator *)objectEnumerator {
	return [[MTSQLiteDataFetchResultEnumerator alloc] initWithEnumerable:self];
}

-(id) populateAndRetain {
	id model = [[_modelClass alloc] init];
	[model setValuesForKeysWithDictionary:[_currentPageData resultDictionary]];
	[_retainedModel addObject:model];
	return model;
}

- (NSUInteger)countByEnumeratingWithState:(NSFastEnumerationState *)state  objects:(id __unsafe_unretained [])stackBuf count:(NSUInteger)stackBufLength {
	// count = 0 - is signal that there no more items to iterate.
	NSUInteger count = 0;

	// We use state->state to track how far we have enumerated through _list
	// between successive invocations of -countByEnumeratingWithState:objects:count:
	unsigned long countOfItemsAlreadyEnumerated = state->state;

	// This is the initialization condition, so we'll do one-time setup here.
	// Ensure that you never set state->state back to 0, or use another method to
	// detect initialization (such as using one of the values of state->extra).
	if(countOfItemsAlreadyEnumerated == 0) {
		// We are not tracking mutations, so we'll set state->mutationsPtr to point
		// into one of our extra values, since these values are not otherwise used
		// by the protocol.
		// If your class was mutable, you may choose to use an internal variable that
		// is updated when the class is mutated.
		// state->mutationsPtr MUST NOT be NULL and SHOULD NOT be set to self.
		state->mutationsPtr = &state->extra[0];
	}

	// Refresh stackBuf with objects
	if (countOfItemsAlreadyEnumerated < [self count]) {
		NSUInteger page = INDEX2PAGE(countOfItemsAlreadyEnumerated);
		if([self fetchPage:page]) {
			while(count < stackBufLength && [_currentPageData next]) {
				stackBuf[count++] = [self populateAndRetain];
			}

			countOfItemsAlreadyEnumerated += count;
		}
	}

	//if all data retrieved, then rewind to begin
	if (countOfItemsAlreadyEnumerated >= [self count]) {
		_currentPageData = nil;
	}

	state->state = countOfItemsAlreadyEnumerated;
	state->itemsPtr = stackBuf;

	return count;
}

-(BOOL)fetchPage:(NSUInteger)page {
	if(page == _currentPageNumber && _currentPageData) {
		return YES;
	}

	NSMutableString *sql = [NSMutableString stringWithFormat:@"SELECT %@ FROM %@", _properties, [_modelClass tableName]];
	NSString *condition = [_predicateTransformer transformedValue:_query.predicate];
	if(condition) {
		[sql appendFormat:@" WHERE %@", condition];
	}

	[sql appendString:[_query.sort description]];

	if(_totalPages > 0) {
		NSUInteger offset = PAGE2INDEX(page);
		[sql appendFormat:@" LIMIT %d", [_query batchSize]];

		if(offset) {
			[sql appendFormat:@" OFFSET %d", offset];
		}
	}

	#if MT_SQLITE_LOG_QUERY
	DDLogDebug(@"%@", sql);
	#endif

	[_retainedModel removeAllObjects];
	_currentPageData = [_db executeQuery:sql];
	_currentPageNumber = page;
	if(_currentPageData == nil) {
		DDLogError(@"Error: %@", [_db lastErrorMessage]);
		return NO;
	}

	return YES;
}

-(NSString *)description {
	return [NSString stringWithFormat:@"%@ (Total = %d)", [super description], [self count]];
}
@end