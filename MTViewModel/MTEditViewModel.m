//
// Created by Andrey on 15/06/15.
// Copyright (c) 2015 Melatonin LLC. All rights reserved.
//
#import <ReactiveCocoa/ReactiveCocoa.h>
#import "MTLogger.h"
#import "MTEditViewModel.h"

@interface MTEditViewModel()
@property (nonatomic, strong) MTDataRepository *dataRepository;
@property (nonatomic, strong) id model;
@property (nonatomic, assign) BOOL isValid;
//@property (nonatomic, strong) RACDisposable *validator;
@end

@implementation MTEditViewModel {
	NSMutableDictionary *_modelValues;
	NSMutableSet *_changedValues;
}

-(id)initWithModel:(id)model {
	if ((self = [super init])) {
		_model = model;
		_modelValues = [NSMutableDictionary dictionary];
		_changedValues = [NSMutableSet set];
//		_isValid = NO;
		_isValid = YES;

		//bindings and other setup
		[self setup];
		[self setupValidator];
	}

	return self;
}

-(id)initWithModel:(id<MTDataObject>)model fromRepository:(MTDataRepository *)repository {
	if ((self = [self initWithModel:model])) {
		NSAssert([model isKindOfClass:[repository modelClass]], @"Model %@ must be same type as repository's model type %@.", NSStringFromClass([model class]), NSStringFromClass([repository modelClass]));
		_dataRepository = repository;
	}

	return self;
}

-(void)setup {

}

/**
 * sync all viewModel's changed values with model
 */
-(BOOL)sync {
	NSMutableSet *transformable = [NSMutableSet setWithArray:[[self.model class] respondsToSelector:@selector(transformable)] ? [[self.model class] transformable] : @[]];
	BOOL canTransform = [self.model respondsToSelector:@selector(transformableRefreshForKey:)];
   	BOOL totalChanges = ([_changedValues count] > 0);

	DDLogDebug(@"sync=%@", _changedValues);

	[_changedValues enumerateObjectsUsingBlock:^(id key, BOOL *stop) {
		id value = _modelValues[key];
		if ([value isEqual:[NSNull null]]) {
			value = nil;
		}

		//if attribute is transformable, then force model to refresh it
		if (canTransform) {
			NSRange relation;
			NSString *transformableKey = nil;

			if ([transformable containsObject:key]) {
				transformableKey = key;
			} else if ((relation = [key rangeOfString:@"."]).location != NSNotFound) {
				//in case of relation we want to refresh transformable value only once
				transformableKey = [key substringToIndex:relation.location];
				if (![transformable containsObject:transformableKey]) {
					transformableKey = nil;
				}
			}

			if (transformableKey) {
				[self.model transformableRefreshForKey:transformableKey];
				[transformable removeObject:transformableKey];
			}
		}

		//we are using keyPath, because in some cases it can be required to set value to related object
		[self.model setValue:value forKeyPath:key];
	}];

	[_modelValues removeAllObjects];
	[_changedValues removeAllObjects];
	return totalChanges;
}

-(void)save {
	//validate data
	if(!_isValid) {
		DDLogError(@"Unpredictable behaviour, model %@ is not valid yet, but there is a request to save it.", _model);
		return;
	}

	NSAssert([_model isKindOfClass:[_dataRepository modelClass]], @"Model %@ must be same type as repository's model type %@.", NSStringFromClass([_model class]), NSStringFromClass([_dataRepository modelClass]));
	//TODO: think about moving saving process out of 'withTransaction' and put it between 'beginTransaction/commitTransaction'.
	@weakify(self);
	[self.dataRepository withTransaction:^(MTDataRepository *repository) {
		@strongify(self);
		if([self sync]) {
			[repository saveModel:self.model];
		}
	}];
}

-(void)cancel {
	NSAssert([_model isKindOfClass:[_dataRepository modelClass]], @"Model %@ must be same type as repository's model type %@.", NSStringFromClass([_model class]), NSStringFromClass([_dataRepository modelClass]));

	//some repositories (E.g. CoreData) must revert created model or it will be saved in the future.
	[self.dataRepository undoModel:self.model];
}

-(void)setupValidator {
	//dispose previous validator, sometimes subclasses need to refresh result of combined signal from validate
//	if(_validator) {
//		[_validator dispose];
//		_validator = nil;
//	}
//
//	@weakify(self);
//	self.validator = [[[RACSignal combineLatest:[self observeAttributes]] map:^(RACTuple *result) {
//		@strongify(self);
//		return @([self.model validate]);
//	}] subscribeNext:^(NSNumber *isValid) {
//		@strongify(self);
//		self.isValid = [isValid boolValue];
//	}];
}

#pragma mark model getter/setter for FXForms
//we must override get/set for undefined to allow FXForms works transparently with properties of model.
- (id)valueForUndefinedKey:(NSString *)key {
	id value = _modelValues[key];
	if(value) {
		//return already requested value
		return value;
	}

	//we are using keyPath, because in some cases it can be required to get value from related object
	value = [self.model valueForKeyPath:key];
	if(value) {
		_modelValues[key] = value;
	}

	return value;
}

- (void)setValue:(id)value forUndefinedKey:(NSString *)key {
	if(value == nil) {
		value = [NSNull null];
	}

	_modelValues[key] = value;
	[_changedValues addObject:key];
}
@end