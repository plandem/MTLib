//
// Created by Andrey on 27/04/15.
// Copyright (c) 2015 Melatonin LLC. All rights reserved.
//

#import <Foundation/Foundation.h>

@class MTDataQuery;

@protocol MTDataObject <NSObject>
@required
+(Class)repositoryClass;
+(Class)dataProviderClass;
+(Class)queryClass;
+(MTDataQuery *)query;

@optional
+(NSArray *)transformable;
-(void)transformableRefreshForKey:(NSString *)key;
@end

@protocol MTDataObjectCollection <NSFastEnumeration>
@required
@property (readonly) NSUInteger count;
- (id)objectAtIndex:(NSUInteger)index;
- (id)objectAtIndexedSubscript:(NSUInteger)index;
@end