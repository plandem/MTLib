//
// Created by Andrey on 18/06/15.
// Copyright (c) 2015 Melatonin LLC. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MTLib/MTStyleKit.h>

@interface LASwipeButton : UIButton
+(instancetype)buttonWithImageName:(NSString *)imageName withStyleKit:(id<MTStyleKit>)styleKit;
@end