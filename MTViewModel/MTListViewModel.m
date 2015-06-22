//
// Created by Andrey on 02/06/15.
// Copyright (c) 2015 Melatonin LLC. All rights reserved.
//

#import "MTDataRepository.h"
#import "MTListViewModel+Cache.h"

@interface MTListViewModel()
@property (nonatomic, strong) RACSignal *updatedContentSignal;
@property (nonatomic, strong) MTDataProvider *dataProvider;
@property (nonatomic, assign) BOOL hasChanges;
@end

@implementation MTListViewModel
-(id)initWithRepository:(MTDataRepository *)repository {
	if ((self = [super init])) {
		_dataProvider = [(MTDataProvider *) [[(id<MTDataObject>)[repository modelClass] dataProviderClass] alloc] initWithRepository:repository];
		_updatedContentSignal = [RACSubject subject];
		_refreshOnChanges = YES;
		_hasChanges = YES;

		@weakify(self);
		_dataProvider.refreshBlock = ^(MTDataProvider *provider) {
			@strongify(self);
			self.hasChanges = YES;
			[self reloadIfNeeded];
		};

		[self.didBecomeActiveSignal subscribeNext:^(id x) {
			@strongify(self);
			[self reloadIfNeeded];
		}];
	}

	return self;
}

-(void)reloadIfNeeded {
	if(_refreshOnChanges && _hasChanges && self.isActive) {
		_hasChanges = NO;

		//reset cached model
		[self modelAtIndexPath:nil];

		//reset fetched data
		[self reload];

		//send refresh UI signal
		[(RACSubject *)_updatedContentSignal sendNext:nil];
	}
}

-(void)reload {
	[_dataProvider refresh];
}

-(void)deleteAtIndexPath:(NSIndexPath *)indexPath {
	[self.dataProvider deleteAtIndexPath:indexPath];
}

-(void)moveFromIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath {
	[self.dataProvider moveFromIndexPath:fromIndexPath toIndexPath:toIndexPath];
}

-(id)createViewModel:(Class)viewModelClass forIndexPath:(NSIndexPath *)indexPath {
	return [self.dataProvider createViewModel:viewModelClass forIndexPath:indexPath];
}

-(NSInteger)numberOfSections {
	return 1;
}

-(NSInteger)numberOfItemsInSection:(NSInteger)section {
	return [_dataProvider.models count];
}
@end