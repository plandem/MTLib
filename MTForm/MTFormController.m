//
// Created by Andrey on 20/04/15.
// Copyright (c) 2015 Andrey Gayvoronsky. All rights reserved.
//

#import "MTFormController.h"
#import "MTFormViewController.h"
#import "MTFormNumberInputCell.h"

@implementation MTFormController

-(instancetype)init {
	if((self = [super init])) {
		[self setup];
	}

	return self;
}

-(void)setup {
	[self registerCellClass:[MTFormNumberInputCell class] forFieldType:FXFormFieldTypeNumber];
	[self registerCellClass:[MTFormNumberInputCell class] forFieldType:FXFormFieldTypeFloat];
	[self registerCellClass:[MTFormNumberInputCell class] forFieldType:FXFormFieldTypeInteger];
	[self registerCellClass:[MTFormNumberInputCell class] forFieldType:FXFormFieldTypeUnsigned];

	[self registerDefaultViewControllerClass:[MTFormViewController class]];
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
	NSString *title = [(id<UITableViewDataSource>)self tableView:tableView titleForHeaderInSection:section];
	if ([title length]) {
		UILabel *label = [[UILabel alloc] initWithFrame:CGRectZero];
		label.text = title;
		label.font = [UIFont fontWithName:[AppTheme fontNameSecondary] size:14.0f];
		label.edgeInsets = UIEdgeInsetsMake(10, 10, 0, 0);
		[label sizeToFit];

		UIView *view = [[UIView alloc] initWithFrame:CGRectMake(0, 0, CGRectGetWidth(tableView.frame), CGRectGetHeight(label.frame))];
		view.backgroundColor = [UIColor clearColor];
		[view addSubview:label];
		return view;
	}

	return nil;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
	return CGRectGetHeight([self tableView:tableView viewForHeaderInSection:section].frame);
}

- (NSInteger)tableView:(UITableView *)tableView indentationLevelForRowAtIndexPath:(NSIndexPath *)indexPath {
	return 1;
}

@end