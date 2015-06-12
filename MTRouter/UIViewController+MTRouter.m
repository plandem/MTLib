//
// Created by Andrey on 10/06/15.
// Copyright (c) 2015 Melatonin LLC. All rights reserved.
//

#import <objc/runtime.h>
#import "NSObject+Swizzle.h"
#import "UIViewController+MTRouter.h"
#import "MTRouterProtocol.h"

@implementation UIViewController (MTRouter)
@dynamic router;

+(void)load {
	[self swizzleInstanceSelector:@selector(prepareForSegue:sender:) withNewSelector:@selector(swizzle_prepareForSegue:sender:)];
}

-(id <MTRouterProtocol>)router {
	return objc_getAssociatedObject(self, @selector(router));
}

-(void)setRouter:(id <MTRouterProtocol>)router {
	objc_setAssociatedObject(self, @selector(router), router, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

-(NSMutableDictionary *)segueCacheBlocks {
	NSMutableDictionary *cache = objc_getAssociatedObject(self, @selector(segueCacheBlocks));
	if(cache == nil) {
		cache = [NSMutableDictionary dictionary];
		[self setSegueCacheBlocks:cache];
	}

	return cache;
}

-(void)setSegueCacheBlocks:(NSMutableDictionary *)cache {
	objc_setAssociatedObject(self, @selector(segueCacheBlocks), cache, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

-(void)setPreparationBlock:(MTRouterPreparationBlock)block forSegueWithIdentifier:(NSString *)identifier {
	NSMutableDictionary *cache = [self segueCacheBlocks];
	if (block) {
		cache[identifier] = [block copy];
	} else {
		[cache removeObjectForKey:identifier];
	}
}

-(void)performSegueWithIdentifier:(NSString *)identifier sender:(id)sender preparationBlock:(MTRouterPreparationBlock)block {
	[self setPreparationBlock:block forSegueWithIdentifier:identifier];
	[self performSegueWithIdentifier:identifier sender:sender];
}

-(MTRouterPreparationBlock)preparationBlockForSegue:(UIStoryboardSegue *)segue {
	NSDictionary *cache = [self segueCacheBlocks];
	return cache[segue.identifier];
}

-(void)swizzle_prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
	[self swizzle_prepareForSegue:segue sender:sender];

	[self.router prepareForSegue:segue sender:sender];
	[self setPreparationBlock:nil forSegueWithIdentifier:segue.identifier];
}
@end