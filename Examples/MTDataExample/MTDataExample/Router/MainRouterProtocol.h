//
// Created by Andrey on 23/06/15.
// Copyright (c) 2015 Andrey. All rights reserved.
//

#import <MTLib/MTRouterProtocol.h>

@protocol MainRouterProtocol <MTRouterProtocol>
-(void)showUpdateContactViewControllerFromViewController:(UIViewController *)viewController forIndexPath:(NSIndexPath *)indexPath;
@end