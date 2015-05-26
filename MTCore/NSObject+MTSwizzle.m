//
// Created by Andrey on 26/04/15.
// Copyright (c) 2015 Melatonin LLC. All rights reserved.
//

#import <objc/runtime.h>
#import "NSObject+MTSwizzle.h"

@implementation NSObject (MTSwizzle)

+(void) swizzleInstanceSelector:(SEL)originalSelector withNewSelector:(SEL)newSelector {
/*	Class cls = self;
	SEL original = originalSelector;
	SEL replacement = newSelector;

	Method originalMethod;
	if ((originalMethod = class_getClassMethod(cls, original))) { //selectors for classes take priority over instances should there be a -propertyName and +propertyName
		Method replacementMethod = class_getClassMethod(cls, replacement);
		method_exchangeImplementations(originalMethod, replacementMethod);  //because class methods are really just statics, there's no method heirarchy to perserve, so we can directly exchange IMPs
	} else {
		//get the replacement IMP
		//set the original IMP on the replacement selector
		//try to add the replacement IMP directly to the class on original selector
		//if it succeeds then we're all good (the original before was located on the superclass)
		//if it doesn't then that means an IMP is already there so we have to overwrite it
		IMP replacementImplementation = method_setImplementation(class_getInstanceMethod(cls, replacement), class_getMethodImplementation(cls, original));
		if (!class_addMethod(cls, original, replacementImplementation, method_getTypeEncoding(class_getInstanceMethod(cls, replacement)))) method_setImplementation(class_getInstanceMethod(cls, original), replacementImplementation);
	}*/

//////////////
//	Method originalMethod = class_getInstanceMethod(cls, originalSel);
//	Method newMethod = class_getInstanceMethod(cls, newSel);
//	method_exchangeImplementations(originalMethod, newMethod);
//////////////
	Method originalMethod = class_getInstanceMethod(self, originalSelector);
	Method newMethod = class_getInstanceMethod(self, newSelector);

	BOOL methodAdded = class_addMethod([self class],
			originalSelector,
			method_getImplementation(newMethod),
			method_getTypeEncoding(newMethod));

	if (methodAdded) {
		class_replaceMethod([self class],
				newSelector,
				method_getImplementation(originalMethod),
				method_getTypeEncoding(originalMethod));
	} else {
		method_exchangeImplementations(originalMethod, newMethod);
	}
}

+(void) swizzleClassSelector:(SEL)originalSelector withNewSelector:(SEL)newSelector {
//////////
//	Method originalMethod = class_getClassMethod(cls, originalSel);
//	Method newMethod = class_getClassMethod(cls, newSel);
//	method_exchangeImplementations(originalMethod, newMethod);
//////////

	Method originalMethod = class_getClassMethod(self, originalSelector);
	Method newMethod = class_getClassMethod(self, newSelector);

	BOOL methodAdded = class_addMethod([self class],
			originalSelector,
			method_getImplementation(newMethod),
			method_getTypeEncoding(newMethod));

	if (methodAdded) {
		class_replaceMethod([self class],
				newSelector,
				method_getImplementation(originalMethod),
				method_getTypeEncoding(originalMethod));
	} else {
		method_exchangeImplementations(originalMethod, newMethod);
	}
}
@end