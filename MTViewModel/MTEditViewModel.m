//
// Created by Andrey on 15/06/15.
// Copyright (c) 2015 Melatonin LLC. All rights reserved.
//
#import "MTLogger.h"
#import "MTEditViewModel.h"

@interface MTEditViewModel()
@property (nonatomic, strong) MTDataRepository *dataRepository;
@property (nonatomic, strong) id<MTDataObject> model;
@property (nonatomic, assign) BOOL isValid;
@property (nonatomic, assign) BOOL readOnly;
//@property (nonatomic, strong) RACDisposable *validator;
@end

@implementation MTEditViewModel
-(id)initWithModel:(id<MTDataObject>)model fromRepository:(MTDataRepository *)repository {
	if ((self = [super init])) {
		NSAssert([model isKindOfClass:[repository modelClass]], @"Model %@ must be same type as repository's model type %@.", NSStringFromClass([model class]), NSStringFromClass([repository modelClass]));
		_dataRepository = repository;
		_model = model;
//		_isValid = NO;
		_isValid = YES;

		//some types of repositories can require active transaction for any changes on object
		[_dataRepository beginTransaction];

		//bindings and other setup
		[self setup];
		[self setupValidator];
	}

	return self;
}

-(void)dealloc {
	if([_dataRepository inTransaction]) {
		DDLogError(@"Unpredictable behaviour, repository was in transaction, no any action to save or cancel model %@.", _model);
	}
}

-(void)setup {

}

-(void)save {
	if(_isValid) {
		_readOnly = YES;
		[_dataRepository saveModel:_model];
		[_dataRepository commitTransaction];
	} else  {
		DDLogError(@"Unpredictable behaviour, model %@ is not valid yet, but there is a request to save it.", _model);
	}
}

-(void)cancel {
	_readOnly = YES;
	[_dataRepository undoModel:_model];
	[_dataRepository rollbackTransaction];
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
@end