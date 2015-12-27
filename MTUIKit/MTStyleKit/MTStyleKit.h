//
// Created by Andrey on 10/06/15.
// Copyright (c) 2015 Melatonin LLC. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "MTStyleKitAppearancePatch.h"

extern const NSString *MTStyleKitChangedNotification;

@protocol MTStyleKit <NSObject>
@optional
-(BOOL)applyStyles:(id<MTStyleKit>)styleKit;
@end