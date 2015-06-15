//
// Created by Andrey on 14/06/15.
// Copyright (c) 2015 Melatonin LLC. All rights reserved.
//

#import <NLCoreData/NLCoreData.h>
#import "NSManagedObject+UniqueAttribute.h"

@implementation NSManagedObject (UniqueAttribute)
-(BOOL)isUniqueAttribute:(NSString *)attribute value:(id *)value error:(NSError **)error {
	if(*value) {
		NSUInteger count = [[self class] countInContext:[self managedObjectContext] predicate:[NSPredicate predicateWithFormat:@"%K = %@", attribute, *value]];
		if(count == 1) {
			return YES;
		}

		if(count == 0) {
			*error = [NSError errorWithDomain:@"NSManagedObject" code:100 userInfo:@{
					NSLocalizedDescriptionKey: [NSString stringWithFormat:@"Attribute '%@' validation error. Looks like upredictable behavior.", attribute]
			}];
		} else {
			*error = [NSError errorWithDomain:@"NSManagedObject" code:100 userInfo:@{
					NSLocalizedDescriptionKey: [NSString stringWithFormat:@"Attribute '%@' must be unique. There is already model with '%@'=%@", attribute, attribute, *value]
			}];
		}
	} else {
		*error = [NSError errorWithDomain:@"NSManagedObject" code:100 userInfo:@{
				NSLocalizedDescriptionKey: [NSString stringWithFormat:@"Mondatory attribute '%@' is nil", attribute]
		}];
	}

	return NO;
}
@end