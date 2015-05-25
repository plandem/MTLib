//
// Created by Andrey on 25/05/15.
// Copyright (c) 2015 Melatonin LLC. All rights reserved.
//

#import <libgen.h>
#import <MTLib/MTLogger.h>

#if DEBUG
	static const DDLogLevel ddLogLevel = DDLogLevelVerbose;
#else
	static const DDLogLevel ddLogLevel = DDLogLevelWarning;
#endif

@interface MTLogger ()
@property(nonatomic, strong) NSDateFormatter *logFormatter;
@end

@implementation MTLogger
+ (MTLogger *)start {
	static MTLogger *logger = nil;
	static dispatch_once_t onceToken;
	dispatch_once(&onceToken, ^{
		logger = [[MTLogger alloc] init];

		[DDLog addLogger:[DDASLLogger sharedInstance] withLevel:DDLogLevelInfo]; //info + warn + error to console.app
		[DDLog addLogger:[DDTTYLogger sharedInstance] withLevel:DDLogLevelVerbose]; //verbose to xcode console

		[DDTTYLogger sharedInstance].colorsEnabled = YES;
		[DDTTYLogger sharedInstance].logFormatter = logger;
		[DDASLLogger sharedInstance].logFormatter = logger;
	});

	return logger;
}

- (instancetype)init {
	self = [super init];

	if (self) {
		self.logFormatter = [[NSDateFormatter alloc] init];
		self.logFormatter.formatterBehavior = NSDateFormatterBehaviorDefault;
		self.logFormatter.dateFormat = @"yyyy-MM-dd HH:mm:ss:SSS";
	}

	return self;
}

- (NSString *)formatLogMessage:(DDLogMessage *)logMessage {
	NSString *logLevel;
	switch (logMessage->_flag) {
		case DDLogFlagError:
			logLevel = @"E";
			break;
		case DDLogFlagWarning:
			logLevel = @"W";
			break;
		case DDLogFlagInfo:
			logLevel = @"I";
			break;
		case DDLogFlagDebug:
			logLevel = @"D";
			break;
		default:
			logLevel = @"V";
			break;
	}

	return [NSString stringWithFormat:@"%@ [%@] %@ %s:%d", [_logFormatter stringFromDate:(logMessage->_timestamp)], logLevel, logMessage->_message, basename((char *) [logMessage->_file UTF8String]), logMessage->_line];
}
@end