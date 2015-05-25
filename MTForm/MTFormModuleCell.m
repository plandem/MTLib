//
// Created by Andrey Gayvoronsky on 8/18/14.
// Copyright (c) 2014 Andrey Gayvoronsky. All rights reserved.
//

#import "MTFormModuleCell.h"

@interface MTFormModuleCell ()
@property (nonatomic, strong) UILabel *title;
@property (nonatomic, strong) UIImageView *icon;
@end

@implementation MTFormModuleCell

-(void)setUp {
	UILabel *title = [[UILabel alloc] initWithFrame:CGRectZero];
	title.font = MTFormTextFont;

	UIImageView *icon = [[UIImageView alloc] initWithFrame:CGRectZero];
	icon.contentMode = UIViewContentModeScaleAspectFit;
	icon.clipsToBounds = YES;
	[self.contentView addSubview:icon];
	[self.contentView addSubview:title];

	@weakify(self);
	[icon mas_makeConstraints:^(MASConstraintMaker *make) {
		@strongify(self);
		make.width.equalTo(@24);
		make.height.equalTo(@24);
		make.centerY.equalTo(icon.superview);
		make.left.equalTo(icon.superview).offset(self.indentationLevel * self.indentationWidth);
	}];

	[title mas_makeConstraints:^(MASConstraintMaker *make) {
		@strongify(self);
		make.centerY.equalTo(title.superview);
		make.left.equalTo(icon.mas_right).offset(10);
	}];

	self.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
	self.selectionStyle = UITableViewCellSelectionStyleDefault;
	self.icon = icon;
	self.title = title;
}

-(void)update {
	self.title.text = self.field.title;
	[self.title sizeToFit];

	self.icon.image = [AppTheme imageNamed:[NSString stringWithFormat:@"event-small-%@", self.field.placeholder]];

	@weakify(self);
	[self.icon mas_updateConstraints:^(MASConstraintMaker *make) {
		@strongify(self);
		make.left.equalTo(self.icon.superview).offset(self.indentationLevel * self.indentationWidth);
	}];

	[self setNeedsLayout];
}
@end