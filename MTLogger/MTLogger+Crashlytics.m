//
// Created by Andrey on 25/05/15.
//

#import <CrashlyticsLumberjack/CrashlyticsLogger.h>
#import <MTLib/MTLogger.h>

@implementation MTLogger (Crashlytics)
+ (void)setupLogger {
	MTLogger *logger = [self.class start];
	[DDLog addLogger:[CrashlyticsLogger sharedInstance] withLevel:DDLogLevelWarning]; //error + warn to Crashlytics
	[CrashlyticsLogger sharedInstance].logFormatter = logger;
}

+ (void)startWithAPIKey:(NSString *)apiKey {
#ifdef MTLOGGER_PRODUCTION_BUILD
	[Crashlytics startWithAPIKey:apiKey];
	[self setupLogger];
#endif
}

+ (void)startWithAPIKey:(NSString *)apiKey afterDelay:(NSTimeInterval)delay {
#ifdef MTLOGGER_PRODUCTION_BUILD
	[Crashlytics startWithAPIKey:apiKey afterDelay:delay];
	[self setupLogger];
#endif
}

+ (void)startWithAPIKey:(NSString *)apiKey delegate:(NSObject <CrashlyticsDelegate> *)delegate {
#ifdef MTLOGGER_PRODUCTION_BUILD
	[Crashlytics startWithAPIKey:apiKey delegate:delegate];
	[self setupLogger];
#endif
}

+ (void)startWithAPIKey:(NSString *)apiKey delegate:(NSObject <CrashlyticsDelegate> *)delegate afterDelay:(NSTimeInterval)delay {
#ifdef MTLOGGER_PRODUCTION_BUILD
	[Crashlytics startWithAPIKey:apiKey delegate:delegate afterDelay:delay];
	[self setupLogger];
#endif
}
@end