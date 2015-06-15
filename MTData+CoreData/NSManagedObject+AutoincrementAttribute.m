//
// Created by Andrey on 15/06/15.
// Copyright (c) 2015 Melatonin LLC. All rights reserved.
//

#import <NLCoreData/NLCoreData.h>
#import "MTLib/MTLogger.h"
#import "NSManagedObject+AutoincrementAttribute.h"

@implementation NSManagedObject (AutoincrementAttribute)
-(void)autoincrement:(NSString *)attribute {
	[self autoincrement:attribute groupBy:nil];
}

-(void)autoincrement:(NSString *)attribute groupBy:(NSString *)groupAttribute {
	// to use 'groupBy' feature we must call it on 'willSave', but 'wilLSave' can be called multiply times, so we must 'imitate' afterInsert and check for '0' value also.
	if(!self.isInserted || [[self valueForKey:attribute] unsignedIntegerValue] > 0) {
		return;
	}

	// we can't use other ways to autoincrement (MAX, e.g.), because they works directly with SQL without unsaved changes. But we want to use unsaved.
	NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntity:[self class] context:[self managedObjectContext]];
	[request setSortDescriptors:@[[NSSortDescriptor sortDescriptorWithKey:attribute ascending:NO]]];
	[request setFetchLimit:1];

	if(groupAttribute) {
		[request setPredicate:[NSPredicate predicateWithFormat:@"%K = %@", groupAttribute, [self valueForKey:groupAttribute]]];
	}

	NSError *error;
	NSArray *result = [[self managedObjectContext] executeFetchRequest:request error:&error];
	NSUInteger sequenceID = 0;

	if(error) {
		DDLogError(@"Error %@, %@", [error localizedDescription], [error userInfo]);
	} else {
		if([result count] > 0) {
			sequenceID = [[result[0] valueForKey:attribute] unsignedIntegerValue] + 1;
		}
	}

	[self setPrimitiveValue:@(sequenceID) forKey:attribute];
}
@end