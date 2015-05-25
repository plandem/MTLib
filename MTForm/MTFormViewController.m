//
// Created by Andrey on 21/04/15.
// Copyright (c) 2015 Andrey Gayvoronsky. All rights reserved.
//

#import "MTFormViewController.h"

@implementation MTFormViewController

-(NSInteger)tableView:(UITableView *)tableView indentationLevelForRowAtIndexPath:(NSIndexPath *)indexPath {
	return [(id<UITableViewDelegate>)self.formController.parentFormController tableView:tableView indentationLevelForRowAtIndexPath:indexPath];
}
@end