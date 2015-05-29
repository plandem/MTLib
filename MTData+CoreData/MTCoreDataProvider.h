//
// Created by Andrey on 26/05/15.
// Copyright (c) 2015 Andrey Gayvoronsky. All rights reserved.
//

#import <CoreData/CoreData.h>
#import "MTDataProvider.h"

typedef NS_OPTIONS(NSUInteger, MTCoreDataProviderOptions) {
	MTCoreDataProviderOptionNone			= 0,
	MTCoreDataProviderOptionWatchContext	= 1 << 0,
	MTCoreDataProviderOptionWatchStore		= 1 << 1,
};

@interface MTCoreDataProvider : MTDataProvider
- (instancetype)initWithModelClass:(Class)modelClass withContext:(NSManagedObjectContext *)context;
- (instancetype)initWithModelClass:(Class)modelClass withContext:(NSManagedObjectContext *)context options:(MTCoreDataProviderOptions)options;
@end