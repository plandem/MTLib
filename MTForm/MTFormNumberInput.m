//
// Created by Andrey on 20/04/15.
// Copyright (c) 2015 Melatonin LLC. All rights reserved.
//

#import "MTFormNumberInput.h"

@implementation MTFormNumberInput {
	NSInteger _valueInteger;
	NSInteger _valueIntegerMax;
	NSInteger _valueIntegerMin;

	CGFloat _valueFloat;
	CGFloat _valueFloatMax;
	CGFloat _valueFloatMin;

	BOOL _hasChanged;
}

- (instancetype)init {
	if((self = [super init])) {
		[self setup];
	}

	return self;
}

- (void)setup {
	self.mode = MTFormNumberInputCellModeInteger;

	_hasChanged = NO;

#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Warc-unsafe-retained-assign"
	self.minValue = @(0);
	self.maxValue = @(INT_MAX);
#pragma clang diagnostic pop
}

- (void)valueChanged {
	if(_hasChanged && _valueChangedBlock) {
		_valueChangedBlock();
	}

	_hasChanged = NO;
}

- (NSNumber *)value {
	if(_mode == MTFormNumberInputCellModeFloat)
		return @(_valueFloat);
	else if(_mode == MTFormNumberInputCellModeInteger || _mode == MTFormNumberInputCellModeUnsigned)
		return @(_valueInteger);
	else
		return nil;
}

- (void)setValue:(NSNumber* )value {
	if(_mode == MTFormNumberInputCellModeFloat) {
		_valueFloat = [value floatValue];
	} else if(_mode == MTFormNumberInputCellModeInteger) {
		_valueInteger = [value integerValue];
	} else if(_mode == MTFormNumberInputCellModeUnsigned) {
		_valueInteger = [value unsignedIntegerValue];
	}

	_hasChanged = NO;
	[self fixLimits];
	[self valueChanged];
}

- (void)setMaxValue:(NSNumber *)maxValue {
	_valueIntegerMax = [maxValue integerValue];
	_valueFloatMax = [maxValue floatValue];
	[self fixMinMax];
	[self fixLimits];
}

- (void)setMinValue:(NSNumber *)minValue {
	_valueIntegerMin = [minValue integerValue];
	_valueFloatMin = [minValue floatValue];
	[self fixMinMax];
	[self fixLimits];
}

- (void)fixMinMax {
	if(_valueIntegerMax < _valueIntegerMin) {
		NSInteger tmpInteger = _valueIntegerMax;
		_valueIntegerMax = _valueIntegerMin;
		_valueIntegerMin = tmpInteger;

		CGFloat tmpFloat = _valueFloatMax;
		_valueFloatMax = _valueFloatMin;
		_valueFloatMin = tmpFloat;
	}
}

- (void)fixLimits {
	BOOL needChange = YES;

	if(_mode == MTFormNumberInputCellModeFloat) {
		if (_valueFloat < _valueFloatMin) {
			_valueFloat = _valueFloatMin;
		} else if (_valueFloat > _valueFloatMax) {
			_valueFloat = _valueFloatMax;
		} else {
			needChange =  NO;
		}
	} else if(_mode == MTFormNumberInputCellModeInteger) {
		if (_valueInteger < _valueIntegerMin) {
			_valueInteger = _valueIntegerMin;
		} else if (_valueInteger > _valueIntegerMax) {
			_valueInteger = _valueIntegerMax;
		} else {
			needChange = NO;
		}
	}

	_hasChanged |= needChange;
}

- (void)insertText:(NSString *)text {
	NSInteger numbers = 0;

	// make sure we received an integer (on the iPad a user chan change the keyboard style)
	NSScanner *sc = [NSScanner scannerWithString:text];
	if ([sc scanInteger:NULL]) {
		if ([sc isAtEnd]) {
			numbers = [text integerValue];
		} else {
			return;
		}
	}

	if(_mode == MTFormNumberInputCellModeFloat) {
		_valueFloat *= (10 * text.length);
		_valueFloat += numbers;
	} else {
		_valueInteger *= (10 * text.length);
		_valueInteger += numbers;
	}

	_hasChanged = YES;
	[self fixLimits];
	[self valueChanged];
}

- (void)deleteBackward {
	if(_mode == MTFormNumberInputCellModeFloat) {
		_valueFloat /= 10;
	} else {
		_valueInteger /= 10;
	}

	_hasChanged = YES;
	[self fixLimits];
	[self valueChanged];
}
@end
