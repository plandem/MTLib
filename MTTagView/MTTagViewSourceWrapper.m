//
// Created by Andrey on 20/09/14.
// Copyright (c) 2015 Melatonin LLC. All rights reserved.
//

#import "MTTagViewSourceWrapper.h"

@interface MTTagViewSourceWrapper ()
@property (nonatomic, strong) UIView *shadow;
@property (nonatomic, strong) CAShapeLayer *border;
@property (nonatomic, strong) UIColor *originalTextColor;
@property (nonatomic, strong) UIColor *originalBackgroundColor;
@end

@implementation MTTagViewSourceWrapper
- (id)initWithView:(UIView *)view {
	if((self = [super init])) {
		self.view = view;
	}

	return self;
}

-(CAShapeLayer *)border {
	if(_border == nil) {
		_border = [CAShapeLayer layer];
		_border.path = [UIBezierPath bezierPathWithRoundedRect:self.view.bounds cornerRadius:15.f].CGPath;;
		_border.frame = self.view.bounds;

		if([self.originalBackgroundColor isEqual:[UIColor clearColor]]) {
			_border.strokeColor = [[UIColor grayColor] CGColor];
		} else {
			_border.strokeColor = [self.originalBackgroundColor CGColor];
		}

		_border.fillColor = [[UIColor clearColor] CGColor];
		_border.lineDashPattern = @[@3, @3];
		_border.lineWidth = 1.0;
	}

	return _border;
}

- (void)dragStarted:(AtkDragAndDropManager *)manager {
	self.originalBackgroundColor = [UIColor colorWithCGColor:self.view.layer.backgroundColor];
	self.originalTextColor = [UIColor blackColor];

	if([self.view isKindOfClass:[UILabel class]]) {
		self.originalTextColor = ((UILabel *) self.view).textColor;
	}

	self.view.layer.backgroundColor = self.originalTextColor.CGColor;
	if([self.view isKindOfClass:[UILabel class]]) {
		((UILabel *) self.view).textColor = self.originalBackgroundColor;
	}

	[self.view.layer addSublayer:self.border];
}

- (void)dragEnded:(AtkDragAndDropManager *)manager {
	self.view.layer.backgroundColor = self.originalBackgroundColor.CGColor;

	if([self.view isKindOfClass:[UILabel class]]) {
		((UILabel *) self.view).textColor = self.originalTextColor;
	}

	[self.border removeFromSuperlayer];
}

- (UIView *)createDragShadowView:(AtkDragAndDropManager *)manager {
	UIView *shadow = [self.view createDefaultDragShadowView:manager];
	shadow.alpha = 0.2f;
	return shadow;
}

@end