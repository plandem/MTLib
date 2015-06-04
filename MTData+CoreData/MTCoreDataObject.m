//
// Created by Andrey on 26/05/15.
// Copyright (c) 2015 Andrey Gayvoronsky. All rights reserved.
//

#import "MTDataQuery.h"
#import "MTDataSort.h"
#import "MTCoreDataObject.h"
#import "MTCoreDataProvider.h"
#import "MTCoreDataRepository.h"

@implementation MTCoreDataObject
+(Class)repositoryClass {
	return [MTCoreDataRepository class];
}

+(Class)dataProviderClass {
	return [MTCoreDataProvider class];
}

+(Class)queryClass {
	return [MTDataQuery class];
}
@end