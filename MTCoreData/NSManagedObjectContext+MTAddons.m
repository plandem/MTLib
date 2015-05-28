//
// Created by Andrey on 26/05/15.
// Copyright (c) 2015 Andrey Gayvoronsky. All rights reserved.
//

#import "NSManagedObjectContext+MTAddons.h"
#import "MTLogger.h"

@implementation NSManagedObjectContext (MTAddons)
- (void)performBlock:(void (^)())block async:(BOOL)async {
	if(async)
		[self performBlock:block];
	else
		[self performBlockAndWait:block];
}

- (BOOL)save {
	if (![self hasChanges]) {
		return YES;
	}

	__block NSError *error = nil;
	__block BOOL result;

	[self performBlockAndWait:^{
		if (!(result = [self save:&error])) {
			DDLogDebug(@"Saving error: %@", [error userInfo]);

			for (NSError *err in [error userInfo][@"NSDetailedErrors"]) {
				DDLogDebug(@"Error %i: %@", [err code], [err userInfo]);
			}
		}
	}];

	return result;
}

- (BOOL)saveNested {
	if ([self save]) {
		NSManagedObjectContext *context = [self parentContext];

		if (!context) {
			return YES;
		}

		__block BOOL save = NO;

		[context performBlockAndWait:^{
			save = [context saveNested];
		}];

		return save;
	}

	return NO;
}

- (void)saveNestedAsynchronous {
	[self saveNestedAsynchronousWithCallback:nil];
}

- (void)saveNestedAsynchronousWithCallback:(MTCoreDataSaveCompleteBlock)block {
	if ([self save]) {

		NSManagedObjectContext* context = [self parentContext];

		if (context) {
			[context performBlock:^{
				[context saveNestedAsynchronousWithCallback:block];
			}];
		} else if (block) {
			block(YES);
		}
	} else if (block) {
		block(NO);
	}
}
@end