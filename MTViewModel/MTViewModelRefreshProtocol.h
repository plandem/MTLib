//
// Created by Andrey on 15/12/15.
//

#import <Foundation/Foundation.h>

@protocol MTViewModelRefreshProtocol <NSObject>
@property (nonatomic, readonly) RACSignal *updatedContentSignal;
@end