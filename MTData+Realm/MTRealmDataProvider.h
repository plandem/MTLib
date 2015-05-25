//
// Created by Andrey on 28/04/15.
// Copyright (c) 2015 Andrey Gayvoronsky. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <MTData/MTDataProvider.h>

@interface MTRealmDataProvider: MTDataProvider
@property (nonatomic, readonly) NSString *realmPath;
@property (nonatomic, readonly) NSString *realmName;
-(instancetype)initWithModelClass:(Class)modelClass withRealm:(NSString *)realmName;
@end