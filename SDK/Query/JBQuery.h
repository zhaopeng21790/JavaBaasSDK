//
//  JBQuery.h
//  LeanCloud_Test
//
//  Created by zhaopeng on 15/9/23.
//  Copyright © 2015年 zhaopeng. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "JBObject.h"


@interface JBQuery : NSObject


@property (nonatomic, strong) NSMutableDictionary *dictionary;
@property (nonatomic, strong) NSMutableString *orMutableString;
@property (nonatomic, strong) NSMutableString *inQueryMutableString;
@property (nonatomic, strong) NSMutableDictionary *paramDictionary;
@property (nonatomic, assign) kJBCachePolicyCache cachePolicy;
@property (nonatomic, assign) NSInteger limit;
@property (nonatomic, assign) NSInteger skip;
@property (nonatomic, strong) NSString *className;



+ (JBQuery *)queryWithClassName:(NSString *)className;


- (NSMutableDictionary *)getQueryConditions;


- (id)findObjects:(NSError **)error;

/**
 *  子线程查询数据(结果以数组的形式返回)
 *
 *  @param block 查询结果回调
 */
- (void)findObjectsInBackgroundWithBlock:(JBArrayResultBlock)block;

- (void)deleteAllInBackgroundWithBlock:(JBBooleanResultBlock)block;

/**
 *  子线程查询一条数据
 *
 *  @param objectId 对象id
 *  @param block    查询结果回调
 */
- (void)getObjectInBackgroundWithId:(NSString *)objectId block:(JBObjectResultBlock)block;

+ (JBObject *)getObjectOfClass:(NSString *)objectClass objectId:(NSString *)objectId error:(NSError **)error;

+ (JBUser *)getUserObjectWithId:(NSString *)objectId error:(NSError **)error;



/**
 *  查询符合条件数据的count
 *
 *  @param block 查询结果回调
 */
- (void)countObjectsInBackgroundWithBlock:(JBIntegerResultBlock)block;

- (NSInteger)countObjects:(NSError **)error;



//查询条件
- (void)whereKey:(NSString *)key equalTo:(id)value;

- (void)whereKey:(NSString *)key notEqualTo:(id)value;

- (void)whereKeyExists:(NSString *)key;

- (void)whereKeyDoesNotExist:(NSString *)key;

- (void)whereKey:(NSString *)key lessThan:(id)value;

- (void)whereKey:(NSString *)key lessThanOrEqualTo:(id)value;

- (void)whereKey:(NSString *)key greaterThan:(id)value;

- (void)whereKey:(NSString *)key greaterThanOrEqualTo:(id)value;

- (void)whereKey:(NSString *)key containedIn:(NSArray *)array;

- (void)whereKey:(NSString *)key notContainedIn:(NSArray *)array;

- (void)whereKey:(NSString *)key containsString:(NSString *)value;

- (void)orderByDescending:(NSString *)key;

- (void)orderByAscending:(NSString *)key;

- (void)addDescendingOrder:(NSString *)key;

- (void)addAscendingOrder:(NSString *)key;

- (void)includeKey:(NSString *)key;

- (void)whereKey:(NSString *)key matchesQuery:(JBQuery *)query;

- (void)whereKey:(NSString *)key matchesKey:(NSString *)matchesKey matchesClass:(NSString *)matchesClass inQuery:(JBQuery *)query;

+ (JBQuery *)orQueryWithSubqueries:(NSArray *)array;


@end











