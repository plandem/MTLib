//
// Created by Andrey on 27/04/15.
// Copyright (c) 2015 Melatonin LLC. All rights reserved.
//

#import "MTDataQuery.h"
#import "MTDataObject.h"

@class MTDataProvider;
@class MTDataRepository;

typedef void (^MTDataProviderRefreshBlock)(MTDataProvider *dataProvider);
typedef BOOL (^MTDataProviderMoveBlock)(MTDataProvider *dataProvider, NSIndexPath *fromIndexPath, id<MTDataObject>fromModel, NSIndexPath *toIndexPath, id<MTDataObject>toModel);

@interface MTDataProvider : NSObject
@property (nonatomic, strong) MTDataRepository *repository;
@property (nonatomic, readonly) id<MTDataObjectCollection> models;
@property (nonatomic, copy) MTDataQuery *query;
@property (nonatomic, copy) MTDataProviderRefreshBlock refreshBlock;
@property (nonatomic, copy) MTDataProviderMoveBlock moveBlock;

-(instancetype)initWithModelClass:(Class)modelClass;
-(instancetype)initWithRepository:(MTDataRepository *)repository;
-(void)refresh;
-(void)prepare:(BOOL)forceUpdate;

-(id)createViewModel:(Class)viewModelClass forIndexPath:(NSIndexPath *)indexPath;
-(void)deleteAtIndexPath:(NSIndexPath *)indexPath;
-(id<MTDataObject>)modelAtIndexPath:(NSIndexPath *)indexPath;
-(BOOL)moveFromIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath;

-(MTDataProvider *)makeQuery:(void(^)(MTDataQuery *query, MTDataSort *sort))block;
//-(void)setupWatcher;
@end

@interface MTDataProvider(MTDataProviderBlocks)
-(MTDataProviderMoveBlock)sortingMoveBlock:(NSString *)attribute withStep:(NSInteger)step;
@end

