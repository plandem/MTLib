//
// Created by Andrey on 26/04/15.
// Copyright (c) 2015 Melatonin LLC. All rights reserved.
//

#import <libextobjc/extobjc.h>
#import "MTDataQuery.h"
#import "MTDataSort.h"

@interface MTDataQuery()
@property(nonatomic, strong) NSPredicate *predicate;
@property(nonatomic, strong) MTDataSort *sort;
@property(nonatomic, assign) NSUInteger batchSize;
@property(nonatomic, assign) NSCompoundPredicateType operator;
@end

@implementation MTDataQuery

-(instancetype)init {
	if((self = [super init])) {
		_operator = NSAndPredicateType;
		_batchSize = 0;
	}

	return self;
}

-(void)setPredicate:(NSPredicate *)predicate {
	if(_predicate == nil) {
		_predicate = predicate;
	} else if(predicate) {
		if(_operator == NSOrPredicateType) {
			_predicate = [NSCompoundPredicate orPredicateWithSubpredicates:@[_predicate, predicate]];
		} else if(_operator == NSAndPredicateType) {
			_predicate = [NSCompoundPredicate andPredicateWithSubpredicates:@[_predicate, predicate]];
		}
	}
}

-(NSPredicate *)processCondition:(id)first arguments:(va_list)arguments not:(BOOL)not{
	NSPredicate *predicate;

	if([first isKindOfClass:[NSString class]]) {
		predicate = [NSPredicate predicateWithFormat:first arguments:arguments];
	} else if([first isKindOfClass:[NSPredicate class]]) {
		predicate = first;
	} else {
		NSAssert(false, @"Unsupported type of of condition. Only NSString and NSPredicate are allowed.");
	}

	//variable substitution?
	if(predicate && [predicate.predicateFormat containsString:@"$"]) {
		id params = va_arg(arguments, id);
		NSAssert(params && [params isKindOfClass:[NSDictionary class]], @"Only NSDictionary is allowed for variable substituion.");
		predicate = [predicate predicateWithSubstitutionVariables:params];
	}

	return ((not) ? [NSCompoundPredicate notPredicateWithSubpredicate:predicate] : predicate);
}

-(void)processSubQueryBlock:(MTDataQueryBlock) block operator:(NSCompoundPredicateType)operator {
	NSCompoundPredicateType currentOperator = _operator;

	if(_operator != NSNotPredicateType) {
		_operator = operator;
	}

	if(block == nil) {
		return;
	}

	MTDataQuery *subQuery = (MTDataQuery *)[[self.class alloc] init];
	block(subQuery);

	self.predicate = ((operator != NSNotPredicateType)
			? subQuery.predicate
			: [NSCompoundPredicate notPredicateWithSubpredicate:subQuery.predicate]);

	_operator = currentOperator;
}

-(NSPredicate *)processBetween:(NSString *)attribute from:(id)from to:(id)to not:(BOOL)not {
	NSPredicate *predicate = [NSPredicate predicateWithFormat:@"%K >= %@ AND %K <= %@", attribute, from, attribute, to];
	return ((not) ? [NSCompoundPredicate notPredicateWithSubpredicate:predicate] : predicate);
}

-(NSPredicate *)processIn:(NSString *)attribute array:(NSArray *)array not:(BOOL)not {
	NSPredicate *predicate = [NSPredicate predicateWithFormat:@"%K IN %@", attribute, array];
	return ((not) ? [NSCompoundPredicate notPredicateWithSubpredicate:predicate] : predicate);
}

-(NSPredicate *)processBeginsWith:(NSString *)attribute string:(NSString *)string not:(BOOL)not {
	NSPredicate *predicate = [NSPredicate predicateWithFormat:@"%K BEGINSWITH %@", attribute, string];
	return ((not) ? [NSCompoundPredicate notPredicateWithSubpredicate:predicate] : predicate);
}

-(NSPredicate *)processEndsWith:(NSString *)attribute string:(NSString *)string not:(BOOL)not {
	NSPredicate *predicate = [NSPredicate predicateWithFormat:@"%K ENDSWITH %@", attribute, string];
	return ((not) ? [NSCompoundPredicate notPredicateWithSubpredicate:predicate] : predicate);
}

-(NSPredicate *)processContains:(NSString *)attribute string:(NSString *)string not:(BOOL)not {
	NSPredicate *predicate = [NSPredicate predicateWithFormat:@"%K CONTAINS %@", attribute, string];
	return ((not) ? [NSCompoundPredicate notPredicateWithSubpredicate:predicate] : predicate);
}

-(MTDataQuery *(^)(id first, ...))condition {
	@weakify(self);
	return ^MTDataQuery *(id first, ...) {
		@strongify(self);
		va_list args;
		va_start(args, first);
		self.predicate = [self processCondition:first arguments:args not:NO];
		va_end(args);
		return self;
	};
}

-(MTDataQuery *(^)(id first, ...))notCondition {
	@weakify(self);
	return ^MTDataQuery *(id first, ...) {
		@strongify(self);
		va_list args;
		va_start(args, first);
		self.predicate = [self processCondition:first arguments:args not:YES];
		va_end(args);
		return self;
	};
}

-(MTDataQuery *(^)(NSString *attribute, id from, id to))between {
	@weakify(self);
	return ^MTDataQuery *(NSString *attribute, id from, id to) {
		@strongify(self);
		self.predicate = [self processBetween:attribute from:from to:to not:NO];
		return self;
	};
}

-(MTDataQuery *(^)(NSString *attribute, id from, id to))notBetween {
	@weakify(self);
	return ^MTDataQuery *(NSString *attribute, id from, id to) {
		@strongify(self);
		self.predicate = [self processBetween:attribute from:from to:to not:YES];
		return self;
	};
}

-(MTDataQuery *(^)(NSString *attribute, NSArray *array))in {
	@weakify(self);
	return ^MTDataQuery *(NSString *attribute, NSArray *array) {
		@strongify(self);
		self.predicate = [self processIn:attribute array:array not:NO];
		return self;
	};
}

-(MTDataQuery *(^)(NSString *attribute, NSArray *array))notIn {
	@weakify(self);
	return ^MTDataQuery *(NSString *attribute, NSArray *array) {
		@strongify(self);
		self.predicate = [self processIn:attribute array:array not:YES];
		return self;
	};
}

-(MTDataQuery *(^)(NSString *attribute, NSString *string))beginsWith {
	@weakify(self);;
	return ^MTDataQuery *(NSString *attribute, NSString *string) {
		@strongify(self);
		self.predicate = [self processBeginsWith:attribute string:string not:NO];
		return self;
	};
}

-(MTDataQuery *(^)(NSString *attribute, NSString *string))notBeginsWith {
	@weakify(self);;
	return ^MTDataQuery *(NSString *attribute, NSString *string) {
		@strongify(self);
		self.predicate = [self processBeginsWith:attribute string:string not:YES];
		return self;
	};
}

-(MTDataQuery *(^)(NSString *attribute, NSString *string))endsWith {
	@weakify(self);;
	return ^MTDataQuery *(NSString *attribute, NSString *string) {
		@strongify(self);
		self.predicate = [self processEndsWith:attribute string:string not:NO];
		return self;
	};
}

-(MTDataQuery *(^)(NSString *attribute, NSString *string))notEndsWith {
	@weakify(self);;
	return ^MTDataQuery *(NSString *attribute, NSString *string) {
		@strongify(self);
		self.predicate = [self processEndsWith:attribute string:string not:YES];
		return self;
	};
}

-(MTDataQuery *(^)(NSString *attribute, NSString *string))contains {
	@weakify(self);;
	return ^MTDataQuery *(NSString *attribute, NSString *string) {
		@strongify(self);
		self.predicate = [self processContains:attribute string:string not:NO];
		return self;
	};
}

-(MTDataQuery *(^)(NSString *attribute, NSString *string))notContains {
	@weakify(self);;
	return ^MTDataQuery *(NSString *attribute, NSString *string) {
		@strongify(self);
		self.predicate = [self processContains:attribute string:string not:YES];
		return self;
	};
}

-(MTDataQuery *(^)(MTDataQueryBlock block))and {
	@weakify(self);;
	return ^MTDataQuery *(MTDataQueryBlock block) {
		@strongify(self);
		[self processSubQueryBlock:block operator:NSAndPredicateType];
		return self;
	};
}

-(MTDataQuery *(^)(MTDataQueryBlock block))or {
	@weakify(self);;
	return ^MTDataQuery *(MTDataQueryBlock block) {
		@strongify(self);
		[self processSubQueryBlock:block operator:NSOrPredicateType];
		return self;
	};
}

-(MTDataQuery *(^)(MTDataQueryBlock block))not {
	@weakify(self);;
	return ^MTDataQuery *(MTDataQueryBlock block) {
		@strongify(self);
		[self processSubQueryBlock:block operator:NSNotPredicateType];
		return self;
	};
}

-(MTDataQuery *(^)(NSUInteger limit))limit {
	@weakify(self);;
	return ^MTDataQuery *(NSUInteger limit) {
		@strongify(self);
		self.batchSize = limit;
		return self;
	};
}

+(Class)sortClass {
	return [MTDataSort class];
}

-(MTDataSort *)sort {
	if(_sort == nil) {
		_sort = (MTDataSort *)[[[[self class] sortClass] alloc] init];
	}

	return _sort;
}
@end