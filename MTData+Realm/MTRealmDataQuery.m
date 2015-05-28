//
// Created by Andrey on 28/05/15.
//

#import "MTRealmDataQuery.h"
#import "MTRealmDataSort.h"

@implementation MTRealmDataQuery
+(Class)sortClass {
	return [MTRealmDataSort class];
}
@end