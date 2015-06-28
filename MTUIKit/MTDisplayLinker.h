//
// Created by Andrey on 27/06/15.
// Copyright (c) 2015 Melatonin LLC. All rights reserved.
//

#import <UIKit/UIKit.h>

@class MTDisplayLinker;
@protocol MTDisplayLinkerDelegate;

typedef void(^MTDisplayLinkerUpdateBlock)(MTDisplayLinker *displayLinker, CFTimeInterval deltaTime);

@interface MTDisplayLinker : NSObject
@property(nonatomic, strong, readonly) CADisplayLink *displayLink;

+(instancetype)linkerWithDelegate:(id<MTDisplayLinkerDelegate>)delegate;
+(instancetype)linkerWithDelegate:(id<MTDisplayLinkerDelegate>)delegate duration:(CGFloat)duration;

+(instancetype)linkerWithBlock:(MTDisplayLinkerUpdateBlock)block;
+(instancetype)linkerWithBlock:(MTDisplayLinkerUpdateBlock)block duration:(CGFloat)duration;

-(void)start;
-(void)stop;
@end

@protocol MTDisplayLinkerDelegate <NSObject>
@required
-(void)displayLinker:(MTDisplayLinker *)linker willUpdateWithDeltaTime:(CFTimeInterval)deltaTime;
@optional
@end