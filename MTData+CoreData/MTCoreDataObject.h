//
// Created by Andrey on 26/05/15.
// Copyright (c) 2015 Andrey Gayvoronsky. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>
#import "MTDataObject.h"

@interface MTCoreDataObject : NSManagedObject <MTDataObject>
+ (instancetype)createInContext:(NSManagedObjectContext *)context;
@end