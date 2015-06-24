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
	return [self initWithRepository:[(MTSQLiteDataRepository *)[[(id<MTDataObject>)modelClass repositoryClass] alloc] initWithModelClass:modelClass withDB:dbName]];
}

-(void)dealloc {
	[[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)repositoryUpdated:(NSNotification *)notification {
	if([[[self repository] modelClass] isEqual:[notification object]] && [self refreshBlock]) {
		[self refreshBlock](self);
	}
}

-(void)setupWatcher {
	[[NSNotificationCenter defaultCenter] removeObserver:self];

	if([self refreshBlock]) {
		[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(repositoryUpdated:) name:(NSString *) MTSQLiteDataRepositoryUpdateNotification object:nil];
	}
}
@end