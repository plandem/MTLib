//
// Created by Andrey on 03/06/15.
// Copyright (c) 2015 Melatonin LLC. All rights reserved.
//
// TODO: add expressions for functions and keyPath. Some hints and ideas:
// http://realm.io/news/nspredicate-cheatsheet/
// http://nshipster.com/nsexpression/
// http://gist.githubusercontent.com/iluvcapra/5118789/raw/c92f0a6c12545791ead0a4fcc0b0094571a37c2d/NSPredicate2SQL.mm
// http://github.com/GusevAndrey/NSIncrementalStoreInUse/blob/master/NSIncrementalStoreInUse/Utilities/FMDB/FMDatabase%2BNSPredicate.m
// http://cocotron.googlecode.com/svn/branches/iTextView/Foundation/NSPredicate/

#import "MTSQLitePredicateTransformer.h"

@implementation MTSQLitePredicateTransformer
static NSString *SQLNullValue = @"NULL";

+ (Class)transformedValueClass {
	return [NSString class];
}

+ (BOOL)allowsReverseTransformation {
	return NO;
}

- (id)transformedValue:(id)value {
	if(value == nil) {
		return nil;
	}

	NSAssert([value isKindOfClass:[NSPredicate class]], @"Value %@ is not subclass of NSPredicate.", NSStringFromClass([value class]));
	return [self predicateToString:value];
}

-(NSString *)predicateToString:(NSPredicate *)predicate {
	if([predicate isKindOfClass:[NSCompoundPredicate class]]) {
		return [self compoundToString:(NSCompoundPredicate *)predicate];
	} else if([predicate isKindOfClass:[NSComparisonPredicate class]]) {
		return [self comparisonToString:(NSComparisonPredicate *) predicate];
	}

	NSAssert(false, @"Unsupported type of predicate: %@", [predicate class]);
	return nil;
}

-(NSString *)compoundToString:(NSCompoundPredicate *)compoundPredicate {
	NSMutableString *result = [NSMutableString string];
	NSMutableArray  *args = [NSMutableArray array];

	NSCompoundPredicateType type = [compoundPredicate compoundPredicateType];

	for(NSPredicate *subPredicate in compoundPredicate.subpredicates) {
		NSString *precedence = [self predicateToString:subPredicate];
		if([subPredicate isKindOfClass:[NSCompoundPredicate class]]) {
			if([(NSCompoundPredicate *)subPredicate compoundPredicateType] != type) {
				precedence = [NSString stringWithFormat:@"(%@)", precedence];
			}
		}

		[args addObject:precedence];
	}

	switch(type){
		case NSNotPredicateType:
			[result appendFormat:@"NOT %@", args[0]];
			break;

		case NSAndPredicateType:
			[result appendFormat:@"%@ AND %@", args[0], args[1]];
			break;

		case NSOrPredicateType:
			[result appendFormat:@"%@ OR %@", args[0], args[1]];
			break;
	}

	return result;
}

-(NSString *)comparisonToString:(NSComparisonPredicate *)comparisonPredicate {
	NSAssert([comparisonPredicate leftExpression] && [comparisonPredicate rightExpression], @"Predicate %@ not fully initialized. Both (left and right) expression must be set.", comparisonPredicate);
	NSAssert([comparisonPredicate comparisonPredicateModifier] == NSDirectPredicateModifier, @"Can't convert predicate %@ with non NSDirectPredicateModifier modifier. ", comparisonPredicate);

	NSString *operator = nil;
	NSExpression *lhs = [comparisonPredicate leftExpression];
	NSExpression *rhs = [comparisonPredicate rightExpression];
	NSRange range;
	NSString *value;

	switch(comparisonPredicate.predicateOperatorType) {
		case NSLessThanPredicateOperatorType:
			operator = @"<";
			break;
		case NSLessThanOrEqualToPredicateOperatorType:
			operator = @"<=";
			break;
		case NSGreaterThanPredicateOperatorType:
			operator = @">";
			break;
		case NSGreaterThanOrEqualToPredicateOperatorType:
			operator = @">=";
			break;
		case NSEqualToPredicateOperatorType:
			value = [self expressionToString:rhs];
			if(value == nil) {
				//will transform into: IS NULL
				value = SQLNullValue;
				operator = @"IS";
			} else {
				operator = @"=";
			}
			break;
		case NSNotEqualToPredicateOperatorType:
			value = [self expressionToString:rhs];
			if(value == nil) {
				//will transform into: IS NOT NULL
				value = SQLNullValue;
				operator = @"IS NOT";
			} else {
				operator = @"<>";
			}
			break;
		case NSMatchesPredicateOperatorType:
			operator = @"MATCH";
			break;
		case NSLikePredicateOperatorType:
			operator = @"LIKE";
			break;
		case NSBeginsWithPredicateOperatorType:
			//transform value into the "text%"
			value = [self expressionToString:rhs];
			range = [value rangeOfString:@"\"" options:NSBackwardsSearch];
			value = [value stringByReplacingCharactersInRange:range withString:@"%\""];
			operator = @"LIKE";
			break;
		case NSEndsWithPredicateOperatorType:
			//transform value into the "%text"
			value = [self expressionToString:rhs];
			range = [value rangeOfString:@"\"" options:0];
			value = [value stringByReplacingCharactersInRange:range withString:@"\"%"];
			operator = @"LIKE";
			break;
		case NSContainsPredicateOperatorType:
			//transform value into the "%text%"
			value = [self expressionToString:rhs];
			range = [value rangeOfString:@"\"" options:0];
			value = [value stringByReplacingCharactersInRange:range withString:@"\"%"];
			range = [value rangeOfString:@"\"" options:NSBackwardsSearch];
			value = [value stringByReplacingCharactersInRange:range withString:@"%\""];
			operator = @"LIKE";
			break;
		case NSInPredicateOperatorType:
			operator = @"IN";
			break;
		case NSCustomSelectorPredicateOperatorType:
			NSAssert(false, @"Predicate %@ could not be converted to SQL because it uses a custom selector.", comparisonPredicate);
			break;
		case NSBetweenPredicateOperatorType:
			return [NSString stringWithFormat:@"%@ BETWEEN %@ AND %@", [self expressionToString:[comparisonPredicate leftExpression]], [rhs constantValue][0], [rhs constantValue][1]];
	}

	NSAssert(operator, @"Can't convert operator for predicate %@", comparisonPredicate);
	return [NSString stringWithFormat:@"%@ %@ %@", [self expressionToString:lhs], operator, (value ? value : [self expressionToString:rhs])];
}

-(NSString *)expressionToString:(NSExpression *)expression {
	switch ([expression expressionType]) {
		case NSConstantValueExpressionType:
			return [self constantToString:expression];
		case NSVariableExpressionType:
			return [self variableToString:expression];
		case NSKeyPathExpressionType:
			return [self keyPathToString:expression];
		case NSFunctionExpressionType:
			return [self functionToString:expression];
		case NSEvaluatedObjectExpressionType:
		case NSUnionSetExpressionType:
		case NSIntersectSetExpressionType:
		case NSMinusSetExpressionType:
		case NSSubqueryExpressionType:
		case NSAggregateExpressionType:
		case NSAnyKeyExpressionType:
		case NSBlockExpressionType:
			break;
	}

	NSAssert(false, @"There is no conversion for such type of expression: %@", expression);
	return nil;
}

- (NSString *)constantToString:(NSExpression *)expression {
	id value = expression.constantValue;

	if(value == nil || [value isEqual:[NSNull null]]) {
		return nil;
	} else if([value isKindOfClass:[NSArray class]]) {
		return [value description];
	} else {
		return [expression description];
	}
}

- (NSString *)variableToString:(NSExpression *)expression {
	return [expression variable];
}

- (NSString *)functionToString:(NSExpression *)expression {
	NSAssert(false, @"Not implemented.");
	return nil;
}

-(NSString *)keyPathToString:(NSExpression *)expression {
	return [expression keyPath];
}
@end