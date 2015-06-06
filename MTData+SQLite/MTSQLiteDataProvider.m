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

		[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(contextUpdated:) name:(NSString *) MTSQLiteDataRepositoryUpdateNotification object:nil];
	}

	return self;
}

-(void)dealloc {
	[[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)contextUpdated:(NSNotification *)notification {
	if([[[self repository] modelClass] isEqual:[notification object]] && [self refreshBlock]) {
		[self refreshBlock](self);
	}
}

@end