//
// Created by Andrey on 25/05/15.
//

#import <Foundation/Foundation.h>
#import <CrashlyticsFramework/Crashlytics.h>
//#import <MTLib/MTLogger.h>

@class MTLogger;

@interface MTLogger (Crashlytics)
+ (void)startWithAPIKey:(NSString *)apiKey;
+ (void)startWithAPIKey:(NSString *)apiKey afterDelay:(NSTimeInterval)delay;
+ (void)startWithAPIKey:(NSString *)apiKey delegate:(NSObject <CrashlyticsDelegate> *)delegate;
+ (void)startWithAPIKey:(NSString *)apiKey delegate:(NSObject <CrashlyticsDelegate> *)delegate afterDelay:(NSTimeInterval)delay;
@end