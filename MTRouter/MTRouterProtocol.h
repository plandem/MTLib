//
// Created by Andrey on 10/06/15.
// Copyright (c) 2015 Melatonin LLC. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol MTRouterProtocol <NSObject>
@required
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender;
- (void)dismissViewController:(UIViewController *)viewController animated:(BOOL)animated;

@optional
-(id)viewModelForViewController:(UIViewController *)viewController;
@end