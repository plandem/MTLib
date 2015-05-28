//
// Created by Andrey on 26/04/15.
// Copyright (c) 2015 Melatonin LLC. All rights reserved.
//

#import <Foundation/Foundation.h>
@class MTDataQuery;
@class MTDataSort;

typedef void (^MTDataQueryBlock)(MTDataQuery *subQuery);

@interface MTDataQuery: NSObject
@property (nonatomic, readonly) NSPredicate *predicate;
@property (nonatomic, readonly) MTDataSort *sort;
@property (nonatomic, readonly) NSUInteger batchSize;

//chaining methods
@property (nonatomic, readonly) MTDataQuery *(^condition)(id condition, ...);
@property (nonatomic, readonly) MTDataQuery *(^notCondition)(id condition, ...);
@property (nonatomic, readonly) MTDataQuery *(^between)(NSString *attribute, id from, id to);
@property (nonatomic, readonly) MTDataQuery *(^notBetween)(NSString *attribute, id from, id to);
@property (nonatomic, readonly) MTDataQuery *(^in)(NSString *attribute, NSArray *array);
@property (nonatomic, readonly) MTDataQuery *(^notIn)(NSString *attribute, NSArray *array);
@property (nonatomic, readonly) MTDataQuery *(^beginsWith)(NSString *attribute, NSString *string);
@property (nonatomic, readonly) MTDataQuery *(^notBeginsWith)(NSString *attribute, NSString *string);
@property (nonatomic, readonly) MTDataQuery *(^endsWith)(NSString *attribute, NSString *string);
@property (nonatomic, readonly) MTDataQuery *(^notEndsWith)(NSString *attribute, NSString *string);
@property (nonatomic, readonly) MTDataQuery *(^contains)(NSString *attribute, NSString *string);
@property (nonatomic, readonly) MTDataQuery *(^notContains)(NSString *attribute, NSString *string);
@property (nonatomic, readonly) MTDataQuery *(^not)(MTDataQueryBlock block);
@property (nonatomic, readonly) MTDataQuery *(^and)(MTDataQueryBlock block);
@property (nonatomic, readonly) MTDataQuery *(^or)(MTDataQueryBlock block);
@property (nonatomic, readonly) MTDataQuery *(^limit)(NSUInteger limit);

+(Class)sortClass;
@end