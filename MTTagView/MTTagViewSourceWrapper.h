//
// Created by Andrey on 20/09/14.
// Copyright (c) 2015 Melatonin LLC. All rights reserved.
//

#import <AtkDragAndDrop/AtkDragAndDrop.h>
@interface MTTagViewSourceWrapper : NSObject<AtkDragSourceProtocol>
@property (nonatomic, strong) UIView *view;
- (id)initWithView:(UIView *)view;
@end