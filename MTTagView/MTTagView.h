//
// Created by Andrey on 17/09/14.
// Copyright (c) 2015 Melatonin LLC. All rights reserved.
//

@import Foundation;
@import UIKit;

@class MTTagView;
@class MTTagViewSectionTitleView;
@class MTTagViewSectionTagsView;

@protocol MTTagViewDelegate <NSObject>
@required
-(NSUInteger)numberOfSectionInTagView:(MTTagView *)tagView; //return number of sections
-(NSUInteger)tagView:(MTTagView *)tagView numberOfTagsInSection:(NSUInteger)section; //return number of tags in section
-(UIView *)tagView:(MTTagView *)tagView tagItemForIndexPath:(NSIndexPath *)indexPath; //return view for tag at IndexPath
@optional
-(UIView *)headerForTagView:(MTTagView *)tagView; //return view for header
-(UIView *)footerForTagView:(MTTagView *)tagView; //return view for footer
-(NSString *)tagView:(MTTagView *)tagView titleForSection:(NSUInteger)section; //return title for default render of section
-(UIControl *)tagView:(MTTagView *)tagView viewForSection:(NSUInteger)section;// or return complete UIControl for section
-(void)tagView:(MTTagView *)tagView dragStartedWithIndexPath:(NSIndexPath *)indexPath;
-(void)tagView:(MTTagView *)tagView dragMovedWithIndexPath:(NSIndexPath *)indexPath;
-(void)tagView:(MTTagView *)tagView dragEndedWithIndexPath:(NSIndexPath *)indexPath;
-(void)tagView:(MTTagView *)tagView dragDroppedWithIndexPath:(NSIndexPath *)indexPath;
-(void)tagView:(MTTagView *)tagView willSelectSection:(NSUInteger)section;
-(void)tagView:(MTTagView *)tagView didSelectSection:(NSUInteger)section;
-(BOOL)tagView:(MTTagView *)tagView shouldSelectSection:(NSUInteger)section;
-(void)willExpandTagView:(MTTagView *)tagView;
-(void)willCollapseTagView:(MTTagView *)tagView;
-(void)didExpandTagView:(MTTagView *)tagView;
-(void)didCollapseTagView:(MTTagView *)tagView;
@end

@interface MTTagViewSectionTitleView: UIScrollView
@end

@interface MTTagViewSectionTagsView: UIScrollView
@end

//IB_DESIGNABLE
@interface MTTagView : UIView
@property (nonatomic, weak) IBOutlet id<MTTagViewDelegate> delegate;
@property (nonatomic, assign) IBInspectable CGFloat minHeight; //height for collapsed state. default 38.0
@property (nonatomic, assign) IBInspectable CGFloat maxHeight; //height for expanded state. default 260.0
@property (nonatomic, assign) IBInspectable BOOL showSections; //default YES
@property (nonatomic, assign) IBInspectable BOOL collapseOnDragStart; //default NO
@property (nonatomic, assign) IBInspectable BOOL expandOnDragEnd; //default YES
@property (nonatomic, assign) IBInspectable BOOL expandOnDragDrop; //default NO
@property (nonatomic, assign) IBInspectable CGFloat selectAnimationDuration; //default 0.1
@property (nonatomic, assign) BOOL isActive; //default NO
@property (nonatomic, assign, readonly) BOOL isExpanded;
@property (nonatomic, assign, readonly) NSInteger selectedSection;
@property (nonatomic, strong, readonly) NSArray *dropZones;
@property (nonatomic, assign) UIEdgeInsets marginSection UI_APPEARANCE_SELECTOR;
@property (nonatomic, assign) UIEdgeInsets marginTag UI_APPEARANCE_SELECTOR;
@property (nonatomic, strong, readonly) MTTagViewSectionTitleView *sectionTitleView;
@property (nonatomic, strong, readonly) MTTagViewSectionTagsView *sectionTagsView;

-(void)reloadData;
-(void)addDropZone:(UIView *)dropZone;
-(void)expandPanel;
-(void)collapsePanel;
//-(void)removeAllDropZones;
@end
