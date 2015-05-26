//
// Created by Andrey on 27/04/15.
// Copyright (c) 2015 Melatonin LLC. All rights reserved.
//

#import "MTDataProvider.h"

@interface MTDataProvider ()
@property (nonatomic, strong) id<NSFastEnumeration> models;
@property (nonatomic, strong) Class modelClass;
@end

@implementation MTDataProvider

-(instancetype)initWithModelClass:(Class)modelClass {
	if ((self = [super init])) {
		self.modelClass = modelClass;
		NSAssert([modelClass conformsToProtocol:@protocol(MTDataObject)], @"Class must conforms to protocol %@", NSStringFromProtocol(@protocol(MTDataObject)));
	}

	return self;
}

// creates and return ViewModel for model
-(instancetype)createViewModel:(Class)className forIndexPath:(NSIndexPath *)indexPath {
	id viewModel = [className alloc];
	NSAssert([viewModel respondsToSelector:@selector(initWithModel:)], @"You must implement the 'initWithModel:' selector for '%@'", NSStringFromClass(className));

	id<MTDataObject> model;

	if(indexPath) {
		model = [self modelAtIndexPath:indexPath];
	} else {
		model = [[self.modelClass alloc] init];
	}

	viewModel = [viewModel performSelector:@selector(initWithModel:) withObject:model];
	return viewModel;
}

-(void)prepare:(BOOL)forceUpdate {
	if(forceUpdate || _models == nil) {
		_models = [self prepareModels];
	}
}

-(id<NSFastEnumeration>)models {
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
	}
}

-(void)setSort:(MTDataSort *)sort {
	NSAssert([sort isKindOfClass:self.sortClass], @"Sort[%@] must be kind of [%@] class.", sort.class, self.sortClass);
	if(_sort != sort) {
		_sort = sort;
	}
}
@end