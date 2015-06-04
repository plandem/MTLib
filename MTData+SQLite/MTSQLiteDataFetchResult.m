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
	MTDataQuery *_query;
	FMDatabase *_db;
	FMResultSet *_currentChunk;
	NSUInteger _totalRows;
	Class _modelClass;
	NSUInteger _offset;
	MTSQLitePredicateTransformer *_predicateTransformer;
	NSString *_properties;
}

- (instancetype)initWithModelClass:(Class)modelClass withProperties:(NSArray *)properties forQuery:(MTDataQuery *)query withDB:(FMDatabase *)db {
	if ((self = [super init])) {
		_query = query;
		_properties = (properties && [properties count] ? [properties componentsJoinedByString:@","] : @"*");
		_db = db;
		_totalRows = NSUIntegerMax;
		_modelClass = modelClass;
		_predicateTransformer = [[MTSQLitePredicateTransformer alloc] init];
		_offset = 0;
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

		DDLogDebug(@"%@", sql);
		FMResultSet *resultSet = [_db executeQuery:sql];
		if (resultSet && [resultSet next]) {
			_totalRows =  (NSUInteger)[resultSet intForColumnIndex:0];
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

	NSUInteger minIndex = _offset * _query.batchSize;
	NSUInteger relativeIndex = index - minIndex;

	return ([self fetchChunkForIndex:index]) ? _currentChunk[relativeIndex] : nil;
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

	//TODO: optimize for using stackBuf
	// Refresh stackBuf with objects
	if (countOfItemsAlreadyEnumerated < [self count]) {
		if([self fetchChunkForIndex:countOfItemsAlreadyEnumerated]) {
			// release memory from previous iteration
			if(state->itemsPtr) {
				free(state->itemsPtr);
				state->itemsPtr = nil;
			}

			count = 0;
			NSMutableArray *rows = [NSMutableArray array];
			while([_currentChunk next]) {
				id model = [[_modelClass alloc] init];
				[model setValuesForKeysWithDictionary:[_currentChunk resultDictionary]];
				[rows addObject:model];
				count++;
			}

			if(count) {
				//alloc memory with same size as chunk
				state->itemsPtr = (__typeof__(state->itemsPtr)) malloc(sizeof(id*) * count);

				//copy objects into the C-array
				[rows getObjects:state->itemsPtr];
			}

			countOfItemsAlreadyEnumerated += count;
		}
	}

	state->state = countOfItemsAlreadyEnumerated;

	// if there is no more items to iterate, then we must release memory from previous iteration.
	if(count == 0 && state->itemsPtr) {
		free(state->itemsPtr);
		state->itemsPtr = nil;
	}

	return count;
}

-(BOOL)fetchChunkForIndex:(NSUInteger)index {
	NSUInteger limit = [_query batchSize];
	NSMutableString *sql = [NSMutableString stringWithFormat:@"SELECT %@ FROM %@", _properties, [_modelClass tableName]];
	NSString *condition = [_predicateTransformer transformedValue:_query.predicate];
	if(condition) {
		[sql appendFormat:@" WHERE %@", condition];
	}

	[sql appendString:[_query.sort description]];

	// no limit for fetching?
	if(!limit) {
		if(_currentChunk) {
			return YES;
		}

		DDLogDebug(@"%@", sql);
		_currentChunk = [_db executeQuery:sql];
	} else {
		NSUInteger minIndex = _offset;

		// if index from same chunk, then no need to fetch
		if(index > minIndex && index < minIndex + limit) {
			return YES;
		}

		// looks like index outside of current chunk, let's fetch a new chunk
		_offset =  index;
		[sql appendFormat:@" LIMIT %d OFFSET %d", limit, _offset];
		DDLogDebug(@"%@", sql);
		_currentChunk = [_db executeQuery:sql];
	}

	if(_currentChunk == nil) {
		DDLogError(@"Error: %@", [_db lastErrorMessage]);
		return NO;
	}

	return YES;
}

-(NSString *)description {
	return [NSString stringWithFormat:@"%@ (Total = %d)", [super description], [self count]];
}
@end