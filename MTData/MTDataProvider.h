//
// Created by Andrey on 27/04/15.
// Copyright (c) 2015 Andrey Gayvoronsky. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "MTDataQuery.h"
#import "MTDataSort.h"
#import "MTDataObject.h"

@class MTDataProvider;

typedef void (^MTDataProviderRefreshBlock)();
typedef void (^MTDataProviderSaveBlock)(MTDataProvider *dataProvider);

@protocol MTDataProviderProtocol <NSObject>
//NB: fetching can be implemented at background thread, so we can use this only after data fetched.
@required
-(void)deleteAtIndexPath:(NSIndexPath *)indexPath;
-(id)modelAtIndexPath:(NSIndexPath *)indexPath;
-(id<NSFastEnumeration>)prepareModels;

@optional
-(void)moveFromIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath;
-(void)saveModel:(id<MTDataObject> *)model;
-(void)withTransaction:(MTDataProviderSaveBlock)saveBlock;
@end

@interface MTDataProvider : NSObject <MTDataProviderProtocol>
@property (nonatomic, readonly) Class modelClass;
@property (nonatomic, readonly) id<NSFastEnumeration> models;
@property (nonatomic, copy) MTDataQuery *query;
@property (nonatomic, copy) MTDataSort *sort;
@property (nonatomic, copy) MTDataProviderRefreshBlock refreshBlock;
-(instancetype)initWithModelClass:(Class)modelClass;
-(instancetype)createViewModel:(Class)className forIndexPath:(NSIndexPath *)indexPath;
-(void)refresh;
-(void)prepare:(BOOL)forceUpdate;

//wrapper for chaining
-(MTDataProvider *)makeQuery:(void(^)(MTDataQuery *query, MTDataSort *sort))block;
@end