//
// Created by Andrey on 02/06/15.
// Copyright (c) 2015 Melatonin LLC. All rights reserved.
//

#import <ReactiveCocoa/ReactiveCocoa.h>
#import <ReactiveViewModel/ReactiveViewModel.h>
#import "MTDataProvider.h"

@interface MTListViewModel : RVMViewModel
@property (nonatomic, readonly) RACSignal *updatedContentSignal;
@property (nonatomic, readonly) MTDataProvider *dataProvider;
@property (nonatomic, assign) BOOL refreshOnChanges;

-(id)initWithRepository:(MTDataRepository *)repository;
-(void)deleteAtIndexPath:(NSIndexPath *)indexPath;
-(void)moveFromIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath;
-(id)createViewModel:(Class)viewModelClass forIndexPath:(NSIndexPath *)indexPath;

-(NSInteger)numberOfSections;
-(NSInteger)numberOfItemsInSection:(NSInteger)section;

-(void)reload;
@end