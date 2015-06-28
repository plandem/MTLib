//
// Created by Andrey on 27/06/15.
// Copyright (c) 2015 Melatonin LLC. All rights reserved.
//

#import "MTDisplayLinker.h"

@interface MTDisplayLinker()
@property(nonatomic, weak) id<MTDisplayLinkerDelegate> delegate;
@property(nonatomic, copy) MTDisplayLinkerUpdateBlock updateBlock;
@property(nonatomic, strong) CADisplayLink *displayLink;
@property(nonatomic, assign) CGFloat duration;
@end

@implementation MTDisplayLinker {
	BOOL _nextDeltaTimeZero;
	CFTimeInterval _previousTimestamp;
	CFTimeInterval _durationExpire;
}

-(instancetype)init {
	if((self = [super init])) {
		_displayLink = nil;
		_updateBlock = nil;
		_delegate = nil;
		_nextDeltaTimeZero = YES;
		_previousTimestamp = 0.0f;
		_durationExpire = 0.0f;
		_duration = 0.0f;
	}

	return self;
}

+(instancetype)linkerWithDelegate:(id<MTDisplayLinkerDelegate>)delegate {
	return [MTDisplayLinker linkerWithDelegate:delegate duration: 0.0f];
}

+(instancetype)linkerWithBlock:(MTDisplayLinkerUpdateBlock)block {
	return [MTDisplayLinker linkerWithBlock:block duration:0.0f];
}

+(instancetype)linkerWithDelegate:(id<MTDisplayLinkerDelegate>)delegate duration:(CGFloat)duration {
	MTDisplayLinker *linker = [[MTDisplayLinker alloc] init];

	if(linker) {
		linker.delegate = delegate;
		linker.duration = duration;
		linker.updateBlock = ^(MTDisplayLinker *displayLinker, CFTimeInterval deltaTime) {
			[displayLinker.delegate displayLinker:displayLinker willUpdateWithDeltaTime:deltaTime];
		};
	}

	return linker;
}

+(instancetype)linkerWithBlock:(MTDisplayLinkerUpdateBlock)block duration:(CGFloat)duration {
	MTDisplayLinker *linker = [[MTDisplayLinker alloc] init];

	if(linker) {
		linker.updateBlock = block;
		linker.duration = duration;
	}

	return linker;
}

-(void)dealloc {
	[self stop];
}

- (void)start {
	if(_displayLink == nil) {
		_displayLink = [CADisplayLink displayLinkWithTarget:self selector:@selector(displayLinkUpdated)];

		// of course we still have some 'lag' between first frame, but in case of seconds it will be accepted.
		if(_duration) {
			_durationExpire = _duration + CACurrentMediaTime();
		}

		// 'NSDefaultRunLoopMode' does not include UIScrollView scrolling mode, so use 'NSRunLoopCommonModes' instead
		[_displayLink addToRunLoop:[NSRunLoop mainRunLoop] forMode:NSRunLoopCommonModes];

		_nextDeltaTimeZero = YES;

		// get notified if the application active state changes
		[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(irregularFrameRateExpected) name:UIApplicationDidBecomeActiveNotification object:nil];
		[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(irregularFrameRateExpected) name:UIApplicationWillResignActiveNotification object:nil];
	}
}

- (void)stop {
	if(_displayLink != nil) {
		[_displayLink invalidate];
		_displayLink = nil;
		_nextDeltaTimeZero = YES;

		[[NSNotificationCenter defaultCenter] removeObserver:self];
	}
}

// an irregular frame rate is expected
- (void)irregularFrameRateExpected {
	_nextDeltaTimeZero = YES;
}

- (void)displayLinkUpdated {
	CFTimeInterval currentTime = [_displayLink timestamp];
	CFTimeInterval deltaTime;

	if(_nextDeltaTimeZero) {
		_nextDeltaTimeZero = NO;
		deltaTime = 0.0;
	} else {
		deltaTime = currentTime - _previousTimestamp;
	}

	_previousTimestamp = currentTime;

	if(_durationExpire && currentTime >= _durationExpire) {
		[self stop];
	}

	_updateBlock(self, deltaTime);
}

@end