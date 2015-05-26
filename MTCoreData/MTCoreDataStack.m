//
// Created by Andrey on 26/05/15.
// Copyright (c) 2015 Melatonin LLC. All rights reserved.
//

#import "MTCoreDataStack.h"

@interface MTCoreDataStack ()
@property (strong, nonatomic) NSPersistentStoreCoordinator *persistentStoreCoordinator;
@property (strong, nonatomic) NSManagedObjectModel *managedObjectModel;
@property (strong, nonatomic) NSString *managedObjectModelName;
@end

@implementation MTCoreDataStack
- (instancetype)initWithModelName:(NSString *)modelName {
	if((self = [self init])) {
		self.managedObjectModelName = modelName;
	}

	return self;
}

+ (NSString *)defaultName {
	static NSString *defaultName;
	static dispatch_once_t onceToken;
	dispatch_once(&onceToken, ^{
		NSDictionary *info = [[NSBundle mainBundle] infoDictionary];
		if(info[@"CFBundleDisplayName"]) {
			defaultName = info[@"CFBundleDisplayName"];
		} else if(info[@"CFBundleName"]) {
			defaultName = info[@"CFBundleName"];
		}
	});

	return defaultName;
}

+ (instancetype)defaultStack {
	return [self setup:[MTCoreDataStack defaultName] inMemory:NO];
}

+ (instancetype)defaultStackWithModel:(NSString *)modelFileName {
	return [self setup:modelFileName inMemory:NO];
}

+ (instancetype)inMemoryStack {
	return [self setup:[MTCoreDataStack defaultName] inMemory:YES];
}

+ (instancetype)inMemoryStackWithModel:(NSString *)modelFileName {
	return [self setup:modelFileName inMemory:YES];
}

+ (instancetype)setup:(NSString *)modelName inMemory:(BOOL)inMemory {
	static MTCoreDataStack *stack;
	static dispatch_once_t onceToken;
	dispatch_once(&onceToken, ^{
		stack = [[self alloc] initWithModelName:modelName];

		@try {
			NSError *error;
			NSString *type;
			NSURL *url;
			NSDictionary *options;

			if(inMemory) {
				type = NSInMemoryStoreType;
			} else {
				type = NSSQLiteStoreType;
				url = [stack persistentStoreURL];
				options = [stack persistentStoreOptions];
			}

			if (![stack.persistentStoreCoordinator addPersistentStoreWithType:type configuration:nil URL:url options:options error:&error]) {
				@throw([NSException exceptionWithName:@"MTCoreDataStack" reason:error.userInfo[@"reason"] userInfo:error.userInfo]);
			}
		} @catch(NSException *e) {
			NSAssert(false, e.reason);
		}
	});

	return stack;
}

- (NSPersistentStoreCoordinator *)persistentStoreCoordinator {
	if (!_persistentStoreCoordinator) {
		_persistentStoreCoordinator = [[NSPersistentStoreCoordinator alloc] initWithManagedObjectModel:self.managedObjectModel];
	}

	return _persistentStoreCoordinator;
}

- (NSManagedObjectModel *)managedObjectModel {
	if (!_managedObjectModel) {
		NSURL *modelURL = [[NSBundle mainBundle] URLForResource:_managedObjectModelName withExtension:@"momd"];
		_managedObjectModel = [[NSManagedObjectModel alloc] initWithContentsOfURL:modelURL];
	}

	return _managedObjectModel;
}

- (NSURL *)persistentStoreURL {
	NSString *url = [_managedObjectModelName stringByAppendingString:@".sqlite"];
	return [[self applicationDocumentsDirectory] URLByAppendingPathComponent:url];
}

- (NSDictionary *)persistentStoreOptions {
	return @{
			NSInferMappingModelAutomaticallyOption: @YES,
			NSMigratePersistentStoresAutomaticallyOption: @YES,
			NSSQLitePragmasOption: @{@"synchronous": @"OFF"}
	};
}

- (NSURL *)applicationDocumentsDirectory {
	return [[[NSFileManager defaultManager] URLsForDirectory:NSDocumentDirectory inDomains:NSUserDomainMask] lastObject];
}

@end