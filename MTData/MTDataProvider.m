//
// Created by Andrey on 27/04/15.
// Copyright (c) 2015 Melatonin LLC. All rights reserved.
//

#import "MTDataProvider.h"

@interface MTDataProvider ()
@property (nonatomic, strong) id<MTDataProviderCollection> models;
@property (nonatomic, strong) Class modelClass;
@end

@implementation MTDataProvider

-(instancetype)initWithModelClass:(Class)modelClass {
	if ((self = [super init])) {
		_modelClass = modelClass;
		_batchSize = 0;
		NSAssert([modelClass conformsToProtocol:@protocol(MTDataObject)], @"Class must conforms to protocol %@", NSStringFromProtocol(@protocol(MTDataObject)));
	}

	return self;
}

// creates and return ViewModel for model at thread. if no thread is provided
-(instancetype)createViewModel:(Class)className forIndexPath:(NSIndexPath *)indexPath {
	id viewModel = [className alloc];
	NSAssert([viewModel respondsToSelector:@selector(initWithModel:)], @"You must implement the 'initWithModel:' selector for '%@'", NSStringFromClass(className));

	id<MTDataObject>model;

	if(indexPath) {
		model = [self modelAtIndexPath:indexPath];
	} else {
		model = (id<MTDataObject>)[[self.modelClass alloc] init];
	}

	return [viewModel performSelector:@selector(initWithModel:) withObject:model];
}

-(id<MTDataObject>)modelAtIndexPath:(NSIndexPath *)indexPath {
	id<MTDataProviderCollection>models = [self models];
	return ((models && (indexPath.row < [models count])) ? models[(NSUInteger)indexPath.row] : nil);
}

-(void)prepare:(BOOL)forceUpdate {
	if(forceUpdate || _models == nil) {
		_models = [self prepareModels];
	}
}

-(id<MTDataProviderCollection>)models {
	[self prepare:NO];
	return _models;
}

-(void)refresh {
	_models = nil;
}

-(MTDataProvider *)makeQuery:(void(^)(MTDataQuery *query, MTDataSort *sort))block {
	_query = (MTDataQuery *)[[[self queryClass] alloc] init];
	_sort = (MTDataSort *)[[[self sortClass] alloc] init];
	block(_query, _sort);
	[self refresh];
	return self;
}

-(Class)sortClass {
	return [MTDataSort class];
}

-(Class)queryClass {
	return [MTDataQuery class];
}

-(void)setQuery:(MTDataQuery *)query {
	NSAssert([query isKindOfClass:self.queryClass], @"Query[%@] must be kind of [%@] class.", query.class, self.queryClass);
	if(_query != query) {
		_query = query;
		[self refresh];
	}
}

-(void)setSort:(MTDataSort *)sort {
	NSAssert([sort isKindOfClass:self.sortClass], @"Sort[%@] must be kind of [%@] class.", sort.class, self.sortClass);
	if(_sort != sort) {
		_sort = sort;
		[self refresh];
	}
}
@end