//
// Created by Andrey on 26/04/15.
// Copyright (c) 2015 Andrey Gayvoronsky. All rights reserved.
//

#import "MTDataQuery.h"

@interface MTDataQuery()
@property(nonatomic, strong) NSPredicate *predicate;
@property(nonatomic, assign) NSCompoundPredicateType operator;
@end

@implementation MTDataQuery

-(instancetype)init {
	if((self = [super init])) {
		_operator = NSAndPredicateType;
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

	MTDataQuery *subQuery = [[MTDataQuery alloc] init];
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
	__weak typeof(self) weakSelf = self;
	return ^MTDataQuery *(id first, ...) {
		va_list args;
		va_start(args, first);
		weakSelf.predicate = [weakSelf processCondition:first arguments:args not:NO];
		va_end(args);
		return weakSelf;
	};
}

-(MTDataQuery *(^)(id first, ...))notCondition {
	__weak typeof(self) weakSelf = self;
	return ^MTDataQuery *(id first, ...) {
		va_list args;
		va_start(args, first);
		weakSelf.predicate = [weakSelf processCondition:first arguments:args not:YES];
		va_end(args);
		return weakSelf;
	};
}

-(MTDataQuery *(^)(NSString *attribute, id from, id to))between {
	__weak typeof(self) weakSelf = self;
	return ^MTDataQuery *(NSString *attribute, id from, id to) {
		weakSelf.predicate = [weakSelf processBetween:attribute from:from to:to not:NO];
		return weakSelf;
	};
}

-(MTDataQuery *(^)(NSString *attribute, id from, id to))notBetween {
	__weak typeof(self) weakSelf = self;
	return ^MTDataQuery *(NSString *attribute, id from, id to) {
		weakSelf.predicate = [weakSelf processBetween:attribute from:from to:to not:YES];
		return weakSelf;
	};
}

-(MTDataQuery *(^)(NSString *attribute, NSArray *array))in {
	__weak typeof(self) weakSelf = self;
	return ^MTDataQuery *(NSString *attribute, NSArray *array) {
		weakSelf.predicate = [weakSelf processIn:attribute array:array not:NO];
		return weakSelf;
	};
}

-(MTDataQuery *(^)(NSString *attribute, NSArray *array))notIn {
	__weak typeof(self) weakSelf = self;
	return ^MTDataQuery *(NSString *attribute, NSArray *array) {
		weakSelf.predicate = [weakSelf processIn:attribute array:array not:YES];
		return weakSelf;
	};
}

-(MTDataQuery *(^)(NSString *attribute, NSString *string))beginsWith {
	__weak typeof(self) weakSelf = self;
	return ^MTDataQuery *(NSString *attribute, NSString *string) {
		weakSelf.predicate = [weakSelf processBeginsWith:attribute string:string not:NO];
		return weakSelf;
	};
}

-(MTDataQuery *(^)(NSString *attribute, NSString *string))notBeginsWith {
	__weak typeof(self) weakSelf = self;
	return ^MTDataQuery *(NSString *attribute, NSString *string) {
		weakSelf.predicate = [weakSelf processBeginsWith:attribute string:string not:YES];
		return weakSelf;
	};
}

-(MTDataQuery *(^)(NSString *attribute, NSString *string))endsWith {
	__weak typeof(self) weakSelf = self;
	return ^MTDataQuery *(NSString *attribute, NSString *string) {
		weakSelf.predicate = [weakSelf processEndsWith:attribute string:string not:NO];
		return weakSelf;
	};
}

-(MTDataQuery *(^)(NSString *attribute, NSString *string))notEndsWith {
	__weak typeof(self) weakSelf = self;
	return ^MTDataQuery *(NSString *attribute, NSString *string) {
		weakSelf.predicate = [weakSelf processEndsWith:attribute string:string not:YES];
		return weakSelf;
	};
}

-(MTDataQuery *(^)(NSString *attribute, NSString *string))contains {
	__weak typeof(self) weakSelf = self;
	return ^MTDataQuery *(NSString *attribute, NSString *string) {
		weakSelf.predicate = [weakSelf processContains:attribute string:string not:NO];
		return weakSelf;
	};
}

-(MTDataQuery *(^)(NSString *attribute, NSString *string))notContains {
	__weak typeof(self) weakSelf = self;
	return ^MTDataQuery *(NSString *attribute, NSString *string) {
		weakSelf.predicate = [weakSelf processContains:attribute string:string not:YES];
		return weakSelf;
	};
}

-(MTDataQuery *(^)(MTDataQueryBlock block))and {
	__weak typeof(self) weakSelf = self;
	return ^MTDataQuery *(MTDataQueryBlock block) {
		[weakSelf processSubQueryBlock:block operator:NSAndPredicateType];
		return weakSelf;
	};
}

-(MTDataQuery *(^)(MTDataQueryBlock block))or {
	__weak typeof(self) weakSelf = self;
	return ^MTDataQuery *(MTDataQueryBlock block) {
		[weakSelf processSubQueryBlock:block operator:NSOrPredicateType];
		return weakSelf;
	};
}

-(MTDataQuery *(^)(MTDataQueryBlock block))not {
	__weak typeof(self) weakSelf = self;
	return ^MTDataQuery *(MTDataQueryBlock block) {
		[weakSelf processSubQueryBlock:block operator:NSNotPredicateType];
		return weakSelf;
	};
}
@end