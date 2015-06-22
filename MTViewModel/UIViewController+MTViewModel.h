//
// Created by Andrey on 19/06/15.
// Copyright (c) 2015 Melatonin LLC. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <ReactiveViewModel/ReactiveViewModel.h>

@interface UIViewController (MTViewModel)
@property (nonatomic, strong, readonly) RVMViewModel *viewModel;
-(void)reload;
@end