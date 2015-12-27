//
// Created by Andrey on 27/12/15.
// Copyright (c) 2015 Melatonin LLC. All rights reserved.
//

#import "MTStyleKitAppearancePatch.h"
#import "UIView+Inspectable.h"
#import "UILabel+EdgeInsets.h"

NSString *const MTCornerRadiusAttributeName = @"MTCornerRadiusAttributeName";
NSString *const MTBorderWidthAttributeName = @"MTBorderWidthAttributeName";
NSString *const MTBorderColorAttributeName = @"MTBorderColorAttributeName";
NSString *const MTEdgeInsetsAttributeName = @"MTEdgeInsetsAttributeName";
NSString *const MTOpaqueAttributeName = @"MTOpaqueAttributeName";
NSString *const MTTextAlignmentAttributeName = @"MTTextAlignmentAttributeName";

@implementation UIView (MTStyleKitAppearancePatch)
- (void)setAttributes:(NSDictionary *)attributes {
	NSNumber *cornerRadius = attributes[MTCornerRadiusAttributeName];
	if(cornerRadius) {
		self.cornerRadius = [cornerRadius floatValue];
	}

	NSNumber *borderWidth = attributes[MTBorderWidthAttributeName];
	if(borderWidth) {
		self.borderWidth = [borderWidth floatValue];
	}

	UIColor *borderColor = attributes[MTBorderColorAttributeName];
	if(borderWidth) {
		self.borderColor = borderColor;
	}

	UIColor *backgroundColor = attributes[NSBackgroundColorAttributeName];
	if (backgroundColor) {
		self.backgroundColor = backgroundColor;
	}

	NSNumber *opaque = attributes[MTOpaqueAttributeName];
	if(opaque) {
		self.opaque = [opaque boolValue];
	}
}
@end

@implementation UIButton (MTStyleKitAppearancePatch)
- (void)setTitleLabelFont:(UIFont *)font {
	self.titleLabel.font = font;
	[self sizeToFit];
}

@end

@implementation UILabel (MTStyleKitAppearancePatch)
- (void)setAttributes:(NSDictionary *)attributes {
	[super setAttributes:attributes];

	UIFont *font = attributes[NSFontAttributeName];
	if (font) {
		self.font = font;
	}

	UIColor *textColor = attributes[NSForegroundColorAttributeName];
	if (textColor) {
		self.textColor = textColor;
	}

	NSShadow *shadow = attributes[NSShadowAttributeName];
	if (shadow) {
		self.shadowColor = shadow.shadowColor;
		self.shadowOffset = shadow.shadowOffset;
	}

	NSValue *edgeInsets = attributes[MTEdgeInsetsAttributeName];
	if(edgeInsets) {
		self.edgeInsets = [edgeInsets UIEdgeInsetsValue];
	}

	NSNumber *textAlignment = attributes[MTTextAlignmentAttributeName];
	if(textAlignment) {
		self.textAlignment = (NSTextAlignment)[textAlignment integerValue];
	}
}
@end
