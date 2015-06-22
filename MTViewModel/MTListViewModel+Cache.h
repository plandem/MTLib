//
// Created by Andrey on 15/06/15.
// Copyright (c) 2015 Melatonin LLC. All rights reserved.
//

#import "MTListViewModel.h"

@interface MTListViewModel (Cache)
-(id<MTDataObject>)modelAtIndexPath:(NSIndexPath *)indexPath;
@end