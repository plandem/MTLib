//
// Created by Andrey on 16/06/15.
// Copyright (c) 2015 Melatonin LLC. All rights reserved.
//

#import <FXForms/FXForms.h>
#import <MTLib/MTStyleKit.h>

@interface FXFormBaseCell (MTStyleKit)
-(id<MTStyleKit>)styleKit;
-(void)applyStyles;
@end