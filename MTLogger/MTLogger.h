//
// Created by Andrey on 25/05/15.
// Copyright (c) 2015 Melatonin LLC. All rights reserved.
//
#import <Foundation/Foundation.h>
#import <CocoaLumberjack/CocoaLumberjack.h>

#ifndef DEBUG
	#if TARGET_IPHONE_SIMULATOR == 0
		#define MTLOGGER_PRODUCTION_BUILD 1
	#endif
#endif

#ifndef MTLOGGER_PRODUCTION_BUILD
	#define TICK NSDate *__profiler_start__ = [NSDate date];
	#define TOCK DDLogDebug(@"Elapsed time: %f", - [__profiler_start__ timeIntervalSinceNow]);
#endif

@interface MTLogger : NSObject <DDLogFormatter>
+(MTLogger *)start;
@end


