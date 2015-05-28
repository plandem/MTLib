//
// Created by Andrey on 28/05/15.
//

#import <CoreData/CoreData.h>
#import "MTDataRepository.h"

@interface MTCoreDataRepository : MTDataRepository
@property (nonatomic, readonly) NSManagedObjectContext *context;
- (instancetype)initWithModelClass:(Class)modelClass withContext:(NSManagedObjectContext *)context;
@end