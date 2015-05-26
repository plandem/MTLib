//
// Created by Andrey on 26/05/15.
// Copyright (c) 2015 Melatonin LLC. All rights reserved.
//

#import <CoreData/CoreData.h>
#import "MTCoreDataStack.h"

//@interface NSManagedObject (SimpleAddons)
/**
* Creates a new entity in privateQueueContext
*/
//+ (instancetype)createEntity;
//@end

@interface MTCoreDataStackSimple : MTCoreDataStack
+ (NSManagedObjectContext *)mainQueueContext;
+ (NSManagedObjectContext *)newMainQueueContext;
+ (NSManagedObjectContext *)privateQueueContext;
@end
