//
// Created by Andrey on 23/06/15.
// Copyright (c) 2015 Andrey. All rights reserved.
//

#import <MTLib/MTData+Realm.h>
#import "ContactProtocol.h"

@interface RealmContact : MTRealmDataObject <ContactProtocol>
@property (nonatomic, retain) NSString *id;
@property (nonatomic, retain) NSString *name;
@property (nonatomic, retain) NSString *email;
@property (nonatomic, assign) NSInteger banned;
@end