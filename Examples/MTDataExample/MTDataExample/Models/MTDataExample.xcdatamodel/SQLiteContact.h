//
// Created by Andrey on 23/06/15.
// Copyright (c) 2015 Andrey. All rights reserved.
//

#import <MTLib/MTData+SQLite.h>
#import "ContactProtocol.h"

@interface SQLiteContact : NSObject <MTDataObject, ContactProtocol>
@property (nonatomic, retain) NSNumber *id;
@property (nonatomic, retain) NSString *name;
@property (nonatomic, retain) NSString *email;
@property (nonatomic, assign) NSInteger banned;
@end