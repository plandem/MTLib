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
//@property (nonatomic, strong) RACDisposable *validator;
@end

@implementation MTEditViewModel
-(id)initWithModel:(id<MTDataObject>)model fromRepository:(MTDataRepository *)repository {
	if ((self = [super init])) {
		NSAssert([[model class] isEqual:[repository modelClass]], @"Model %@ must be same type as repository's model type %@.", NSStringFromClass([model class]), NSStringFromClass([repository modelClass]));
		_dataRepository = repository;
		_model = model;
//		_isValid = NO;
		_isValid = YES;

		[self setup];
		[self setupValidator];
	}

	return self;
}

-(void)setup {

}

-(void)save {
	if(_isValid) {
		[_dataRepository withTransaction:^(MTDataRepository *repository){
			[_dataRepository saveModel:_model];
		}];
	} else  {
		DDLogError(@"Unpredictable behaviour, model %@ is not valid yet, but there is a request to save it.", _model);
	}
}

-(void)cancel {
	[_dataRepository undoModel:_model];
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