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
	NSMutableDictionary *_transformableUpdated;
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

- (NSMutableDictionary *)transformableUpdated {
	if(_transformableUpdated == nil) {
		_transformableUpdated = [NSMutableDictionary dictionary];
	}

	return _transformableUpdated;
}

- (void)transformableUpdate:(NSString *)key {
	self.transformableUpdated[key] = @(YES);

	//trick KVO about changes, we need to initiate willSave
	[self willChangeValueForKey:key];
	[self didChangeValueForKey:key];
}

- (void)willSave {
	NSDictionary *keys = self.transformableUpdated;

	if([keys count]) {
		NSDictionary *attributes = [[self entity] attributesByName];

		for (NSString *key in keys) {
			//skip any non-transformable attributes, because they already updated
			if ([attributes[key] attributeType] != NSTransformableAttributeType)
				continue;

			id current = [self primitiveValueForKey:key];
			id refreshed = nil;

			if (current) {
				//encode
				current = [NSKeyedArchiver archivedDataWithRootObject:current];
				//decode
				refreshed = [NSKeyedUnarchiver unarchiveObjectWithData:current];
			}

			[self setPrimitiveValue:refreshed forKey:key];
		}
	}

	[super willSave];
}
@end