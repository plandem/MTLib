//
// Created by Andrey on 30/04/15.
// Copyright (c) 2015 Melatonin LLC. All rights reserved.
//

#import <objc/runtime.h>
#import "MTRealmDataObject.h"
#import "MTRealmDataRepository.h"
#import "MTRealmDataProvider.h"
#import "MTRealmDataQuery.h"
#import "NSObject+MTDataObjectQuery.h"

@implementation MTRealmDataObject
+(Class)repositoryClass {
	return [MTRealmDataRepository class];
}

+(Class)dataProviderClass {
	return [MTRealmDataProvider class];
}

+(Class)queryClass {
	return [MTRealmDataQuery class];
}

//ignore any property that starts with '$'
+(NSArray *)ignoredProperties {
	NSMutableArray *ignore = [NSMutableArray array];

	NSUInteger numberOfProperties = 0;
	objc_property_t *propertyArray = class_copyPropertyList([self class], &numberOfProperties);

	for (NSUInteger i = 0; i < numberOfProperties; i++) {
		objc_property_t property = propertyArray[i];
		NSString *name = [[NSString alloc] initWithUTF8String:property_getName(property)];

		if([name characterAtIndex:0] == '$') {
			[ignore addObject:name];
		}
	} //for(prop_i)

	free(propertyArray);

	return ignore;
}

//set default values for all 'object' types
+(NSDictionary *)defaultPropertyValues {
	NSMutableDictionary *defaultValues = objc_getAssociatedObject([self class], @selector(defaultPropertyValues));
	if (defaultValues) {
		return defaultValues;
	}

	static NSSet *NSObjectProperties;
	static dispatch_once_t onceToken = 0;
	dispatch_once(&onceToken, ^{
		NSObjectProperties = [NSMutableSet set];
		NSUInteger numberOfProperties;
		objc_property_t *propertyList = class_copyPropertyList([NSObject class], &numberOfProperties);
		for (NSUInteger prop_i = 0; prop_i < numberOfProperties; prop_i++) {
			objc_property_t property = propertyList[prop_i];
			NSString *name = [[NSString alloc] initWithUTF8String:property_getName(property)];
			[(NSMutableSet *)NSObjectProperties addObject:name];
		}

		free(propertyList);
		NSObjectProperties = [NSObjectProperties copy];
	});

	NSUInteger numberOfProperties = 0;
	defaultValues = [NSMutableDictionary dictionary];
	objc_property_t *propertyArray = class_copyPropertyList([self class], &numberOfProperties);

	for (NSUInteger prop_i = 0; prop_i < numberOfProperties; prop_i++) {
		objc_property_t property = propertyArray[prop_i];
		NSString *name = [[NSString alloc] initWithUTF8String:property_getName(property)];

		if([NSObjectProperties containsObject:name]) {
			//ignore properties from NSObject
			continue;
		}

		NSUInteger numOfAttributes;
		objc_property_attribute_t *propertyAttributes = property_copyAttributeList(property, &numOfAttributes);
		for (NSUInteger attr_i = 0; attr_i < numOfAttributes; attr_i++ ) {
			switch (propertyAttributes[attr_i].name[0]) {
				case 'T': { //type of the property
					NSString *propertyType = [[NSString alloc] initWithUTF8String:propertyAttributes[attr_i].value];
					if([propertyType isEqualToString:@"@\"NSString\""]) {
						defaultValues[name] = [NSString string];
					} else if([propertyType isEqualToString:@"@\"NSDate\""]) {
						defaultValues[name] = [NSDate dateWithTimeIntervalSince1970:0];
					} else if([propertyType isEqualToString:@"@\"NSData\""]) {
						defaultValues[name] = [[NSData alloc] init];
					}

					break;
				}

				default:
					break;
			}
		} //for(attr_i)

		free(propertyAttributes);
	} //for(prop_i)

	free(propertyArray);
	objc_setAssociatedObject([self class], @selector(defaultPropertyValues), defaultValues, OBJC_ASSOCIATION_RETAIN);

	return defaultValues;
}

@end