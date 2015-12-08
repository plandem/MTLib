//
// Created by Andrey on 26/05/15.
// Copyright (c) 2015 Andrey Gayvoronsky. All rights reserved.
//

#import "MTDataQuery.h"
#import "MTCoreDataObject.h"
#import "MTCoreDataProvider.h"
#import "MTCoreDataRepository.h"
#import "NSObject+MTDataObjectQuery.h"

@implementation MTCoreDataObject {
	NSMutableSet *_transformableUpdated;
}

+(Class)repositoryClass {
	return [MTCoreDataRepository class];
}

+(Class)dataProviderClass {
	return [MTCoreDataProvider class];
}

+(Class)queryClass {
	return [MTDataQuery class];
}

-(void)transformableRefreshForKey:(NSString *)key {
	//trick KVO about changes, we need to initiate willSave
	[self willChangeValueForKey:key];

	if(_transformableUpdated == nil) {
		_transformableUpdated = [NSMutableSet set];
	}

	[_transformableUpdated addObject:key];
	[self didChangeValueForKey:key];
}

- (void)willSave {
	if(_transformableUpdated && [_transformableUpdated count]) {
		NSDictionary *attributes = [[self entity] attributesByName];

		[_transformableUpdated enumerateObjectsUsingBlock:^(id key, BOOL *stop) {
			//skip any non-transformable attributes, because they already updated
			if ([attributes[key] attributeType] != NSTransformableAttributeType)
				return;

			id current = [self primitiveValueForKey:key];
			id refreshed = nil;

			if (current) {
				//encode
				current = [NSKeyedArchiver archivedDataWithRootObject:current];
				//decode
				refreshed = [NSKeyedUnarchiver unarchiveObjectWithData:current];
			}

			[self setPrimitiveValue:refreshed forKey:key];
		}];

		//'willSave' will be calling each update, so we must prevent it
		[_transformableUpdated removeAllObjects];
	}

	[super willSave];
}
@end