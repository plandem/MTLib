//
// Created by Andrey on 20/09/14.
// Copyright (c) 2015 Melatonin LLC. All rights reserved.
//

#import "MTTagViewDropZoneWrapper.h"

@implementation MTTagViewDropZoneWrapper
- (id)initWithView:(UIView *)view {
	if((self = [super init]))
		self.view = view;

	return self;
}

-(void)setup {
}

- (BOOL)isActive:(AtkDragAndDropManager *)manager point:(CGPoint)point {
	return [self.view isActiveDropZone:manager point:point];
}

- (BOOL)shouldDragStart:(AtkDragAndDropManager *)manager {
	return YES;
}

- (BOOL)isInterested:(AtkDragAndDropManager *)manager {
	return YES;
}

- (void)dragEnded:(AtkDragAndDropManager *)manager {
	[self performSelector:@selector(delayEnd) withObject:nil afterDelay:0.4];
}

- (void)delayEnd {
}

@end