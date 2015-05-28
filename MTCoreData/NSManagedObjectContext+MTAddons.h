//
// Created by Andrey on 26/05/15.
// Copyright (c) 2015 Andrey Gayvoronsky. All rights reserved.
//

#import <CoreData/CoreData.h>

typedef void(^MTCoreDataSaveCompleteBlock)(BOOL success);

@interface NSManagedObjectContext (MTAddons)
/**
* Saves the context.
*/
- (BOOL)save;

/**
* Saves the context and all parent contexts asynchronously.
*/
- (void)saveNestedAsynchronous;

/**
* Saves the context and all parent contexts asynchronously.
* @param block callback for when save is complete
*/
- (void)saveNestedAsynchronousWithCallback:(MTCoreDataSaveCompleteBlock)block;

/**
* Saves the context and all parent contexts synchronously.
*/
- (BOOL)saveNested;
@end