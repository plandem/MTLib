//
// Created by Andrey on 14/06/15.
// Copyright (c) 2015 Melatonin LLC. All rights reserved.
//

#import <CoreData/CoreData.h>

@interface NSManagedObject (UniqueAttribute)
// Will not work correctly if some models will be in process of creation at another context.
+(BOOL)isUniqueAttribute:(NSString *)attribute value:(id *)value error:(NSError **)error context:(NSManagedObjectContext *)context;
@end