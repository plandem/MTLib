//
// Created by Andrey on 28/05/15.
// Copyright (c) 2015 Melatonin LLC. All rights reserved.
//

#import "MTCoreDataFetchResult.h"
#import "MTLogger.h"

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
	NSFetchRequest *_fetchRequest;
	NSManagedObjectContext *_context;
	NSArray *_currentChunk;
}

- (instancetype)initWithFetchRequest:(NSFetchRequest *)fetchRequest inContext:(NSManagedObjectContext *)context {
	if ((self = [super init])) {
		_fetchRequest = fetchRequest;
		_context = context;
	}

	return self;
}

- (NSUInteger)count {
	static NSUInteger total = 0;
	static dispatch_once_t onceToken;
	dispatch_once(&onceToken, ^{
		NSError *error = nil;

		NSUInteger limit = [_fetchRequest fetchLimit];

		[_fetchRequest setFetchLimit:0];
		total = [_context countForFetchRequest:_fetchRequest error:&error];
		[_fetchRequest setFetchLimit:limit];

		if(error) {
			DDLogDebug(@"NSManagedObjectContext Error: %@", [error userInfo]);

			NSArray* details = [error userInfo][@"NSDetailedErrors"];
			for (NSError* err in details) {
				DDLogDebug(@"Error %i: %@", [err code], [err userInfo]);
			}
		}
	});

	return total;
}

- (id)objectAtIndex:(NSUInteger)index {
	return [self objectAtIndexedSubscript:index];
}

- (id)objectAtIndexedSubscript:(NSUInteger)index {
	if(index >= [self count]) {
		[NSException raise:NSRangeException format:@"Index %d is beyond bounds [0, %d].", index, [self count]];
	}

	NSUInteger minIndex = _fetchRequest.fetchOffset * _fetchRequest.fetchLimit;
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
		if([self fetchChunkForIndex:countOfItemsAlreadyEnumerated]) {
			//TODO: replace malloc with using stackBuf array and internal pointer inside of current chunk
			state->itemsPtr = (__typeof__(state->itemsPtr))malloc(sizeof(id *) * [_currentChunk count]);
			[_currentChunk getObjects:state->itemsPtr];
			count = [_currentChunk count];
			countOfItemsAlreadyEnumerated = _fetchRequest.fetchLimit * _fetchRequest.fetchOffset + [_currentChunk count];
		}
    }

	state->state = countOfItemsAlreadyEnumerated;
	return count;
}

-(BOOL)fetchChunkForIndex:(NSUInteger)index {
	NSError *error = nil;

	NSUInteger limit = [_fetchRequest fetchLimit];

	// no limit for fetching?
	if(!limit) {
		_currentChunk = [_context executeFetchRequest:_fetchRequest error:&error];
	} else {
		NSUInteger minIndex = _fetchRequest.fetchOffset;

		// if index from same chunk, then no need to fetch
		if(index > minIndex && index < minIndex + limit) {
			return YES;
		}

		// looks like index outside of current chunk, let's fetch new chunk
		[_fetchRequest setFetchOffset:index];
		_currentChunk = [_context executeFetchRequest:_fetchRequest error:&error];
	}

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

@end