//
// Created by Andrey on 25/05/15.
// Copyright (c) 2015 Melatonin LLC. All rights reserved.
//
#ifndef MT_LOGGER_H
#define MT_LOGGER_H
#import <Foundation/Foundation.h>
#import <CocoaLumberjack/CocoaLumberjack.h>

#ifndef DEBUG
	#if TARGET_IPHONE_SIMULATOR == 0
		#define MTLOGGER_PRODUCTION_BUILD 1
	#endif
#endif

@interface MTLogger : NSObject <DDLogFormatter>
+(MTLogger *)start;
@end

#ifdef MTLOGGER_CRASHLYTICS
#import <MTLib/MTLogger+Crashlytics.h>
#endif
#endif


