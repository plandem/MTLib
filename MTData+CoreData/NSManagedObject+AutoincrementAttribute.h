//
// Created by Andrey on 15/06/15.
// Copyright (c) 2015 Melatonin LLC. All rights reserved.
//

#import <CoreData/CoreData.h>

@interface NSManagedObject (AutoincrementAttribute)
// Will not work correctly if some models will be in process of creation at another context.
-(void)autoincrement:(NSString *)attribute;
-(void)autoincrement:(NSString *)attribute byStep:(NSInteger)step;
-(void)autoincrement:(NSString *)attribute groupBy:(NSString *)groupAttribute;
-(void)autoincrement:(NSString *)attribute groupBy:(NSString *)groupAttribute byStep:(NSInteger)step;
@end