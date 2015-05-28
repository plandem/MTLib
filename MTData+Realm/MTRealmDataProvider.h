//
// Created by Andrey on 28/04/15.
// Copyright (c) 2015 Melatonin LLC. All rights reserved.
//

#import "MTDataProvider.h"

@interface MTRealmDataProvider: MTDataProvider
-(instancetype)initWithModelClass:(Class)modelClass withRealm:(NSString *)realmName;
@end