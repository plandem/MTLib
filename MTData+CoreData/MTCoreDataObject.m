//
// Created by Andrey on 26/05/15.
// Copyright (c) 2015 Andrey Gayvoronsky. All rights reserved.
//

#import "MTCoreDataObject.h"

@implementation MTCoreDataObject
+ (instancetype)createInContext:(NSManagedObjectContext *)context {
	NSEntityDescription *entity = [NSEntityDescription entityForName:NSStringFromClass([self class]) inManagedObjectContext:context];

	return (MTCoreDataObject *)[[NSManagedObject alloc] initWithEntity:entity insertIntoManagedObjectContext:context];
}
@end