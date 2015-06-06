//
// Created by Andrey on 28/05/15.
// Copyright (c) 2015 Melatonin LLC. All rights reserved.
//

#import "MTCoreDataFetchResult.h"
#import "MTLogger.h"

#define INDEX2PAGE(_index) (_totalPages > 0 ? (NSUInteger)ceil((_index) / [_fetchRequest fetchLimit]) : 0)
#define PAGE2INDEX(_page) ((_page) * [_fetchRequest fetchLimit])

@interface MTCoreDataFetchResultEnumerator : NSEnumerator {
	MTCoreDataFetchResult *_result;
	NSUInteger _currentIndex;
}

- (id)initWithEnumerable:(MTCoreDataFetchResult *)result;
@end


@implementation MTCoreDataFetchResultEnumerator
- (id)initWithEnumerable:(MTCoreDataFetchResult *)fetchResult {
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

@implementation MTCoreDataFetchResult {
	NSManagedObjectContext *_context;
	NSFetchRequest *_fetchRequest;
	NSEnumerator *_currentPageData;
	NSUInteger _currentPageNumber;
	NSArray *_retainedModel;
	NSUInteger _totalRows;
	NSUInteger _totalPages;
}

- (instancetype)initWithFetchRequest:(NSFetchRequest *)fetchRequest inContext:(NSManagedObjectContext *)context {
	if ((self = [super init])) {
		_fetchRequest = fetchRequest;
		_context = context;
		_totalRows = NSUIntegerMax;
		_totalPages = NSUIntegerMax;
		_currentPageNumber = 0;
	}

	return self;
}

- (NSUInteger)count {
	if(_totalRows == NSUIntegerMax) {
		__block NSError *error = nil;

		[_context performBlockAndWait:^{
			NSUInteger limit = [_fetchRequest fetchLimit];
			[_fetchRequest setFetchLimit:0];
			_totalRows = [_context countForFetchRequest:_fetchRequest error:&error];
			_totalPages = (limit ? (NSUInteger)ceil(_totalRows / limit) : 0);
			[_fetchRequest setFetchLimit:limit];
		}];

		if(error) {
			DDLogDebug(@"NSManagedObjectContext Error: %@", [error userInfo]);

			NSArray* details = [error userInfo][@"NSDetailedErrors"];
			for (NSError* err in details) {
				DDLogDebug(@"Error %i: %@", [err code], [err userInfo]);
			}
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
	return [[MTCoreDataFetchResultEnumerator alloc] initWithEnumerable:self];
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
			if(_currentPageData == nil) {
				_currentPageData = [_retainedModel objectEnumerator];
			}

			id model;
			while(count < stackBufLength && (model = [_currentPageData nextObject])) {
				stackBuf[count++] = model;
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

	if(_totalPages > 0) {
		NSUInteger offset = PAGE2INDEX(page);
		[_fetchRequest setFetchOffset:offset];
	}

	__block NSError *error = nil;
	[_context performBlockAndWait:^{
		_retainedModel = [_context executeFetchRequest:_fetchRequest error:&error];
		_currentPageData = _retainedModel.objectEnumerator;
		_currentPageNumber = page;
	}];

	if(error) {
		DDLogDebug(@"NSManagedObjectContext Error: %@", [error userInfo]);

		NSArray* details = [error userInfo][@"NSDetailedErrors"];
		for (NSError* err in details) {
			DDLogDebug(@"Error %i: %@", [err code], [err userInfo]);
		}

		return NO;
	}

	return YES;
}

-(NSString *)description {
	return [NSString stringWithFormat:@"%@ (Total = %d)", [super description], [self count]];
}

@end