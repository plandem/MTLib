//
// Created by Andrey on 28/05/15.
// Copyright (c) 2015 Andrey Gayvoronsky. All rights reserved.
//

#import <Realm/Realm.h>
#import <MTDataRepository.h>

@interface MTRealmDataRepository : MTDataRepository
@property (nonatomic, readonly) NSString *realmPath;
@property (nonatomic, readonly) NSString *realmName;
@property (nonatomic, readonly) RLMRealm *realm;

-(instancetype)initWithModelClass:(Class)modelClass withRealm:(NSString *)realmName;
@end