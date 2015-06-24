//
// Created by Andrey on 23/06/15.
// Copyright (c) 2015 Andrey. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol ContactProtocol <NSObject>
@property (nonatomic, retain) NSString *name;
@property (nonatomic, retain) NSString *email;
@property (nonatomic, assign) NSInteger banned;
@end