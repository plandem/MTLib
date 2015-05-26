//
// Created by Andrey on 26/05/15.
// Copyright (c) 2015 Melatonin LLC. All rights reserved.
//

#import "MTCoreDataStackAdvanced.h"

@interface MTCoreDataStackAdvanced ()
@property (strong, nonatomic) NSManagedObjectContext *defaultPrivateQueueContext;
@end

@implementation MTCoreDataStackAdvanced

+ (NSManagedObjectContext *)newMainQueueContext {
    NSManagedObjectContext *context = [[NSManagedObjectContext alloc] initWithConcurrencyType:NSMainQueueConcurrencyType];
    context.parentContext = [self defaultPrivateQueueContext];
    return context;
}

+ (NSManagedObjectContext *)newPrivateQueueContext {
    NSManagedObjectContext *context = [[NSManagedObjectContext alloc] initWithConcurrencyType:NSPrivateQueueConcurrencyType];
    context.parentContext = [self defaultPrivateQueueContext];
    return context;
}

+ (NSManagedObjectContext *)defaultPrivateQueueContext {
    return [[self defaultStack] defaultPrivateQueueContext];
}

- (NSManagedObjectContext *)defaultPrivateQueueContext {
    if (!_defaultPrivateQueueContext) {
        _defaultPrivateQueueContext = [[NSManagedObjectContext alloc] initWithConcurrencyType:NSPrivateQueueConcurrencyType];
        _defaultPrivateQueueContext.persistentStoreCoordinator = self.persistentStoreCoordinator;
    }

    return _defaultPrivateQueueContext;
}

@end
