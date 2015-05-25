//
// Created by Andrey on 26/04/15.
// Copyright (c) 2015 Andrey Gayvoronsky. All rights reserved.
//

#import <Foundation/Foundation.h>
@class MTDataQuery;

typedef void (^MTDataQueryBlock)(MTDataQuery *subQuery);

@interface MTDataQuery: NSObject
//result info
@property (nonatomic, readonly) NSPredicate *predicate;

//chaining methods
@property (readonly) MTDataQuery *(^condition)(id condition, ...);
@property (readonly) MTDataQuery *(^notCondition)(id condition, ...);
@property (readonly) MTDataQuery *(^between)(NSString *attribute, id from, id to);
@property (readonly) MTDataQuery *(^notBetween)(NSString *attribute, id from, id to);
@property (readonly) MTDataQuery *(^in)(NSString *attribute, NSArray *array);
@property (readonly) MTDataQuery *(^notIn)(NSString *attribute, NSArray *array);
@property (readonly) MTDataQuery *(^beginsWith)(NSString *attribute, NSString *string);
@property (readonly) MTDataQuery *(^notBeginsWith)(NSString *attribute, NSString *string);
@property (readonly) MTDataQuery *(^endsWith)(NSString *attribute, NSString *string);
@property (readonly) MTDataQuery *(^notEndsWith)(NSString *attribute, NSString *string);
@property (readonly) MTDataQuery *(^contains)(NSString *attribute, NSString *string);
@property (readonly) MTDataQuery *(^notContains)(NSString *attribute, NSString *string);
@property (readonly) MTDataQuery *(^not)(MTDataQueryBlock block);
@property (readonly) MTDataQuery *(^and)(MTDataQueryBlock block);
@property (readonly) MTDataQuery *(^or)(MTDataQueryBlock block);
@end