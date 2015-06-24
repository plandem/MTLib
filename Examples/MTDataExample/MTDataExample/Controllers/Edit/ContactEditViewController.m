//
// Created by Andrey on 23/06/15.
// Copyright (c) 2015 Andrey. All rights reserved.
//

#import "ContactEditViewController.h"
#import "ContactEditViewModel.h"
#import "MainRouterProtocol.h"

@interface ContactEditViewController () <FXFormControllerDelegate>
@property(nonatomic, strong) id<MainRouterProtocol> router;
@property(nonatomic, strong) ContactEditViewModel *viewModel;
@property (strong, nonatomic) IBOutlet UIBarButtonItem *saveButton;
@property (nonatomic, strong) FXFormController *formController;
@end

@implementation ContactEditViewController
@dynamic viewModel;
@dynamic router;

-(void)viewDidLoad {
	[super viewDidLoad];

	self.formController = [[MTFormController alloc] init];
	self.formController.tableView = self.tableView;
	self.formController.delegate = self;
	self.formController.form = self.viewModel;

	RAC(self.saveButton, enabled) = RACObserve(self.viewModel, isValid);
}

- (void)viewWillAppear:(BOOL)animated {
	[super viewWillAppear:animated];
	[self.tableView reloadData];
}

-(IBAction)onSave:(id)sender {
	[self.viewModel save];
	[self.router dismissViewController:self animated:YES];
}

-(IBAction)onCancel:(id)sender {
	[self.viewModel cancel];
	[self.router dismissViewController:self animated:YES];
}
@end