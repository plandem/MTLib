//
// Created by Andrey on 23/06/15.
// Copyright (c) 2015 Andrey. All rights reserved.
//

#import "AppDelegate.h"
#import "MainAssembly.h"
#import "MainRouter.h"
#import "CoreContact.h"
#import "RealmContact.h"
#import "SQLiteContact.h"
#import "ContactListViewController.h"
#import "ContactEditViewController.h"

@implementation MainAssembly
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wundeclared-selector"

-(ContactListViewController *)contactListViewController {
	return [TyphoonDefinition withClass:[ContactListViewController class] configuration:^(TyphoonDefinition *definition) {
		[definition injectProperty:@selector(router) with: [self mainRouter]];
	}];
}

-(ContactEditViewController *)contactEditViewController {
	return [TyphoonDefinition withClass:[ContactEditViewController class] configuration:^(TyphoonDefinition *definition) {
		[definition injectProperty:@selector(router) with: [self mainRouter]];
	}];
}

-(MainRouter *)mainRouter {
	//we must create SQLite table somewhere, so let's do it here. just for demo.
	MTSQLiteDataRepository *sqliteRepository = [[MTSQLiteDataRepository alloc] initWithModelClass:[SQLiteContact class]];

	NSString *initSQL = @"CREATE TABLE SQLiteContact (\
			'name' varchar,\
			'email' varchar,\
			'banned' integer,\
			'id' integer NOT NULL,\
			PRIMARY KEY('id')\
	);\
	CREATE INDEX idx1_name ON SQLiteContact ('name');\
	CREATE INDEX idx2_banned ON SQLiteContact ('banned');";
	[sqliteRepository.db executeStatements:initSQL withResultBlock:nil];
	//
	return [TyphoonDefinition withClass:[MainRouter class] configuration:^(TyphoonDefinition *definition) {
		[definition injectProperty:@selector(coreRepository) with:[[MTCoreDataRepository alloc] initWithModelClass:[CoreContact class]]];
		[definition injectProperty:@selector(realmRepository) with:[[MTRealmDataRepository alloc] initWithModelClass:[RealmContact class]]];
		[definition injectProperty:@selector(sqliteRepository) with:sqliteRepository];
	}];
}

#pragma clang diagnostic pop
@end