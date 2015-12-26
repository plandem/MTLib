//
// Created by Andrey on 28/04/15.
// Copyright (c) 2015 Melatonin LLC. All rights reserved.
//

#import "MTDataObject.h"
#import "MTDataQuery.h"

@class MTDataRepository;

extern NSString *MTDataErrorNoActiveTransaction;
typedef void (^MTDataRepositoryTransactionBlock)(MTDataRepository *dataRepository);

@interface MTDataRepository : NSObject
@property (nonatomic, readonly) Class modelClass;

-(instancetype)initWithModelClass:(Class)modelClass;
-(void)withTransaction:(MTDataRepositoryTransactionBlock)transactionBlock;
-(void)beginTransaction;
-(void)commitTransaction;
-(void)rollbackTransaction;
-(BOOL)inTransaction;
-(void)ensureModelType:(id<MTDataObject>)model;

-(id<MTDataObject>)createModel;
-(void)saveModel:(id<MTDataObject>)model;
-(void)undoModel:(id<MTDataObject>)model;
-(void)deleteModel:(id<MTDataObject>)model;

-(void)deleteAll;
-(void)deleteAllWithQuery:(MTDataQuery *)query;

-(NSUInteger)countAll;
-(NSUInteger)countWithQuery:(MTDataQuery *)query;

-(id<MTDataObject>)fetchWithQuery:(MTDataQuery *)query;
-(id<MTDataObjectCollection>)fetchAllWithQuery:(MTDataQuery *)query;
@end