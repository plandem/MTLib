//
// Created by Andrey on 22/04/15.
// Copyright (c) 2015 Andrey Gayvoronsky. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef NS_OPTIONS(NSInteger, MTFormNumberInputMode) {
	MTFormNumberInputCellModeFloat,
	MTFormNumberInputCellModeInteger,
	MTFormNumberInputCellModeUnsigned,
};

typedef void (^MTFormNumberInputValueChangedBlock)();

@interface MTFormNumberInput : NSObject
@property (nonatomic, assign) MTFormNumberInputMode mode;
@property (nonatomic, weak) NSNumber *value;
@property (nonatomic, weak) NSNumber *maxValue;
@property (nonatomic, weak) NSNumber *minValue;
@property (nonatomic, copy) MTFormNumberInputValueChangedBlock valueChangedBlock;
@end
