//
// Created by Andrey on 23/06/15.
// Copyright (c) 2015 Andrey. All rights reserved.
//

#import <MTLib/UIViewController+MTRouter.h>
#import <MTLib/UIViewController+MTViewModel.h>
#import <MTLib/MTListViewModel+Cache.h>
#import "MainRouter.h"
#import "ContactListViewController.h"
#import "ContactListViewModel.h"
#import "ContactEditViewModel.h"

@interface MainRouter()
@property(nonatomic, strong) MTDataRepository *coreRepository;
@property(nonatomic, strong) MTDataRepository *sqliteRepository;
@property(nonatomic, strong) MTDataRepository *realmRepository;
@end

@implementation MainRouter
-(id)viewModelForViewController:(UIViewController *)viewController {
	MTDataRepository *repository;

	if([viewController isKindOfClass:[ContactListViewController class]]) {
		NSString *type = viewController.navigationController.tabBarItem.title.lowercaseString;

		if ([type isEqual:@"coredata"]) {
			repository = _coreRepository;
		} else if ([type isEqual:@"realm"]) {
			repository = _realmRepository;
		} else if ([type isEqual:@"sqlite"]) {
			repository = _sqliteRepository;
		}

		NSAssert(repository, @"Repository can't be nil.");
		return [[ContactListViewModel alloc] initWithRepository:repository];
	}

	return nil;
}

-(void)showUpdateContactViewControllerFromViewController:(UIViewController *)viewController forIndexPath:(NSIndexPath *)indexPath {
	MTRouterPreparationBlock preparationBlock =  ^void(UIStoryboardSegue *segue) {
		UINavigationController *destination = segue.destinationViewController;
		ContactListViewModel *listViewModel = (id)[segue.sourceViewController viewModel];
		id<MTDataObject> model;

		if(indexPath == nil) {
			//create a new contact
			model = [listViewModel.dataProvider.repository createModel];
		} else {
			//update existing contact
			model = [listViewModel.dataProvider modelAtIndexPath:indexPath];
		}

#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wundeclared-selector"
		[destination.visibleViewController performSelector:@selector(setViewModel:) withObject: [[ContactEditViewModel alloc] initWithModel:model fromRepository:listViewModel.dataProvider.repository]];
#pragma clang diagnostic pop
	};

	[viewController performSegueWithIdentifier:@"ContactEdit" sender:self preparationBlock:preparationBlock];
}
@end