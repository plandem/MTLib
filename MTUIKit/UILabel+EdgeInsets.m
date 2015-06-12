//
// Created by Andrey on 26/04/15.
// Copyright (c) 2015 Melatonin LLC. All rights reserved.
//

#import <objc/runtime.h>
#import "NSObject+Swizzle.h"
#import "UILabel+EdgeInsets.h"

@implementation UILabel (EdgeInsets)
@dynamic edgeInsets;

+ (void)load {
	[self swizzleInstanceSelector:@selector(drawTextInRect:) withNewSelector:@selector(swizzle_drawTextInRect:)];
	[self swizzleInstanceSelector:@selector(textRectForBounds:limitedToNumberOfLines:) withNewSelector:@selector(swizzle_textRectForBounds:limitedToNumberOfLines:)];
}

-(UIEdgeInsets)edgeInsets {
	NSValue *edgeValue = (NSValue *)objc_getAssociatedObject(self, @selector(edgeInsets));
	return (edgeValue ? [edgeValue UIEdgeInsetsValue] : UIEdgeInsetsMake(0, 0, 0, 0));
}

- (void)setEdgeInsets:(UIEdgeInsets)edge {
	NSValue *edgeValue = [NSValue valueWithUIEdgeInsets:edge];
	objc_setAssociatedObject(self, @selector(edgeInsets), edgeValue, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (void)swizzle_drawTextInRect:(CGRect)rect {
	[self swizzle_drawTextInRect:UIEdgeInsetsInsetRect(rect, self.edgeInsets)];
}

- (CGRect)swizzle_textRectForBounds:(CGRect)bounds limitedToNumberOfLines:(NSInteger)numberOfLines {
	UIEdgeInsets insets = self.edgeInsets;
	CGRect rect = [self  swizzle_textRectForBounds:UIEdgeInsetsInsetRect(bounds, insets) limitedToNumberOfLines:numberOfLines];

	rect.origin.x    -= insets.left;
	rect.origin.y    -= insets.top;
	rect.size.width  += (insets.left + insets.right);
	rect.size.height += (insets.top + insets.bottom);

	return rect;
}
@end