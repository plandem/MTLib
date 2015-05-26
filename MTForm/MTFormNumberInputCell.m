//
// Created by Andrey on 22/04/15.
// Copyright (c) 2015 Melatonin LLC. All rights reserved.
//

#import "MTFormNumberInputCell.h"

@interface MTFormNumberInputCell()
@property (nonatomic, strong) MTFormNumberInput *numberInput;
@end

@implementation MTFormNumberInputCell

- (void)setUp {
	[super setUp];

	self.numberInput = [[MTFormNumberInput alloc] init];
	self.keyboardType = UIKeyboardTypeNumberPad;
	self.returnKeyType = UIReturnKeyDone;

	__weak MTFormNumberInputCell *weakSelf = self;
	self.numberInput.valueChangedBlock = ^{
		weakSelf.field.value = weakSelf.numberInput.value;
		weakSelf.detailTextLabel.text = [weakSelf.field fieldDescription];
		[weakSelf setNeedsLayout];

		if(weakSelf.field.action) {
			weakSelf.field.action(weakSelf);
		}
	};
}

- (void)update {
	self.textLabel.text = self.field.title;
	self.detailTextLabel.text = [self.field fieldDescription] ?: [self.field.placeholder fieldDescription];

	if ([self.field.type isEqualToString:FXFormFieldTypeFloat]) {
		_numberInput.mode = MTFormNumberInputCellModeFloat;
		self.keyboardType = UIKeyboardTypeDecimalPad;
	} else if ([self.field.type isEqualToString:FXFormFieldTypeInteger]) {
		_numberInput.mode = MTFormNumberInputCellModeInteger;
		self.keyboardType = UIKeyboardTypeNumberPad;
	} else {
		_numberInput.mode = MTFormNumberInputCellModeUnsigned;
		self.keyboardType = UIKeyboardTypeNumberPad;
	}

	self.numberInput.value = self.field.value ?: ([self.field.placeholder isKindOfClass:[NSNumber class]]? self.field.placeholder: @(0));
}

- (void)didSelectWithTableView:(UITableView *)tableView controller:(__unused UIViewController *)controller {
	if (!([self isFirstResponder])) {
		[self becomeFirstResponder];
	} else {
		[self resignFirstResponder];
	}

	[tableView deselectRowAtIndexPath:tableView.indexPathForSelectedRow animated:YES];
}

- (BOOL)canBecomeFirstResponder {
	return YES;
}

- (BOOL)hasText {
	return YES;
}

- (void)insertText:(NSString *)text {
	[self.numberInput performSelector:@selector(insertText:) withObject:text];
}

- (void)deleteBackward {
	[self.numberInput performSelector:@selector(deleteBackward)];
}
@end