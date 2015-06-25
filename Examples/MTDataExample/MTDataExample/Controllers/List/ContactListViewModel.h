//
// Created by Andrey on 23/06/15.
// Copyright (c) 2015 Andrey. All rights reserved.
//

#import <MTLib/MTListViewModel.h>

@protocol ContactListViewModel
-(NSString *)nameForIndexPath:(NSIndexPath *)indexPath;
-(NSString *)emailForIndexPath:(NSIndexPath *)indexPath;
@end

@interface ContactListViewModel : MTListViewModel <ContactListViewModel>
@end