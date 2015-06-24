//
//  ContactListViewController.m
//  MTDataExample
//
//  Created by Andrey on 23/06/15.
//  Copyright (c) 2015 Andrey. All rights reserved.
//

#import "MainRouterProtocol.h"
#import "ContactListViewController.h"
#import "ContactListViewModel.h"

@interface ContactListViewController ()
@property(nonatomic, strong) id<MainRouterProtocol> router;
@property(nonatomic, strong) ContactListViewModel *viewModel;
@end

@implementation ContactListViewController
@dynamic viewModel;
@dynamic router;

-(void)viewDidLoad {
	[super viewDidLoad];
}
-(void)reload {
	NSLog(@"%@ updated. reloading...", self.viewModel.dataProvider);
	[self.tableView reloadData];
}

-(IBAction)createContact:(id)sender {
	[self.router showUpdateContactViewControllerFromViewController:self forIndexPath:nil];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
	return [self.viewModel numberOfItemsInSection:section];
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
	return [self.viewModel numberOfSections];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
	UITableViewCell *cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"cell"];

	cell.textLabel.text = [self.viewModel nameForIndexPath:indexPath];
	cell.detailTextLabel.text = [self.viewModel emailForIndexPath:indexPath];

	return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
	[self.router showUpdateContactViewControllerFromViewController:self forIndexPath:indexPath];
}
@end
