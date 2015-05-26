//
// Created by Andrey on 26/05/15.
// Copyright (c) 2015 Andrey Gayvoronsky. All rights reserved.
//

#import <CoreData/CoreData.h>
#import "MTDataProvider.h"
#import "MTCoreDataObject.h"
#import "MTCoreDataStack.h"

@interface MTCoreDataProvider: MTDataProvider
@property (nonatomic, readonly) NSManagedObjectContext *context;
-(instancetype)initWithModelClass:(Class)modelClass withContext:(NSManagedObjectContext *)context;

/**
* NSFetchRequest advanced settings
*/
@property (nonatomic, assign) NSUInteger limit;
@property (nonatomic, assign) NSUInteger offset;
@property (nonatomic, assign) NSUInteger batchSize;
@property (nonatomic, assign) NSFetchRequestResultType resultType;
@property (nonatomic, assign) BOOL includesPendingChanges;
@property (nonatomic, assign) BOOL includesPropertyValues;
@property (nonatomic, assign) BOOL shouldRefreshRefetchedObjects;
@property (nonatomic, assign) BOOL returnsObjectsAsFaults;
@property (nonatomic, assign) BOOL returnsDistinctResults;
@end