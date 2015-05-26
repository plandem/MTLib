//
// Created by Andrey on 26/05/15.
// Copyright (c) 2015 Melatonin LLC. All rights reserved.
//
// Based on: http://robots.thoughtbot.com/core-data
//

#import <CoreData/CoreData.h>

@interface MTCoreDataStack : NSObject

@property (nonatomic, readonly, strong) NSPersistentStoreCoordinator *persistentStoreCoordinator;
@property (nonatomic, readonly, strong) NSManagedObjectModel *managedObjectModel;

+ (instancetype)defaultStack;
+ (instancetype)defaultStackWithModel:(NSString *)modelFileName;
+ (instancetype)inMemoryStack;
+ (instancetype)inMemoryStackWithModel:(NSString *)modelFileName;
@end