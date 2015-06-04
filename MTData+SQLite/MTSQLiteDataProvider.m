//
// Created by Andrey on 03/06/15.
// Copyright (c) 2015 Melatonin LLC. All rights reserved.
//

#import "MTSQLiteDataProvider.h"
#import "MTSQLiteDataRepository.h"

@implementation MTSQLiteDataProvider
-(instancetype)initWithModelClass:(Class)modelClass {
	return [self initWithModelClass:modelClass withDB:[MTSQLiteDataRepository defaultDbName]];
}

-(instancetype)initWithModelClass:(Class)modelClass withDB:(NSString *)dbName {
	if((self = [self init])) {
		self.repository = [(MTSQLiteDataRepository *)[[(id<MTDataObject>)modelClass repositoryClass] alloc] initWithModelClass:modelClass withDB:dbName];
	}

	return self;
}

@end