//
// Created by Andrey on 26/05/15.
// Copyright (c) 2015 Melatonin LLC. All rights reserved.
//

#import "MTLogger.h"
#import "MTCoreDataStack.h"

@interface MTCoreDataStack ()
@property (strong, nonatomic) NSPersistentStoreCoordinator *persistentStoreCoordinator;
@property (strong, nonatomic) NSManagedObjectModel *managedObjectModel;
@property (strong, nonatomic) NSString *managedObjectModelName;
@end

@implementation MTCoreDataStack
-(instancetype)initWithModelName:(NSString *)modelName {
	if((self = [self init])) {
		self.managedObjectModelName = modelName;
	}

	return self;
}

+ (instancetype)defaultStack {
	return [self setup:[[NSBundle mainBundle] infoDictionary][@"CFBundleDisplayName"]];
}

+ (instancetype)defaultStackWithModel:(NSString *)modelFileName {
	return [self setup:modelFileName];
}

+ (instancetype)inMemoryStack {
	return [self setupInMemory:[[NSBundle mainBundle] infoDictionary][@"CFBundleDisplayName"]];
}

+ (instancetype)inMemoryStackWithModel:(NSString *)modelFileName {
	return [self setupInMemory:modelFileName];
}

+ (instancetype)setup:(NSString *)modelName {
	static MTCoreDataStack *stack;
	static dispatch_once_t onceToken;
	dispatch_once(&onceToken, ^{
		stack = [[self alloc] initWithModelName:modelName];
	});

	return stack;
}

+(instancetype)setupInMemory:(NSString *)modelName {
	static MTCoreDataStack *stack = nil;
	static dispatch_once_t onceToken;
	dispatch_once(&onceToken, ^{
		stack = [[self alloc] initWithModelName:modelName];

		NSPersistentStoreCoordinator *persistentStoreCoordinator = [[NSPersistentStoreCoordinator alloc] initWithManagedObjectModel:[stack managedObjectModel]];
		NSError *error;

		if (![persistentStoreCoordinator addPersistentStoreWithType:NSInMemoryStoreType configuration:nil URL:nil options:nil error:&error])
			DDLogError(@"Unresolved error %@, %@", error, [error userInfo]);

		stack.persistentStoreCoordinator = persistentStoreCoordinator;
	});

	return stack;
}

#pragma mark - Stack Setup
- (NSPersistentStoreCoordinator *)persistentStoreCoordinator {
	if (!_persistentStoreCoordinator) {
		_persistentStoreCoordinator = [[NSPersistentStoreCoordinator alloc] initWithManagedObjectModel:self.managedObjectModel];
		NSError *error = nil;

		if (![_persistentStoreCoordinator addPersistentStoreWithType:NSSQLiteStoreType configuration:nil URL:[self persistentStoreURL] options:[self persistentStoreOptions] error:&error]) {
			DDLogError(@"Error adding persistent store. %@, %@", error, error.userInfo);
		}
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
	NSString *appName = [[NSBundle mainBundle] infoDictionary][@"CFBundleDisplayName"];
	appName = [appName stringByAppendingString:@".sqlite"];

	return [[self applicationDocumentsDirectory] URLByAppendingPathComponent:appName];
}

- (NSDictionary *)persistentStoreOptions {
	return @{NSInferMappingModelAutomaticallyOption: @YES, NSMigratePersistentStoresAutomaticallyOption: @YES, NSSQLitePragmasOption: @{@"synchronous": @"OFF"}};
}

- (NSURL *)applicationDocumentsDirectory {
	return [[[NSFileManager defaultManager] URLsForDirectory:NSDocumentDirectory inDomains:NSUserDomainMask] lastObject];
}

@end