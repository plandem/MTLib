//
// Created by Andrey on 15/06/15.
// Copyright (c) 2015 Melatonin LLC. All rights reserved.
//

#import <objc/runtime.h>
#import "MTListViewModel+Cache.h"

@implementation MTListViewModel (Cache)
-(NSIndexPath *)currentIndexPath {
	return objc_getAssociatedObject(self, @selector(currentIndexPath));
}

-(void)setCurrentIndexPath:(NSIndexPath *)indexPath {
	objc_setAssociatedObject(self, @selector(currentIndexPath), indexPath, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

-(id<MTDataObject>)currentModel {
	return objc_getAssociatedObject(self, @selector(currentModel));
}

-(void)setCurrentModel:(id<MTDataObject>)model {
	objc_setAssociatedObject(self, @selector(currentModel), model, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

-(id<MTDataObject>)modelAtIndexPath:(NSIndexPath *)indexPath {
	if(indexPath == nil) {
		//reset cached model
		[self setCurrentModel:nil];
		[self setCurrentIndexPath:nil];
		return nil;
	} else if([indexPath isEqual:[self currentIndexPath]]) {
		//return already cached model
		return [self currentModel];
	}

	// refresh cached model and return it
	[self setCurrentModel:[self.dataProvider modelAtIndexPath:indexPath]];
	[self setCurrentIndexPath:[indexPath copy]];
	return [self currentModel];
}
@end