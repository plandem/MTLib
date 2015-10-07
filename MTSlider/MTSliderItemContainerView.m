//
// Created by Alexey Bukhtin on 01.04.15.
// Copyright (c) 2015 Melatonin LLC. All rights reserved.
//

#import "MTSliderItemContainerView.h"

@interface MTSliderItemContainerView ()
@property (nonatomic) CAShapeLayer *pointerLayer;
@end

@implementation MTSliderItemContainerView

@synthesize pointerCenterX = _pointerCenterX;

- (instancetype)initWithItemView:(UIView *)itemView edgeInsets:(UIEdgeInsets)edgeInsets color:(UIColor *)color
{
    // Increase container frame with item view size and edgeInsets.
    CGRect frame = CGRectInset(itemView.frame,
                               (edgeInsets.left + edgeInsets.right) / -2.f,
                               (edgeInsets.top + edgeInsets.bottom) / -2.f);
    
    self = [super initWithFrame:frame];
    
    if (self) {
        self.backgroundColor = color;
        [self addItemView:itemView edgeInsets:edgeInsets];
        self.pointerSize = CGSizeMake(10.f, 5.f);
    }
    
    return self;
}

- (void)addItemView:(UIView *)itemView edgeInsets:(UIEdgeInsets)edgeInsets
{
    // Make item view offset.
    CGRect frame = itemView.frame;
    frame.origin = CGPointMake(edgeInsets.left, edgeInsets.top);
    itemView.frame = frame;
    
    _itemView = itemView;
    [self addSubview:_itemView];
}

- (void)setPointerHidden:(BOOL)pointerHidden
{
    _pointerHidden = pointerHidden;
    [self setupPointer];
}

- (void)setPointerSize:(CGSize)pointerSize
{
    _pointerSize = pointerSize;
    [self setupPointer];
}

- (void)setupPointer
{
    if (_pointerLayer) {
        [_pointerLayer removeFromSuperlayer];
    }
    
    if (_pointerHidden) {
        return;
    }
    
    UIBezierPath *trianglePath = [UIBezierPath bezierPath];
    [trianglePath moveToPoint:CGPointZero];
    [trianglePath addLineToPoint:CGPointMake(_pointerSize.width, 0.f)];
    [trianglePath addLineToPoint:CGPointMake(_pointerSize.width / 2.f, _pointerSize.height)];
    [trianglePath closePath];
    
    _pointerLayer = [CAShapeLayer layer];
    _pointerLayer.path = trianglePath.CGPath;
    _pointerLayer.fillColor = self.backgroundColor.CGColor;
    _pointerLayer.position = CGPointMake((self.bounds.size.width - _pointerSize.width) / 2.f, self.frame.size.height);
    [self.layer addSublayer:_pointerLayer];
}

- (void)setPointerCenterX:(CGFloat)pointerCenterX
{
    CGFloat dX = pointerCenterX - (self.frame.origin.x + self.frame.size.width / 2.f);
    _pointerLayer.position = CGPointMake(_pointerLayer.position.x + dX, _pointerLayer.position.y);
}

@end
