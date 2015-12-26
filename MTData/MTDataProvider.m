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

// creates and return ViewModel for model at indexPath. if no indexPath is provided then new model will be created
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
	//this implementation IS NOT supporting sections
	NSUInteger index = [indexPath indexAtPosition:1];
	return ((models && (index < [models count])) ? models[index] : nil);
}

-(void)deleteAtIndexPath:(NSIndexPath *)indexPath {
	id<MTDataObject>model = [self modelAtIndexPath:indexPath];
	[_repository deleteModel:model];
}

-(BOOL)moveFromIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath {
	if(_moveBlock && ![fromIndexPath isEqual:toIndexPath]) {
		id<MTDataObject>fromModel = [self modelAtIndexPath:fromIndexPath];
		id<MTDataObject>toModel = [self modelAtIndexPath:toIndexPath];
		return _moveBlock(self, fromIndexPath, fromModel, toIndexPath, toModel);
	} else {
		return NO;
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
	//by default do nothing. override to add specific behavior.
}
@end

/**
 * return block for basic sorting via dedicated integer attribute (E.g., instead of 1,2,3,4 -> 1000,2000,3000,4000 so we can divide it by 2)
 */
@implementation MTDataProvider(MTDataProviderBlocks)
-(MTDataProviderMoveBlock)sortingMoveBlock:(NSString *)attribute withStep:(NSInteger)step {
	//this implementation IS NOT supporting sections
	id sortingBlock = ^BOOL(MTDataProvider *dataProvider, NSIndexPath *fromIndexPath, id<MTDataObject>fromModel, NSIndexPath *toIndexPath, id<MTDataObject>toModel) {
		BOOL insert = NO;

		NSUInteger fromIndex = [fromIndexPath indexAtPosition:1];
		NSUInteger toIndex = [toIndexPath indexAtPosition:1];

		NSInteger toSorting = [[(NSObject *)toModel valueForKey:attribute] integerValue];
		NSInteger direction = 1;
		NSInteger newSorting;

		if(fromIndex < toIndex) {
			if([toIndexPath indexAtPosition:1] < [[dataProvider models] count] - 1) {
				insert = YES;
			}
		} else {
			if(toIndex > 0) {
				insert = YES;
			}

			direction = -1;
		}

		if(insert) {
			NSUInteger indexes[] = {[toIndexPath indexAtPosition:0], toIndex + direction};
			id<MTDataObject>nextModel = [dataProvider modelAtIndexPath:[NSIndexPath indexPathWithIndexes:indexes length:2]];
			NSInteger nextSorting = [[(NSObject *)nextModel valueForKey:attribute] integerValue];
			newSorting = toSorting + nextSorting;
			newSorting /= 2;
		} else {
			//normalize last/first sorting
			newSorting = (toSorting / step) * step;

			//increase/decrease by step
			newSorting += step * direction;
		}

		[(NSObject *)fromModel setValue:@(newSorting) forKey:attribute];
		return YES;
	};

	return sortingBlock;
}
@end