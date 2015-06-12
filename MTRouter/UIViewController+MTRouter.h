//
// Created by Andrey on 10/06/15.
// Copyright (c) 2015 Melatonin LLC. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol MTRouterProtocol;

typedef void (^MTRouterPreparationBlock)(UIStoryboardSegue *segue);

@interface UIViewController (MTRouter)
@property (nonatomic, strong, readonly) id <MTRouterProtocol> router;

-(void)performSegueWithIdentifier:(NSString *)identifier sender:(id)sender preparationBlock:(MTRouterPreparationBlock)block;
-(MTRouterPreparationBlock)preparationBlockForSegue:(UIStoryboardSegue *)segue;

@end