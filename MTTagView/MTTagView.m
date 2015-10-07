//
// Created by Andrey on 17/09/14.
// Copyright (c) 2015 Melatonin LLC. All rights reserved.
//

#import <objc/runtime.h>
#import <libextobjc/extobjc.h>
#import <AtkDragAndDrop/AtkDragAndDrop.h>
#import "UIImage+Addons.h"
#import "MTLogger.h"
#import "MTTagView.h"
#import "MTTagViewDropZoneWrapper.h"
#import "MTTagViewSourceWrapper.h"

const NSInteger SECTION_FLAG_ID	= 0x100000;
const NSInteger TAG_FLAG_ID		= 0x200000;

@interface TagScrollView: UIScrollView
@end

@implementation TagScrollView
- (BOOL)touchesShouldCancelInContentView:(UIView *)view {
	return YES;
}
@end

@interface MTTagView () <AtkDragAndDropManagerDelegate, UIGestureRecognizerDelegate>
@property (nonatomic, assign) NSInteger selectedSection;
@property (nonatomic, strong) AtkDragAndDropManager *dragAndDropManager;
@property (nonatomic, strong) UIView *headerView;
@property (nonatomic, strong) UIView *footerView;
@property (nonatomic, strong) UIScrollView *sectionTitleView;
@property (nonatomic, strong) UIScrollView *sectionTagsViews;
@property (nonatomic) NSUInteger totalSection;
@property (nonatomic) NSUInteger totalTags;
@property (nonatomic) BOOL sectionMustBeShown;
@property (nonatomic) BOOL sourceDropped;
@property (nonatomic, strong) NSInvocation *sectionRender;
@property (nonatomic, strong) NSArray *dropZones;
@property (nonatomic) CGSize offsetSize;
@property (nonatomic, strong) NSLayoutConstraint *heightConstraint;
@property (strong, nonatomic) UIPanGestureRecognizer *sectionSwipe;
@property (nonatomic) NSIndexPath *indexPathForDragSource;
@property (nonatomic) CGPoint pointForDragSource;
@end

@implementation MTTagView
- (instancetype)init {
	if ((self = [super init]))
		[self setup];

	return self;
}

- (instancetype)initWithCoder:(NSCoder *)aDecoder {
	if ((self = [super initWithCoder:aDecoder]))
		[self setup];

	return self;
}

- (instancetype)initWithFrame:(CGRect)frame {
	if ((self = [super initWithFrame:frame]))
		[self setup];

	return self;
}

- (void)setup {
	_collapseOnDragStart = NO;
	_expandOnDragEnd = YES;
	_expandOnDragDrop = NO;
	_isActive = NO;
	_delegate = nil;
	_showSections = YES;
	_selectedSection = -1;
	_headerView = nil;
	_footerView = nil;
	_totalSection = 0;
	_totalTags = 0;
	_sectionRender = nil;
	_sectionMustBeShown = NO;
	_marginSection = UIEdgeInsetsMake(4, 4, 4, 4);
	_marginTag= UIEdgeInsetsMake(8, 8, 8, 8);
	_offsetSize = CGSizeZero;
	_selectAnimationDuration = 0.1f;
	_minHeight = 38.0f;
	_maxHeight = 260.0f;

	_sectionTitleView = [[TagScrollView alloc] initWithFrame:CGRectZero];
	_sectionTitleView.backgroundColor = [UIColor blackColor];
	_sectionTitleView.canCancelContentTouches = YES;
	_sectionTitleView.scrollEnabled = YES;
	_sectionTitleView.showsHorizontalScrollIndicator = NO;
	_sectionTitleView.showsVerticalScrollIndicator = NO;
	_sectionTitleView.translatesAutoresizingMaskIntoConstraints = NO;

	_sectionTagsViews = [[TagScrollView alloc] initWithFrame:CGRectZero];
	_sectionTagsViews.backgroundColor = [UIColor whiteColor];
	_sectionTagsViews.canCancelContentTouches = YES;
	_sectionTagsViews.scrollEnabled = YES;
	_sectionTagsViews.showsHorizontalScrollIndicator = NO;
	_sectionTagsViews.showsVerticalScrollIndicator = YES;
	_sectionTagsViews.translatesAutoresizingMaskIntoConstraints = NO;
	_sectionTagsViews.userInteractionEnabled = YES;

	_sectionSwipe = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(onSectionSwipe:)];
	_sectionSwipe.delegate = self;
	_sectionSwipe.enabled = NO;
	[_sectionTitleView addGestureRecognizer:_sectionSwipe];

	[self addSubview:_sectionTitleView];
	[self addSubview:_sectionTagsViews];

	_dragAndDropManager = [[AtkDragAndDropManager alloc] init];
	_dragAndDropManager.delegate = self;
	self.translatesAutoresizingMaskIntoConstraints = NO;
}

- (void)awakeFromNib {
	[super awakeFromNib];

	for (NSLayoutConstraint *constraint in self.constraints) {
		if (constraint.firstAttribute == NSLayoutAttributeHeight) {
			if (constraint.relation == NSLayoutRelationEqual)
				_heightConstraint = constraint;
		}
	}

	self.heightConstraint.constant = self.minHeight;
}

- (NSLayoutConstraint *)heightConstraint {
	if(_heightConstraint == nil)
		_heightConstraint = [NSLayoutConstraint constraintWithItem:self
														 attribute:NSLayoutAttributeHeight
														 relatedBy:NSLayoutRelationEqual
															toItem:nil
														 attribute:NSLayoutAttributeNotAnAttribute
														multiplier:1
														  constant:_minHeight];

	return _heightConstraint;
}

-(void)onSectionSwipe:(UIPanGestureRecognizer *)recognizer {
	//is horizontal built-in UIScrollView panRecognizer is active?
	if(self.sectionTitleView.dragging || self.sectionTitleView.decelerating)
		return;

	if (recognizer.state == UIGestureRecognizerStateEnded || recognizer.state == UIGestureRecognizerStateCancelled) {
		[recognizer cancelsTouchesInView];
		CGPoint distance = [recognizer translationInView:self];

		if (distance.y > 0) {
			[self collapsePanel];
		} else if (distance.y < 0) {
			[self expandPanel];
		}
	}
}

//process simultaneous sectionSwipe and built-in scrollView swipes
- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldRecognizeSimultaneouslyWithGestureRecognizer:(UIGestureRecognizer *)otherGestureRecognizer {
	return YES;
}

-(void)setIsActive:(BOOL)isActive {
	@synchronized (self.delegate) {
		if (isActive != _isActive) {
			_isActive = isActive;

			if(_isActive)
				[self.dragAndDropManager start:[[UIApplication sharedApplication] keyWindow] recognizerClass:[UILongPressGestureRecognizer class]];
			else
				[self.dragAndDropManager stop];

			_sectionSwipe.enabled = _isActive;
		}
	}
}

-(void)addDropZone:(UIView *)dropZone {
	if(_dropZones == nil)
		_dropZones = [[NSMutableArray alloc] init];

	MTTagViewDropZoneWrapper *viewDropZone = [[MTTagViewDropZoneWrapper alloc] initWithView:dropZone];
	[(NSMutableArray *)_dropZones addObject:viewDropZone];
}

/*
-(void)removeAllDropZones {
	[dropZones removeAllObjects];

	//TODO: cancel animations
}*/

-(void)setDelegate:(id <MTTagViewDelegate>)delegate {
	if(delegate == nil)
		return;

	_delegate = delegate;

	CGFloat contentY;

	if(!(_headerView)) {
		_headerView = ([_delegate respondsToSelector:@selector(headerForTagView:)]) ? [_delegate headerForTagView:self] : nil;

		if(_headerView) {
			contentY = _sectionTitleView.frame.size.height;
			_headerView.frame = CGRectMake(0, contentY, self.bounds.size.width, _headerView.frame.size.height);
			[self addSubview:_headerView];
		}
	}

	if(!(_footerView)) {
		_footerView = ([_delegate respondsToSelector:@selector(footerForTagView:)]) ? [_delegate footerForTagView:self] : nil;

		if(_footerView) {
			contentY = self.bounds.size.height - _footerView.frame.size.height;
			_footerView.frame = CGRectMake(0, contentY, self.bounds.size.width, _footerView.frame.size.height);
			[self addSubview:_footerView];
		}
	}

	NSMethodSignature* signature;
	if ([_delegate respondsToSelector:@selector(tagView:viewForSection:)]) {
		signature = [[_delegate class] instanceMethodSignatureForSelector: @selector(tagView:viewForSection:)];
		_sectionRender = [NSInvocation invocationWithMethodSignature: signature];
		[_sectionRender setSelector: @selector(tagView:viewForSection:)];
	} else if ([_delegate respondsToSelector:@selector(tagView:titleForSection:)]) {
		signature = [[_delegate class] instanceMethodSignatureForSelector: @selector(tagView:titleForSection:)];
		_sectionRender = [NSInvocation invocationWithMethodSignature: signature];
		[_sectionRender setSelector: @selector(tagView:titleForSection:)];
	} else {
		_sectionRender = nil;
		DDLogError(@"No implementation for titleForSection or viewForSection was found.");
	}

	if(_sectionRender) {
		id sender = self;
		[_sectionRender setTarget: _delegate];
		[_sectionRender setArgument: &sender atIndex: 2];
	}

	_selectedSection = 0;
	[self reloadData];
}

-(void)setSelectedSection:(NSInteger)selectedSection {
	if(_selectedSection == selectedSection || selectedSection >= _totalSection)
		return;

	[self sectionWillSelect:(NSUInteger) selectedSection];
	[self sectionDidSelect:(NSUInteger) _selectedSection];
}

-(void)setShowSections:(BOOL)showSections {
	if(_showSections == showSections)
		return;

	_showSections = showSections;
	[self setNeedsLayout];
}

-(void)layoutSections {
	UIEdgeInsets padding = self.marginSection;
	CGFloat offsetX = 0;

	_sectionTitleView.frame = CGRectMake(0, 0, self.bounds.size.width, 38.0f);
	for(UIView *control in _sectionTitleView.subviews) {
		if(!(control.tag & SECTION_FLAG_ID))
			continue;

		control.frame = CGRectMake(offsetX + padding.left, padding.top, control.frame.size.width, _sectionTitleView.frame.size.height - (padding.top + padding.bottom));
		offsetX += control.frame.size.width + padding.right;
	}
}

-(void)layoutTags {
	CGFloat contentY = _sectionTitleView.frame.size.height;
	_sectionTagsViews.frame = CGRectMake(0, contentY, self.bounds.size.width, self.bounds.size.height - contentY);

	UIEdgeInsets padding = self.marginTag;
	CGFloat offsetX = 0;
	CGFloat offsetY = 0;
	CGFloat width = _sectionTagsViews.frame.size.width;
	for(UIView *tagItem in _sectionTagsViews.subviews) {
		if(!(tagItem.tag & TAG_FLAG_ID))
			continue;

		if(offsetX + tagItem.frame.size.width + padding.left + padding.right > width) {
			offsetX = 0;
			offsetY += tagItem.frame.size.height + padding.bottom;
		}

		tagItem.frame = CGRectMake(offsetX + padding.left, offsetY + padding.top, tagItem.frame.size.width, tagItem.frame.size.height);
		offsetX += tagItem.frame.size.width + padding.right;
	}
}

-(void)layoutSubviews {
//	DDLogDebug(@"layoutSubviews. size=%@, origin=%@", NSStringFromCGSize(self.frame.size), NSStringFromCGPoint(self.frame.origin));
	if(!(_sectionTitleView.hidden)) {
		[self layoutSections];

		UIView *lastSection = [_sectionTitleView viewWithTag:((_totalSection - 1) | SECTION_FLAG_ID)];
		if(lastSection)
			_sectionTitleView.contentSize = CGSizeMake(lastSection.frame.origin.x + lastSection.frame.size.width + self.marginSection.right, _sectionTitleView.frame.size.height);
	}

	CGFloat contentY = ((_sectionMustBeShown) ? _sectionTitleView.frame.size.height : 0);
	CGFloat contentHeight = self.bounds.size.height;

	if(_headerView) {
		_headerView.frame = CGRectMake(0, contentY, _headerView.frame.size.width, _headerView.frame.size.height);
		contentY += _headerView.frame.size.height;
	}

	if(_footerView) {
		_footerView.frame = CGRectMake(0, self.bounds.size.height - _footerView.frame.size.height, _footerView.frame.size.width, _footerView.frame.size.height);
		contentHeight -= _footerView.frame.size.height;
	}

	contentHeight -= contentY;
	_sectionTagsViews.frame = CGRectMake(0, contentY, _sectionTagsViews.frame.size.width, contentHeight);

	[self layoutTags];
	UIView *lastTag = [_sectionTagsViews viewWithTag:((_totalTags - 1) | TAG_FLAG_ID)];
	if(lastTag)
		_sectionTagsViews.contentSize = CGSizeMake(_sectionTagsViews.frame.size.width, lastTag.frame.origin.y + lastTag.frame.size.height + self.marginTag.bottom);

	[super layoutSubviews];
}

-(void)collapsePanel {
	@synchronized (self.delegate) {
		CGFloat currentHeight = self.frame.size.height;
		if(currentHeight <= _minHeight)
			return;

		if(self.delegate && [self.delegate respondsToSelector:@selector(willCollapseTagView:)])
			[self.delegate willCollapseTagView:self];

		[self layoutIfNeeded];
		@weakify(self);
		[UIView animateWithDuration:0.3f
							  delay:0.0
			 usingSpringWithDamping:0.6f
			  initialSpringVelocity:1.0f
							options:UIViewAnimationOptionBeginFromCurrentState
						 animations:^{
							 @strongify(self);
							 self.heightConstraint.constant = _minHeight;
							 [self layoutIfNeeded];
						 }
						 completion:^(BOOL finished) {
							 @strongify(self);
							 if(self.delegate && [self.delegate respondsToSelector:@selector(didCollapseTagView:)])
								 [self.delegate didCollapseTagView:self];
						 }
		];
	}
}

-(void)expandPanel {
	@synchronized (self.delegate) {
		CGFloat currentHeight = self.frame.size.height;
		if(currentHeight >= _maxHeight)
			return;

		if(self.delegate && [self.delegate respondsToSelector:@selector(willExpandTagView:)])
			[self.delegate willExpandTagView:self];

		@weakify(self);
		[UIView animateWithDuration:0.3f
							  delay:0.0
			 usingSpringWithDamping:0.8f
			  initialSpringVelocity:1.0f
							options:UIViewAnimationOptionBeginFromCurrentState
						 animations:^{
							 @strongify(self);
							 self.heightConstraint.constant = _maxHeight;
							 [self layoutIfNeeded];
						 }
						 completion:^(BOOL finished) {
							 @strongify(self);
							 if(self.delegate && [self.delegate respondsToSelector:@selector(didExpandTagView:)])
								[self.delegate didExpandTagView:self];
						 }
		];

		[self layoutIfNeeded];
	}
}

-(void)reloadData {
	[self reloadSections];
	[self reloadTags];
}

-(void)reloadSections {
	_totalSection = 0;
	if(([_delegate respondsToSelector:@selector(numberOfSectionInTagView:)])) {
		NSMethodSignature *signature = [[_delegate class] instanceMethodSignatureForSelector: @selector(numberOfSectionInTagView:)];
		NSInvocation *invocation = [NSInvocation invocationWithMethodSignature: signature];
		id sender = self;
		[invocation setTarget: _delegate];
		[invocation setSelector: @selector(numberOfSectionInTagView:)];
		[invocation setArgument: &sender atIndex: 2];
		[invocation invoke];
		[invocation getReturnValue:&_totalSection];
	}

	_sectionMustBeShown = (_showSections && _totalSection > 1);
	_sectionTitleView.hidden = !_sectionMustBeShown;

	if(_sectionMustBeShown && _sectionRender) {
		NSArray *subviewsCopy = [[_sectionTitleView subviews] copy];
		for(UIView *control in subviewsCopy) {
			if(control.tag & SECTION_FLAG_ID)
				[control removeFromSuperview];
		}

		for(NSUInteger i = 0; i < _totalSection; i++) {
			UIControl *control = [self controlForSection:i];

			if(control == nil)
				continue;

			if(_selectedSection == i)
				control.selected = YES;

			[control addTarget:self action:@selector(onSectionSelect:) forControlEvents:UIControlEventTouchUpInside];
			control.tag = SECTION_FLAG_ID | i;

			[_sectionTitleView addSubview:control];
		}
	}

	[self setNeedsLayout];
}

-(void)reloadTags {
	_totalTags = 0;
	if(!([_delegate respondsToSelector:@selector(tagView:numberOfTagsInSection:)]) || !([_delegate respondsToSelector:@selector(tagView:tagItemForIndexPath:)]) || !(_totalSection) ||  _selectedSection > _totalSection)
		return;

	id sender = self;
	NSUInteger section = (NSUInteger)_selectedSection;

	NSMethodSignature* signature = [[_delegate class] instanceMethodSignatureForSelector: @selector(tagView:numberOfTagsInSection:)];
	NSInvocation* invocation = [NSInvocation invocationWithMethodSignature: signature];
	[invocation setTarget: _delegate];
	[invocation setSelector: @selector(tagView:numberOfTagsInSection:)];
	[invocation setArgument: &sender atIndex: 2];
	[invocation setArgument: &section atIndex: 3];
	[invocation invoke];
	[invocation getReturnValue:&_totalTags];

	NSArray *subviewsCopy = [[_sectionTagsViews subviews] copy];
	for(UIView *view in subviewsCopy) {
		if(view.tag & TAG_FLAG_ID)
			[view removeFromSuperview];
	}

	for(NSUInteger i = 0; i < _totalTags; i++) {
		UIView *tagItem = [_delegate tagView:self tagItemForIndexPath:[NSIndexPath indexPathForRow:i inSection:section]];
		tagItem.tag = TAG_FLAG_ID | i;
		[_sectionTagsViews addSubview:tagItem];
	}

	[self setNeedsLayout];
}

-(UIControl *)controlForSection:(NSUInteger)section {
	UIControl *control = nil;
	if(_sectionRender) {
		[_sectionRender setArgument: &section atIndex: 3];
		[_sectionRender invoke];

		CFTypeRef result;
		if ([_delegate respondsToSelector:@selector(tagView:viewForSection:)]) {
			[_sectionRender getReturnValue:&result];
			if(result)
				CFRetain(result);

			control = (__bridge_transfer UIControl *)result;
		} else if ([_delegate respondsToSelector:@selector(tagView:titleForSection:)]){
			[_sectionRender getReturnValue:&result];
			if(result)
				CFRetain(result);

			NSString *title = (__bridge_transfer NSString *)result;
			control = [self sectionForTitle:title];
		}
	}

	return control;
}

-(UIControl *)sectionForTitle:(NSString *)title {
	UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];

	button.frame = CGRectZero;
	button.contentEdgeInsets = UIEdgeInsetsMake(0, 10, 0, 10);
	button.titleLabel.font = [UIFont systemFontOfSize:14.0f];

	[button setTitle:title forState:UIControlStateNormal];
	[button sizeToFit];
	[button setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
	[button setTitleColor:button.tintColor forState:UIControlStateSelected];
	[button setBackgroundImage:[UIImage backgroundImageWithColor:[UIColor whiteColor]] forState:UIControlStateSelected];
	return button;
}

-(void)onSectionSelect:(UIControl *)button {
	NSUInteger section = (NSUInteger)button.tag & ~SECTION_FLAG_ID;

	if(_delegate && [_delegate respondsToSelector:@selector(tagView:shouldSelectSection:)])
		if(!([_delegate tagView:self shouldSelectSection:section]))
			return;

	if(button.selected) {
		if(self.frame.size.height > _minHeight)
			[self collapsePanel];
		else
			[self expandPanel];

		return;
	}

	for(UIControl *sectionButton in _sectionTitleView.subviews) {
		if (sectionButton.selected) {
			[UIView transitionWithView:sectionButton
							  duration:_selectAnimationDuration
							   options:UIViewAnimationOptionTransitionCrossDissolve
							animations:^{
								[sectionButton setSelected:NO];
							} completion:nil];

			break;
		}
	}

	[self sectionWillSelect:section];
	@weakify(self);
	[UIView transitionWithView:button
					  duration:_selectAnimationDuration
					   options:UIViewAnimationOptionTransitionCrossDissolve
					animations:^{
						[button setSelected:YES];
					} completion:^(BOOL flag) {
				@strongify(self);
				[self sectionDidSelect:section];
			}];
}

-(void)sectionWillSelect:(NSUInteger)section {
	if(_delegate && [_delegate respondsToSelector:@selector(tagView:willSelectSection:)])
		[_delegate tagView:self willSelectSection:section];

	_selectedSection = section;
}

-(void)sectionDidSelect:(NSUInteger)section {
	[self expandPanel];
	[self reloadTags];

	if(_delegate && [_delegate respondsToSelector:@selector(tagView:didSelectSection:)])
		[_delegate tagView:self didSelectSection:section];
}

#pragma mark AtkDragAndDropManagerDelegate
/**
* Finds the drag source.
*/
- (id<AtkDragSourceProtocol>)findDragSource:(AtkDragAndDropManager *)manager recognizer:(UIGestureRecognizer *)recognizer {
	UIView *hitView = [manager.rootView hitTest:[recognizer locationInView:manager.rootView] withEvent:nil];

	if(!(hitView.tag & TAG_FLAG_ID)) {
		return nil;
	}

	MTTagViewSourceWrapper *ret = [[MTTagViewSourceWrapper alloc] initWithView:hitView];
	self.indexPathForDragSource = [NSIndexPath indexPathForRow:(hitView.tag & ~TAG_FLAG_ID) inSection:_selectedSection];
	self.pointForDragSource = [recognizer locationInView:manager.rootView];
	return ret;
}

/**
* Recursively finds any drop zones (id<AtkDropZoneProtocol>) in rootView and it's descendents that are interested in the gesture
* recognizer and returns them.
*/
- (NSArray *)findDropZones:(AtkDragAndDropManager *)manager recognizer:(UIGestureRecognizer *)recognizer {
	return _dropZones;
}

/**
* Returns YES is the specified drop zone is active for the recognizer. Active means that if the
* drop event were to occur immediately, that drop zone would be dropped upon.
*/
- (BOOL)isDropZoneActive:(AtkDragAndDropManager *)manager dropZone:(id<AtkDropZoneProtocol>)dropZone recognizer:(UIGestureRecognizer *)recognizer {
	BOOL ret = NO;
	if([dropZone respondsToSelector:@selector(isActive:point:)])
		ret = [dropZone isActive:manager point:[recognizer locationInView:manager.rootView]];

	if(!(self.collapseOnDragStart) && [recognizer isKindOfClass:[UIGestureRecognizer class]]) {
		CGFloat offsetY = 0.0f;

		if([recognizer isKindOfClass:[UIPanGestureRecognizer class]]) {
			offsetY = [(UIPanGestureRecognizer *) recognizer translationInView:manager.rootView].y;
		} else if([recognizer isKindOfClass:[UILongPressGestureRecognizer class]]) {
			offsetY = [recognizer locationInView:manager.rootView].y - self.pointForDragSource.y;
		}

		if(offsetY) {
			self.heightConstraint.constant = self.offsetSize.height + offsetY * 3;
			if (self.heightConstraint.constant > _maxHeight)
				self.heightConstraint.constant = _maxHeight;

			if (self.heightConstraint.constant < _minHeight)
				self.heightConstraint.constant = _minHeight;

			[self layoutIfNeeded];
		}
	}

	if([self.delegate respondsToSelector:@selector(tagView:dragMovedWithIndexPath:)])
		[self.delegate tagView:self dragMovedWithIndexPath:self.indexPathForDragSource];

	return ret;
}

/**
* Called when a drag has started. All of the interested drop zoned have been found.
*/
- (void)dragStarted:(AtkDragAndDropManager *)manager {
	DDLogDebug(@"dragStarted");
	self.sourceDropped = NO;

	if(self.collapseOnDragStart)
		[self collapsePanel];
	else
		self.offsetSize = self.frame.size;

	if([self.delegate respondsToSelector:@selector(tagView:dragStartedWithIndexPath:)])
		[self.delegate tagView:self dragStartedWithIndexPath:self.indexPathForDragSource];
}

/**
* Called when a drag has ended.
*/
- (void)dragEnded:(AtkDragAndDropManager *)manager {
	if(!(self.sourceDropped) && self.expandOnDragEnd)
		[self expandPanel];

	if([self.delegate respondsToSelector:@selector(tagView:dragEndedWithIndexPath:)])
		[self.delegate tagView:self dragEndedWithIndexPath:self.indexPathForDragSource];
}

/**
* Called when a drag is dropped onto a drop zone.
*/
- (void)dragDropped:(AtkDragAndDropManager *)manager dropZone:(id<AtkDropZoneProtocol>) dropZone point:(CGPoint)point {
	self.sourceDropped = YES;
	self.expandOnDragDrop ? [self expandPanel] : [self collapsePanel];

	if([self.delegate respondsToSelector:@selector(tagView:dragDroppedWithIndexPath:)])
		[self.delegate tagView:self dragDroppedWithIndexPath:self.indexPathForDragSource];
}

@end
