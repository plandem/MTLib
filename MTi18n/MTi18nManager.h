//
// Created by Andrey on 11/04/15.
// Copyright (c) 2015 Melatonin LLC. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface MTi18nManager : NSObject
@property(nonatomic, readonly) NSArray *languages;
@property(nonatomic, weak) NSString *language;

+(instancetype)sharedInstance;
-(NSString *)localizedStringForKey:(NSString *)key table:(NSString *)table;
-(NSString *)localizedStringForKey:(NSString *)key table:(NSString *)table file:(const char *)file line:(NSUInteger)line;
@end