//
// Created by Andrey on 16/06/15.
// Copyright (c) 2015 Melatonin LLC. All rights reserved.
//

#import <objc/runtime.h>
#import <MTLib/NSObject+Swizzle.h>
#import "UITextView+Underline.h"

@implementation UITextView (Underline)
+(void)load {
	[self swizzleInstanceSelector:@selector(drawRect:) withNewSelector:@selector(swizzle_drawRect:)];
}

-(BOOL)underlineText {
	return [objc_getAssociatedObject(self, @selector(underlineText)) boolValue];
}

- (void)setUnderlineText:(BOOL)underline {
	if(underline) {
		self.contentMode = UIViewContentModeRedraw;
	}

	objc_setAssociatedObject(self, @selector(underlineText), @(underline), OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

-(UIColor *)underlineColor {
	UIColor *underlineColor = objc_getAssociatedObject(self, @selector(underlineColor));

	if(underlineColor == nil) {
		[self setUnderlineColor:[UIColor lightGrayColor]];
	}

	return underlineColor;
}

- (void)setUnderlineColor:(UIColor *)underlineColor {
	if(underlineColor) {
		self.contentMode = UIViewContentModeRedraw;
		objc_setAssociatedObject(self, @selector(underlineColor), underlineColor, OBJC_ASSOCIATION_COPY_NONATOMIC);
	}
}

- (void)swizzle_drawRect:(CGRect)rect {
	[self swizzle_drawRect:rect];

	//Get the current drawing context
	CGContextRef context = UIGraphicsGetCurrentContext();

	CGFloat lineWidth = 0.2f;
	//Set the line color and width
	CGContextSetStrokeColorWithColor(context, [self underlineColor].CGColor);
	CGContextSetLineWidth(context, 0.2f);

	//Start a new Path
	CGContextBeginPath(context);

	//Find the number of lines in our textView + add a bit more height to draw lines in the empty part of the view
	NSUInteger numberOfLines = (NSUInteger)((self.contentSize.height + self.bounds.size.height) / self.font.leading);

	//Set the line offset from the baseline. (I'm sure there's a concrete way to calculate this.)
	CGFloat baselineOffset = 6.0f;

	//iterate over numberOfLines and draw each line
	for (int line = 1; line < numberOfLines; line++) {
		//0.5f offset lines up line with pixel boundary
		CGFloat lineY = self.font.leading * line + lineWidth / 2 + baselineOffset;
		CGContextMoveToPoint(context, self.bounds.origin.x, lineY);
		CGContextAddLineToPoint(context, self.bounds.size.width, lineY);
	}

	//Close our Path and Stroke (draw) it
	CGContextClosePath(context);
	CGContextStrokePath(context);
}
@end