//
// Created by Andrey on 16/06/15.
// Copyright (c) 2015 Melatonin LLC. All rights reserved.
//

#import "MTFormDateValueTransformer.h"

@interface MTFormDateValueTransformer()
@property (nonatomic, strong) NSDateFormatter *dateFormatter;
@end

@implementation MTFormDateValueTransformer
-(instancetype)initWithFormat:(NSString *)format {
	if((self = [super init])) {
		_dateFormatter = [[NSDateFormatter alloc] init];
		[_dateFormatter setDateFormat:format];
	}

	return self;
}

+ (Class)transformedValueClass {
	return [NSString class];
}

+ (BOOL)allowsReverseTransformation {
	return NO;
}

- (id)transformedValue:(id)value {
	return value? [_dateFormatter stringFromDate: value]: nil;
}

-(NSDateFormatter *)dateFormatter {
	if(_dateFormatter == nil) {
		_dateFormatter = [[NSDateFormatter alloc] init];
		[_dateFormatter setDateFormat:@"yyyy-MM-dd hh:mm a"];
	}

	return _dateFormatter;
}
@end