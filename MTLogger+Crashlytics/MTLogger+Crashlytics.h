//
// Created by Andrey on 25/05/15.
// Copyright (c) 2015 Melatonin LLC. All rights reserved.
//
#import <Foundation/Foundation.h>
#import <Crashlytics/Crashlytics.h>
#import "MTLogger.h"

@interface MTLogger (Crashlytics)
+ (void)startWithAPIKey:(NSString *)apiKey;
+ (void)startWithAPIKey:(NSString *)apiKey afterDelay:(NSTimeInterval)delay;
+ (void)startWithAPIKey:(NSString *)apiKey delegate:(NSObject <CrashlyticsDelegate> *)delegate;
+ (void)startWithAPIKey:(NSString *)apiKey delegate:(NSObject <CrashlyticsDelegate> *)delegate afterDelay:(NSTimeInterval)delay;
@end