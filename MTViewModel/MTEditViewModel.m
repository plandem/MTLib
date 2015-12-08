//
// Created by Andrey on 15/06/15.
// Copyright (c) 2015 Melatonin LLC. All rights reserved.
//
#import <ReactiveCocoa/ReactiveCocoa.h>
#import "MTLogger.h"
#import "MTEditViewModel.h"

@interface MTEditViewModel()
@property (nonatomic, strong) MTDataRepository *dataRepository;
@property (nonatomic, strong) id<MTDataObject> model;
@property (nonatomic, assign) BOOL isValid;
//@property (nonatomic, strong) RACDisposable *validator;
@end

@implementation MTEditViewModel {
	NSMutableDictionary *_modelValues;
}

-(id)initWithModel:(id<MTDataObject>)model fromRepository:(MTDataRepository *)repository {
	if ((self = [super init])) {
		NSAssert([model isKindOfClass:[repository modelClass]], @"Model %@ must be same type as repository's model type %@.", NSStringFromClass([model class]), NSStringFromClass([repository modelClass]));
		_dataRepository = repository;
		_model = model;
		_modelValues = [NSMutableDictionary dictionary];
//		_isValid = NO;
		_isValid = YES;

		//bindings and other setup
		[self setup];
		[self setupValidator];
	}

	return self;
}

-(void)setup {

}

-(void)save {
	//validate data
	if(!_isValid) {
		DDLogError(@"Unpredictable behaviour, model %@ is not valid yet, but there is a request to save it.", _model);
		return;
	}

	//TODO: think about moving saving process out of 'withTransaction' and put it between 'beginTransaction/commitTransaction'.
	@weakify(self);
	[self.dataRepository withTransaction:^(MTDataRepository *repository) {
		@strongify(self);

		NSMutableSet *transformable = [NSMutableSet setWithArray:[[self.model class] respondsToSelector:@selector(transformable)] ? [[self.model class] transformable] : @[]];
		BOOL canTransform = [self.model respondsToSelector:@selector(transformableRefreshForKey:)];

		//TODO: think about 'dirty' values. Right now we ALWAYS consider model as changed for any attribute in _modelValues
		//in case of 'transformable' it's ok, but model actually can have no changes for common attributes.
		[_modelValues enumerateKeysAndObjectsUsingBlock:^(id key, id value, BOOL *stop) {
			if ([value isEqual:[NSNull null]]) {
				value = nil;
			}

			//if attribute is transformable, then force model to refresh it
			if(canTransform) {
				NSRange relation;
				NSString *transformableKey = nil;

				if([transformable containsObject:key]) {
					transformableKey = key;
				} else if((relation = [key rangeOfString:@"."]).location != NSNotFound) {
					//in case of relation we want to refresh transformable value only once
					transformableKey = [key substringToIndex:relation.location];
					if(![transformable containsObject:transformableKey]) {
						transformableKey = nil;
					}
				}

				if(transformableKey) {
					[self.model transformableRefreshForKey:transformableKey];
					[transformable removeObject:transformableKey];
				}
			}

			//we are using keyPath, because in some cases it can be required to set value to related object
			[(id)self.model setValue:value forKeyPath:key];
		}];

		[repository saveModel:self.model];
		[_modelValues removeAllObjects];
	}];
}

-(void)cancel {
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
	value = [(id)self.model valueForKeyPath:key];
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
}
@end