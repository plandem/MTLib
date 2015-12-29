//
// Created by Andrey on 11/04/15.
// Copyright (c) 2015 Melatonin LLC. All rights reserved.
//

#import "MTi18nMacros.h"

static NSBundle *MTi18nBundle = nil;
static NSString *MTi18nLanguageKey = @"AppleLanguages";
static NSString *MTi18nMissedKey = @"#MTI18N#";

@interface MTi18nManager ()
@property(nonatomic, strong) NSArray *languages;
@property(nonatomic, strong) NSDictionary *dictionary;
@end

@implementation MTi18nManager
+(instancetype)sharedInstance {
	static id sharedInstance = nil;
	static dispatch_once_t onceToken = 0;
	dispatch_once(&onceToken, ^{
		sharedInstance = [[self alloc] init];
	});

	return sharedInstance;
}

-(id)init{
	if((self = [super init])) {
		MTi18nBundle = [NSBundle mainBundle];
	}

	return self;
}

-(NSArray *)languages {
	if(_languages == nil) {
		_languages = [[NSBundle mainBundle] localizations];
	}

	return _languages;
}

-(NSString *)language {
	NSString *language = [[[NSUserDefaults standardUserDefaults] objectForKey:MTi18nLanguageKey] firstObject];
	if(([self.languages indexOfObject:language]) == NSNotFound) {
#if MT_LOCALIZATION_WARNING
		NSLog(@"There is no localization for language '%@'. Using default system settings for it.", language);
#endif
	}

	return language;
}

-(void)setLanguage:(NSString*)language {
	//ignore unknown languages
	if(([self.languages indexOfObject:language]) == NSNotFound) {
		#if MT_LOCALIZATION_WARNING
			NSLog(@"There is no localization for language '%@'. Ignored.", language);
		#endif
		return;
	}

	NSString *path = [[NSBundle mainBundle] pathForResource:language ofType:@"lproj"];
	if (path == nil) {
		// there is no bundle for that language use main bundle instead
		MTi18nBundle = [NSBundle mainBundle];
	} else {
		// use this bundle as my bundle from now on:
		MTi18nBundle = [NSBundle bundleWithPath:path];

		// to be absolutely sure (this is probably unnecessary):
		if (MTi18nBundle == nil) {
			MTi18nBundle = [NSBundle mainBundle];
		}
	}

	//if bundle with language correctly resolved, then set it as application's language
	if(!([[NSBundle mainBundle] isEqual:MTi18nBundle])) {
		[[NSUserDefaults standardUserDefaults] setObject:@[language] forKey:MTi18nLanguageKey];
		[[NSUserDefaults standardUserDefaults] synchronize];
	}
}

-(NSString *)localizedStringForKey:(NSString *)key table:(NSString *)table {
	return [MTi18nBundle localizedStringForKey:key value:nil table:table];
}

-(NSString *)localizedStringForKey:(NSString *)key table:(NSString *)table file:(const char *)file line:(NSUInteger)line {
	NSString *result = [MTi18nBundle localizedStringForKey:key value:MTi18nMissedKey table:table];
	if(!([result isEqual:MTi18nMissedKey]))
		return result;

	#if MT_LOCALIZATION_WARNING
		NSLog(@"Localizable string \"%@\" not found in strings table \"%@\". %@:%d", key, (table ? table : @"Localizable"), [NSString stringWithFormat:@"%s", file], line);
	#endif

	return key;
}
@end