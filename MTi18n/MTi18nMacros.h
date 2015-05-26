//
// Created by Andrey on 11/04/15.
// Copyright (c) 2015 Melatonin LLC. All rights reserved.
//
#import "MTi18nManager.h"

//replace NSLocalizedString macros?
#ifndef MT_LOCALIZATION
#define MT_LOCALIZATION 1
#endif

//log warning about missed translation? will work only if DEBUG was defined.
#ifndef MT_LOCALIZATION_WARNING
#define MT_LOCALIZATION_WARNING 1
#endif

//automatically translate any NSObject at awakeFromNib?
#ifndef MT_LOCALIZATION_AUTO
#define MT_LOCALIZATION_AUTO 0
#endif

#ifdef DEBUG
	#define MTi18nString(_key, _comment) \
		[[MTi18nManager sharedInstance] localizedStringForKey:(_key) table: nil file:__FILE__ line: __LINE__]

	#define MTi18nStringFromTable(_key, _tbl, _comment) \
		[[MTi18nManager sharedInstance] localizedStringForKey:(_key) table: (_tbl) file:__FILE__ line: __LINE__]
#else
#define MTi18nString(_key, _comment) \
		[[MTi18nManager sharedInstance] localizedStringForKey:(_key) table: nil]

#define MTi18nStringFromTable(_key, _tbl, _comment) \
		[[MTi18nManager sharedInstance] localizedStringForKey:(_key) table: (_tbl)]
#endif

#if MT_LOCALIZATION
	#ifdef NSLocalizedString
		#undef NSLocalizedString
		#undef NSLocalizedStringFromTable
	#endif

	#define NSLocalizedString(_key, _comment) MTi18nString((_key), (_comment))
	#define NSLocalizedStringFromTable(_key, _tbl, _comment) MTi18nStringFromTable((_key), (_tbl), (_comment))
#endif