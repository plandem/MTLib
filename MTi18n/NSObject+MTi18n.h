//
// Created by Andrey on 11/04/15.
// Copyright (c) 2015 Melatonin LLC. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "MTi18nMacros.h"

@protocol MTi18n
@property (nonatomic, assign) IBInspectable BOOL i18nAuto;
@end

@interface NSObject (MTi18n) <MTi18n>
-(void)i18nFromNib;
@end