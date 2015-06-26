//
// Created by Andrey on 27/04/15.
// Copyright (c) 2015 Melatonin LLC. All rights reserved.
//

#import "MTDataProvider.h"
#import "MTDataRepository.h"

@interface MTDataProvider ()
@property (nonatomic, strong) id<MTDataObjectCollection> models;
@end

@implementation MTDataProvider

-(instancetype)initWithRepository:(MTDataRepository *)repository {
	if ((self = [self init])) {
		self.repository = repository;
	}

	return self;
}

-(instancetype)initWithModelClass:(Class)modelClass {
	if ((self = [self init])) {
		self.repository = [(MTDataRepository *)[[(id<MTDataObject>)modelClass repositoryClass] alloc] initWithModelClass:modelClass];
	}

	return self;
}

// creates and return ViewModel for model at thread. if no thread is provided
-(id)createViewModel:(Class)viewModelClass forIndexPath:(NSIndexPath *)indexPath {
	id viewModel = [viewModelClass alloc];
	NSAssert([viewModel respondsToSelector:@selector(initWithModel:)], @"You must implement the 'initWithModel:' selector for '%@'", NSStringFromClass(viewModelClass));

	id<MTDataObject>model;

	if(indexPath) {
		model = [self modelAtIndexPath:indexPath];
	} else {
		model = [_repository createModel];
	}

	return [viewModel performSelector:@selector(initWithModel:) withObject:model];
}

-(id<MTDataObject>)modelAtIndexPath:(NSIndexPath *)indexPath {
	id<MTDataObjectCollection>models = [self models];
	return ((models && (indexPath.row < [models count])) ? models[(NSUInteger)indexPath.row] : nil);
}

-(void)deleteAtIndexPath:(NSIndexPath *)indexPath {
	id<MTDataObject>model = [self modelAtIndexPath:indexPath];
	[_repository deleteModel:model];
}

-(void)moveFromIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath {
	if(_moveBlock && ![fromIndexPath isEqual:toIndexPath]) {
		id<MTDataObject>fromModel = [self modelAtIndexPath:fromIndexPath];
		id<MTDataObject>toModel = [self modelAtIndexPath:toIndexPath];
		_moveBlock(self, fromIndexPath, fromModel, toIndexPath, toModel);
	}
}

-(void)prepare:(BOOL)forceUpdate {
	if(forceUpdate || _models == nil) {
		_models = [_repository fetchAllWithQuery:_query];
	}
}

-(id<MTDataObjectCollection>)models {
	[self prepare:NO];
	return _models;
}

-(void)refresh {
	[self setupWatcher];
	_models = nil;
}

-(MTDataProvider *)makeQuery:(void(^)(MTDataQuery *query, MTDataSort *sort))block {
	_query = [(id<MTDataObject>)[_repository modelClass] query];
	block(_query, _query.sort);
	[self refresh];
	return self;
}

-(void)setQuery:(MTDataQuery *)query {
	Class queryClass = [(id<MTDataObject>)[_repository modelClass] queryClass];

	NSAssert([query isKindOfClass:queryClass], @"Query[%@] must be kind of [%@] class.", query.class, queryClass);
	if(_query != query) {
		_query = query;
		[self refresh];
	}
}

-(void)setRepository:(MTDataRepository *)repository {
	Class repositoryClass = [(id<MTDataObject>)[repository modelClass] repositoryClass];

	NSAssert([repository isKindOfClass:repositoryClass], @"Repository [%@] must be kind of [%@] class.", repository.class, repositoryClass);
	if(_repository != repository) {
		_repository = repository;
		[self refresh];
	}
}

-(void)setRefreshBlock:(MTDataProviderRefreshBlock)refreshBlock {
	_refreshBlock = [refreshBlock copy];
	[self refresh];
}

-(void)setupWatcher {
	//by default do nothing, specific to implementation. override to add specific behavior.
}
@end