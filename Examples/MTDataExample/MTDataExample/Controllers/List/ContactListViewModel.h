//
// Created by Andrey on 23/06/15.
// Copyright (c) 2015 Andrey. All rights reserved.
//

#import <MTLib/MTListViewModel.h>

@interface ContactListViewModel : MTListViewModel
-(NSString *)nameForIndexPath:(NSIndexPath *)indexPath;
-(NSString *)emailForIndexPath:(NSIndexPath *)indexPath;
@end