//
// Created by Andrey on 26/05/15.
// Copyright (c) 2015 Andrey Gayvoronsky. All rights reserved.
//

#import <CoreData/CoreData.h>

@interface NSManagedObjectContext (MTAddons)
/**
* Shorter more unified version of performBlock. if 'async' is NO, then performBlockAndWait is using.
*/
- (void)performBlock:(void (^)())block async:(BOOL)async;

/**
* Save all changes at context of entity with respecting parentContext
*/
- (BOOL)save:(NSError **)error withRoot:(BOOL)withRoot;
@end