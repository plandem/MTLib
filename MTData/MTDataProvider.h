//
// Created by Andrey on 27/04/15.
// Copyright (c) 2015 Melatonin LLC. All rights reserved.
//

#import "MTDataQuery.h"
#import "MTDataObject.h"
#import "MTDataObjectCollection.h"

@class MTDataProvider;
@class MTDataRepository;

typedef void (^MTDataProviderRefreshBlock)(MTDataProvider *dataProvider);
typedef void (^MTDataProviderMoveBlock)(MTDataProvider *dataProvider, id<MTDataObject>fromModel, id<MTDataObject>toModel);

@interface MTDataProvider : NSObject
@property (nonatomic, strong) MTDataRepository *repository;
@property (nonatomic, readonly) id<MTDataObjectCollection> models;
@property (nonatomic, copy) MTDataQuery *query;
@property (nonatomic, copy) MTDataProviderRefreshBlock refreshBlock;
@property (nonatomic, copy) MTDataProviderMoveBlock moveBlock;

+(Class)repositoryClass;

-(instancetype)initWithModelClass:(Class)modelClass;
-(instancetype)createViewModel:(Class)className forIndexPath:(NSIndexPath *)indexPath;
-(void)refresh;
-(void)prepare:(BOOL)forceUpdate;

-(void)deleteAtIndexPath:(NSIndexPath *)indexPath;
-(id<MTDataObject>)modelAtIndexPath:(NSIndexPath *)indexPath;
-(void)moveFromIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath;

-(MTDataProvider *)makeQuery:(void(^)(MTDataQuery *query, MTDataSort *sort))block;
@end