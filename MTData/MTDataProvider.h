//
// Created by Andrey on 27/04/15.
// Copyright (c) 2015 Melatonin LLC. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "MTDataQuery.h"
#import "MTDataSort.h"
#import "MTDataObject.h"

@class MTDataProvider;

typedef void (^MTDataProviderRefreshBlock)(MTDataProvider *dataProvider);
typedef void (^MTDataProviderSaveBlock)(MTDataProvider *dataProvider);

@protocol MTDataProviderCollection <NSFastEnumeration>
@required
@property (readonly) NSUInteger count;
- (id)objectAtIndex:(NSUInteger)index;
- (id)objectAtIndexedSubscript:(NSUInteger)index;
@end

@protocol MTDataProviderProtocol <NSObject>
//NB: fetching can be implemented at background thread, so we can use this only after data fetched.
@required
-(void)deleteAtIndexPath:(NSIndexPath *)indexPath;
-(id<MTDataObject>)modelAtIndexPath:(NSIndexPath *)indexPath;
-(id<MTDataProviderCollection>)prepareModels;

@optional
-(void)moveFromIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath;
-(id<MTDataObject>)createModel;
-(void)saveModel:(id<MTDataObject>)model;
-(void)withTransaction:(MTDataProviderSaveBlock)saveBlock;
@end

@interface MTDataProvider : NSObject <MTDataProviderProtocol>
@property (nonatomic, readonly) Class modelClass;
@property (nonatomic, readonly) Class queryClass;
@property (nonatomic, readonly) Class sortClass;
@property (nonatomic, readonly) id<MTDataProviderCollection> models;
@property (nonatomic, copy) MTDataQuery *query;
@property (nonatomic, copy) MTDataSort *sort;
@property (nonatomic, assign) NSUInteger batchSize;
@property (nonatomic, copy) MTDataProviderRefreshBlock refreshBlock;
-(instancetype)initWithModelClass:(Class)modelClass;
-(instancetype)createViewModel:(Class)className forIndexPath:(NSIndexPath *)indexPath;
-(void)refresh;
-(void)prepare:(BOOL)forceUpdate;

//wrapper for chaining
-(MTDataProvider *)makeQuery:(void(^)(MTDataQuery *query, MTDataSort *sort))block;
@end