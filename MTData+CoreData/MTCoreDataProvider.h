//
// Created by Andrey on 26/05/15.
// Copyright (c) 2015 Andrey Gayvoronsky. All rights reserved.
//

#import <CoreData/CoreData.h>
#import "MTDataProvider.h"

@interface MTCoreDataProvider : MTDataProvider
- (instancetype)initWithModelClass:(Class)modelClass withContext:(NSManagedObjectContext *)context;
@end