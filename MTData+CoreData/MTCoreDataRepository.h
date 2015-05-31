//
// Created by Andrey on 28/05/15.
// Copyright (c) 2015 Andrey Gayvoronsky. All rights reserved.
//

#import <CoreData/CoreData.h>
#import "MTDataRepository.h"

@interface MTCoreDataRepository : MTDataRepository
@property (nonatomic, readonly) NSManagedObjectContext *context;
- (instancetype)initWithModelClass:(Class)modelClass withContext:(NSManagedObjectContext *)context;
@end