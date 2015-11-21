//
// Created by Alexey Bukhtin on 01.04.15.
// Copyright (c) 2015 Melatonin LLC. All rights reserved.
//

#import "MTSlider.h"
#import "MTSliderItemContainerView.h"

enum {
	MTSliderControlEventDragging	= 1 << 24,
	MTSliderControlEventDropped		= 1 << 25,
};

@interface MTSlider ()
@property (nonatomic) UIView *allItemViewsContainer;
@property (nonatomic) UIView *itemViewsContainer;
@property (nonatomic) UIView *selectedItemView;
@property (nonatomic) CGFloat thumbImageWidth;
@property (nonatomic) CGFloat itemViewsInternalDistance;
@property (nonatomic) NSUInteger previousIndex;
@end

@implementation MTSlider

#pragma mark - Setup Properties

- (NSUInteger)index
{
    return (NSUInteger)fabsf(roundf(self.value));
}

#pragma mark - Update subviews

- (void)updateItemViews
{
    [self clearAnimation];

    // Clear previous item views.
    if (_allItemViewsContainer) {
        [_allItemViewsContainer removeFromSuperview];
    }

    [self.selectedItemViews makeObjectsPerformSelector:@selector(removeFromSuperview)];

    // Reload item views arrays using callback block.
	[self reloadItemViewsUsingBlock];

    if (_itemViews.count > 1 && _itemViews.count == _selectedItemViews.count) {
        [self setupItemViews];
        [self setValue:self.index animated:NO];
    }
}

- (void)setupItemViews
{
    _allItemViewsContainer = [[UIView alloc] initWithFrame:CGRectMake(0.f, -_itemViewsContainerOffsetY, 0.f, 0.f)];
    [self addSubview:_allItemViewsContainer];

    _itemViewsContainer = [[UIView alloc] initWithFrame:CGRectZero];
    _itemViewsContainer.alpha = 0.f;
    [_allItemViewsContainer addSubview:_itemViewsContainer];

    // Calculate distance between internal item views.
    _thumbImageWidth = [self thumbImageSize].width;
    _itemViewsInternalDistance = (self.frame.size.width - _thumbImageWidth) / (_itemViews.count - 1);

    for (NSUInteger index = 0; index < _itemViews.count; index++) {
        [self updateItemViewFrameAtIndex:index];
    }
}

- (void)setIndex:(NSUInteger)index
{
    if (_itemViews.count) {
        [self setValue:MIN(_itemViews.count - 1, MAX(0, index)) animated:NO];
        [self showSelectedItemView];
    }
}

#pragma mark - Update

- (void)updateItemViewAtIndex:(NSUInteger)index
{
    if (index >= _itemViews.count) {
        return;
    }

    // Remove old item views.
    UIView *itemView = _itemViews[index];
    UIView *selectedItemView = _selectedItemViews[index];
    [itemView removeFromSuperview];
    [selectedItemView removeFromSuperview];

    // Reload item views.
    [self reloadItemViewUsingBlockAtIndex:index];
    [self updateItemViewFrameAtIndex:index];
}

- (void)updateItemViewFrameAtIndex:(NSUInteger)index
{
    UIView *itemView = _itemViews[index];
    UIView *selectedItemView = _selectedItemViews[index];

    // Update item view frame.
    [self updateItemViewFrame:itemView atIndex:index];
    [_itemViewsContainer addSubview:itemView];

    // Update selected item view frame.
    selectedItemView.alpha = 0.f;
    [self updateItemViewFrame:selectedItemView atIndex:index];
    [_allItemViewsContainer addSubview:selectedItemView];

    if (index == self.index) {
        _selectedItemView = selectedItemView;
        _selectedItemView.alpha = 1.f;
    } else {
        selectedItemView.alpha = 0.f;
    }
}

- (void)updateItemViewFrame:(UIView *)itemView atIndex:(NSUInteger)index
{
    CGRect frame = itemView.frame;
    frame.origin.y = -frame.size.height;

    // Calculate offsetX.
    CGFloat baseX = floorf(index * _itemViewsInternalDistance - itemView.frame.size.width / 2.f + _thumbImageWidth / 2.f);
    CGFloat x = baseX;

    // Reset offsetX for first item view, if item view width greater thumb image width.
    if (!index && itemView.frame.size.width > _thumbImageWidth) {
        x = 0.f;
    }

    // Calculate offsetX for last item view, if item view width greater thumb image width.
    if ((index + 1) == _itemViews.count && itemView.frame.size.width > _thumbImageWidth) {
        x = self.frame.size.width - frame.size.width;
    }

    frame.origin.x = x;
    itemView.frame = frame;

    if ([itemView conformsToProtocol:@protocol(MTSlideItemContainerProtocol)]) {
        ((UIView <MTSlideItemContainerProtocol> *)itemView).pointerCenterX = baseX + itemView.frame.size.width / 2.f;
    }
}

- (CGSize)thumbImageSize
{
    if (self.currentThumbImage) {
        return self.currentThumbImage.size;
    }

    return [self thumbRectForBounds:self.bounds trackRect:[self trackRectForBounds:self.bounds] value:0].size;
}

- (void)reloadItemViewsUsingBlock
{
	if(!_itemViewsBlock) {
		[self setupDefaultItemsView];
	}

    NSMutableArray *itemViews = [NSMutableArray array];
    NSMutableArray *selectedItemViews = [NSMutableArray array];
    NSUInteger itemsCount = (NSUInteger)fabsf(floorf(self.maximumValue));

    for (NSUInteger index = 0; index <= itemsCount; index++) {
        UIView *itemView = _itemViewsBlock(self, index, NO) ?: [[UIView alloc] initWithFrame:CGRectZero];
        UIView *selectedItemView = _itemViewsBlock(self, index, YES) ?: [[UIView alloc] initWithFrame:CGRectZero];

        [itemViews addObject:itemView];
        [selectedItemViews addObject:selectedItemView];
    }

    self.itemViews = itemViews;
    self.selectedItemViews = selectedItemViews;
}

- (void)reloadItemViewUsingBlockAtIndex:(NSUInteger)index
{
	if(!_itemViewsBlock) {
		[self setupDefaultItemsView];
	}

	NSMutableArray *itemViews = [NSMutableArray arrayWithArray:_itemViews];
    NSMutableArray *selectedItemViews = [NSMutableArray arrayWithArray:_selectedItemViews];

    UIView *itemView = _itemViewsBlock(self, index, NO) ?: [[UIView alloc] initWithFrame:CGRectZero];
    UIView *selectedItemView = _itemViewsBlock(self, index, YES) ?: [[UIView alloc] initWithFrame:CGRectZero];

    itemViews[index] = itemView;
    selectedItemViews[index] = selectedItemView;

    self.itemViews = itemViews;
    self.selectedItemViews = selectedItemViews;
}

#pragma mark - Events

- (BOOL)beginTrackingWithTouch:(UITouch *)touch withEvent:(UIEvent *)event
{
    BOOL beginTracking = [super beginTrackingWithTouch:touch withEvent:event];

    if (beginTracking) {
        [self showItemViews];
    }

    return beginTracking;
}

- (void)endTrackingWithTouch:(UITouch *)touch withEvent:(UIEvent *)event
{
    [super endTrackingWithTouch:touch withEvent:event];
    [self showSelectedItemView];
	[self sendActionsForControlEvents:UIControlEventApplicationReserved & MTSliderControlEventDropped];
}

- (void)showSelectedItemView
{
	[self clearAnimation];

    NSUInteger index = self.index;
    _selectedItemView.alpha = 0.f;

    if (_selectedItemViews.count > index) {
        _selectedItemView = _selectedItemViews[index];
    } else {
        _selectedItemView = nil;
    }

    if (!_showSelectedItemViewAnimationBlock) {
        [self setupDefaultAnimation];
    }

    _showSelectedItemViewAnimationBlock(self, _selectedItemView, _itemViewsContainer);

    [self setValue:index animated:YES];
    [self sendActionsForControlEvents:UIControlEventValueChanged];
}

- (void)showItemViews
{
    [self clearAnimation];

    if (!_hideSelectedItemViewAnimationBlock) {
        [self setupDefaultAnimation];
    }

    _hideSelectedItemViewAnimationBlock(self, _selectedItemView, _itemViewsContainer);
}

- (void)clearAnimation
{
    [CATransaction begin];
    [_itemViewsContainer.layer removeAllAnimations];
    [_selectedItemView.layer removeAllAnimations];
    _itemViewsContainer.transform = CGAffineTransformIdentity;
    _selectedItemView.transform = CGAffineTransformIdentity;
    [CATransaction commit];
}

- (void)setupDefaultAnimation
{
    if (!_showSelectedItemViewAnimationBlock) {
        _showSelectedItemViewAnimationBlock = ^(MTSlider *slider, UIView *selectedItemView, UIView *itemViewsContainer) {
            selectedItemView.alpha = 0.f;
            selectedItemView.transform = CGAffineTransformMakeScale(0.01f, 0.01f);

            [UIView animateWithDuration:0.3
                                  delay:0.0
                 usingSpringWithDamping:0.6f
                  initialSpringVelocity:0.0f
                                options:0
                             animations:^{
                                 itemViewsContainer.alpha = 0.f;
                                 selectedItemView.transform = CGAffineTransformIdentity;
                                 selectedItemView.alpha = 1.f;
                             } completion:NULL];
        };
    }

    if (!_hideSelectedItemViewAnimationBlock) {
        _hideSelectedItemViewAnimationBlock = ^(MTSlider *slider, UIView *selectedItemView, UIView *itemViewsContainer) {
            itemViewsContainer.alpha = 0.f;

            [UIView animateWithDuration:0.4
                                  delay:0.0
                 usingSpringWithDamping:1.0f
                  initialSpringVelocity:0.0f
                                options:0
                             animations:^{
                                 itemViewsContainer.alpha = 1.f;
                                 selectedItemView.transform = CGAffineTransformMakeScale(0.01f, 0.01f);
                                 selectedItemView.alpha = 0.f;

                             } completion:^(BOOL finished) {
                                 if (finished) {
                                     itemViewsContainer.alpha = 1.f;
                                     selectedItemView.transform = CGAffineTransformIdentity;
                                 }
                             }];
        };
    }
}

-(void)setupDefaultItemsView {
	UIView* (^render)(MTSlider *slider, NSUInteger index, BOOL selected) = ^UIView *(MTSlider *slider, NSUInteger index, BOOL selected) {
		UILabel *label = [[UILabel alloc] initWithFrame:CGRectZero];

		label.textAlignment = NSTextAlignmentCenter;
		label.font = [UIFont systemFontOfSize:18.0f];
		label.text = [NSString stringWithFormat:@"%d", index];
		[label sizeToFit];

		if (selected) {
			label.textColor = [UIColor whiteColor];

			MTSliderItemContainerView *container = [[MTSliderItemContainerView alloc] initWithItemView:label edgeInsets:UIEdgeInsetsMake(4.f, 6.f, 0.f, 6.f) color:self.tintColor];
			container.layer.cornerRadius = 3.f;
			return container;
		}

		return label;

	};

	_itemViewsBlock = render;
}

- (instancetype)initWithFrame:(CGRect)frame {
	if ((self = [super initWithFrame:frame]))
		[self setup];

	return self;
}

- (instancetype)initWithCoder:(NSCoder *)aDecoder {
	if ((self = [super initWithCoder:aDecoder]))
		[self setup];

	return self;
}

- (void)setup {
	_previousIndex = UINT_MAX;
	self.continuous = YES;
	[self addTarget:self action:@selector(onValueChanged:) forControlEvents:UIControlEventValueChanged];
	[self addTarget:self action:@selector(onIndexChangedWithDragging) forControlEvents:UIControlEventApplicationReserved & MTSliderControlEventDragging];
	[self addTarget:self action:@selector(onIndexChangedWithDropping) forControlEvents:UIControlEventApplicationReserved & MTSliderControlEventDropped];
}

- (void)onIndexChangedWithDragging {
	if(_onIndexChangeBlock) {
		_onIndexChangeBlock(self, self.index, YES);
	}
}

- (void)onIndexChangedWithDropping {
	if(_onIndexChangeBlock) {
		_onIndexChangeBlock(self, self.index, NO);
	}
}

- (void)onValueChanged:(id)sender {
	NSUInteger index = self.index;

	if (_previousIndex != index) {
		_previousIndex = index;
		[self sendActionsForControlEvents:UIControlEventApplicationReserved & MTSliderControlEventDragging];
	}
}

-(void)setBounds:(CGRect)bounds {
    [super setBounds:bounds];
    [self updateItemViews];
}
@end
