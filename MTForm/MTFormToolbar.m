//
// Created by Andrey on 22/04/15.
// Copyright (c) 2015 Andrey Gayvoronsky. All rights reserved.
//

#import "MTFormToolbar.h"

@interface MTFormToolbar ()
@property (nonatomic, strong) UILabel *titleLabel;
@property (nonatomic, strong) UIBarButtonItem *closeButton;
@property (nonatomic, strong) UIBarButtonItem *titleButton;
@end

@implementation MTFormToolbar {
	NSMutableArray *_toolbarItems;
}

-(instancetype)initWithCoder:(NSCoder *)decoder {
	if((self = [super initWithCoder:decoder])) {
		[self setUp];
	}

	return self;
}

-(instancetype)initWithFrame:(CGRect)frame {
	if((self = [super initWithFrame:frame])) {
		[self setUp];
	}

	return self;
}

-(void)setUp {
	self.translucent = YES;
	self.barStyle = UIBarStyleBlack;
	self.autoresizingMask = UIViewAutoresizingFlexibleHeight;
	self.userInteractionEnabled = YES;
	self.exclusiveTouch = YES;

	[self sizeToFit];

	_toolbarItems = [[NSMutableArray alloc] initWithCapacity: 4];

	_titleLabel = [[UILabel alloc] initWithFrame:CGRectZero];
	[_titleLabel setFont: [UIFont italicSystemFontOfSize: [UIFont systemFontSize]]];
	[_titleLabel setBackgroundColor: [UIColor clearColor]];
	[_titleLabel setTextColor: [UIColor whiteColor]];
	[_titleLabel setTextAlignment: NSTextAlignmentCenter];
	[_titleLabel setAutoresizingMask: UIViewAutoresizingFlexibleWidth];

	_titleButton = [[UIBarButtonItem alloc] initWithCustomView: _titleLabel];
	_closeButton = [[UIBarButtonItem alloc] initWithCustomView: nil];
	UIBarButtonItem *spacerLeft = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil];
	UIBarButtonItem *spacerRight = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil];

	[_toolbarItems addObject:spacerLeft];
	[_toolbarItems addObject:_titleButton];
	[_toolbarItems addObject:spacerRight];
	[_toolbarItems addObject:_closeButton];
	[self refresh:YES];
}

-(void)onCloseButtonAction:(UIBarButtonItem *)sender {
	self.action();
}

-(void)refresh:(BOOL)replace {
	if(replace) {
		[self setItems:_toolbarItems];
	}

	self.hidden = (![[_titleLabel text] length] && [_closeButton action] == nil);
}

-(void)setValue:(id)value forUndefinedKey:(NSString *)key {
	if([key isEqualToString:@"title"]) {
		if([value isKindOfClass:[NSString class]]) {
			//change text of title
			[_titleLabel setText:value];
			[_titleLabel sizeToFit];
			[self refresh:NO];
		} else if([value isKindOfClass:[UILabel class]]) {
			//replace label of title
			UIBarButtonItem *previous = _titleButton;
			_titleButton  = [[UIBarButtonItem alloc] initWithCustomView:value];
			_titleLabel = (UILabel *)value;
			_toolbarItems[[_toolbarItems indexOfObject:previous]] = _titleButton;
			[self refresh:YES];
		} else {
			NSAssert(false, ([NSString stringWithFormat:@"Unsupported type for key %@", key]));
		}
	} else if([key isEqualToString:@"button"]) {
		UIBarButtonItem *previous = _closeButton;
		BOOL hidden = NO;

		if([value isKindOfClass:[NSString class]]) {
			//change title for 'close'
			_closeButton  = [[UIBarButtonItem alloc] initWithTitle:(NSString *)value style:UIBarButtonItemStyleDone target:nil action:nil];
			hidden = ![(NSString *)value length];
		} else if([value isKindOfClass:[UIBarButtonItem class]]) {
			//replace 'close' with own button
			_closeButton  = value;
		} else if([value isKindOfClass:[NSNumber class]]) {
			//change style for 'close'
			_closeButton  = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:(UIBarButtonSystemItem)[(NSNumber *) value integerValue] target:nil action:nil];
		} else {
			NSAssert(false, ([NSString stringWithFormat:@"Unsupported type for key %@", key]));
		}

		if(hidden) {
			_closeButton.target = nil;
			_closeButton.action = nil;
		} else {
			_closeButton.target = self;
			_closeButton.action = @selector(onCloseButtonAction:);
		}

		_toolbarItems[[_toolbarItems indexOfObject:previous]] = _closeButton;
		[self refresh:YES];
	} else {
		[super setValue:value forUndefinedKey:key];
	}
}

-(void)touchesBegan:(NSSet*)touches withEvent:(UIEvent*)event {
	//let's just cancel any touches at toolbar, we don't any, but closeButton must work.
	[self touchesCancelled:touches withEvent:event];
};
@end