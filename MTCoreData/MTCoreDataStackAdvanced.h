//
// Created by Andrey on 26/05/15.
// Copyright (c) 2015 Melatonin LLC. All rights reserved.
//

#import <CoreData/CoreData.h>
#import "MTCoreDataStack.h"

@interface MTCoreDataStackAdvanced : MTCoreDataStack
+ (NSManagedObjectContext *)defaultPrivateQueueContext;
+ (NSManagedObjectContext *)newMainQueueContext;
+ (NSManagedObjectContext *)newPrivateQueueContext;
@end
