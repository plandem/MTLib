//
// Created by Andrey on 25/05/15.
// Copyright (c) 2015 Melatonin LLC. All rights reserved.
//
#import <CrashlyticsLumberjack/CrashlyticsLogger.h>
#import "MTLogger+Crashlytics.h"

@implementation MTLogger (Crashlytics)
+ (void)setupLogger {
	MTLogger *logger = [self.class start];

#ifdef MTLOGGER_PRODUCTION_BUILD
	[DDLog addLogger:[CrashlyticsLogger sharedInstance] withLevel:DDLogLevelWarning]; //error + warn to Crashlytics
	[CrashlyticsLogger sharedInstance].logFormatter = logger;
#endif
}

+ (void)startWithAPIKey:(NSString *)apiKey {
	[self setupLogger];

#ifdef MTLOGGER_PRODUCTION_BUILD
	[Crashlytics startWithAPIKey:apiKey];
#endif
}

+ (void)startWithAPIKey:(NSString *)apiKey afterDelay:(NSTimeInterval)delay {
	[self setupLogger];

#ifdef MTLOGGER_PRODUCTION_BUILD
	[Crashlytics startWithAPIKey:apiKey afterDelay:delay];
#endif
}

+ (void)startWithAPIKey:(NSString *)apiKey delegate:(NSObject <CrashlyticsDelegate> *)delegate {
	[self setupLogger];

#ifdef MTLOGGER_PRODUCTION_BUILD
	[Crashlytics startWithAPIKey:apiKey delegate:delegate];
#endif
}

+ (void)startWithAPIKey:(NSString *)apiKey delegate:(NSObject <CrashlyticsDelegate> *)delegate afterDelay:(NSTimeInterval)delay {
	[self setupLogger];

#ifdef MTLOGGER_PRODUCTION_BUILD
	[Crashlytics startWithAPIKey:apiKey delegate:delegate afterDelay:delay];
#endif
}
@end