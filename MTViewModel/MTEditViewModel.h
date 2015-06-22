//
// Created by Andrey on 15/06/15.
// Copyright (c) 2015 Melatonin LLC. All rights reserved.
//

#import <ReactiveCocoa/ReactiveCocoa.h>
#import <ReactiveViewModel/ReactiveViewModel.h>
#import "MTDataRepository.h"
#import "MTForm.h"

@interface MTEditViewModel : RVMViewModel <FXForm>
@property (nonatomic, strong, readonly) MTDataRepository *dataRepository;
@property (nonatomic, strong, readonly) id<MTDataObject> model;
@property (nonatomic, assign, readonly) BOOL isValid;

-(id)initWithModel:(id<MTDataObject>)model fromRepository:(MTDataRepository *)repository;
-(void)save;
-(void)cancel;
-(void)setup;
-(void)setupValidator;
@end