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

- (BOOL)save:(NSError **)error withRoot:(BOOL)withRoot {
	NSManagedObjectContext *context = self;

	__block NSError *err;
	do {
		[context performBlock:^{
			if(!([context save:&err]))
				DDLogError(@"*** Saving error %@", err.localizedDescription);
		} async:NO];

		//move to parent context
		context = context.parentContext;
	} while(withRoot && context && err == nil);

	if(error)
		*error = [err copy];

	return (err == nil);
}
@end