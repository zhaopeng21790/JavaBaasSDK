//
//  JBObject.h
//  
//
//  Created by zhaopeng on 15/9/28.
//  Copyright © 2015年 zhaopeng. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "JBACL.h"
#import "JBConstants.h"

@interface JBObject : NSObject

@property (nonatomic, strong) NSString *objectId;
@property (nonatomic, strong) NSDate *createdAt;
@property (nonatomic, strong) NSDate *updatedAt;
@property (nonatomic, strong) NSString *className;
@property (nonatomic, strong) JBACL *acl;



- (instancetype)initWithDictionary:(NSDictionary *)dictionay;


+ (instancetype)objectWithoutDataWithClassName:(NSString *)className
                                      objectId:(NSString *)objectId;

+ (instancetype)objectWithoutDataWithObjectId:(NSString *)objectId;


+ (instancetype)objectWithClassName:(NSString *)className;


#pragma mark -
#pragma mark Save,fetch,delete

- (BOOL)save:(NSError **)error;


/**
 *  保存数据到服务器
 *
 *  @param block 服务器返回结果
 */
- (void)saveInBackgroundWithBlock:(JBBooleanResultBlock)block;


- (JBObject *)fetch:(NSError **)error;

- (void)fetchInBackgroundWithBlock:(JBObjectResultBlock)block;

- (BOOL)delete:(NSError **)error;

- (void)deleteInBackgroundWithBlock:(JBBooleanResultBlock)block;

#pragma mark -
#pragma mark Increment

/*!
 对这段key做原子增 1.
 */
- (BOOL)incrementKey:(NSString *)key error:(NSError **)error;

- (void)incrementKeyInBackground:(NSString *)key block:(JBBooleanResultBlock)block;

/**
 *   对这段key做圆子增 amout.
 *
 *  @param key    字段名
 *  @param amount 原子增数
 *  @param error  错误
 *
 */
- (BOOL)incrementKey:(NSString *)key byAmount:(NSNumber *)amount error:(NSError **)error;

- (void)incrementKeyInBackground:(NSString *)key byAmount:(NSNumber *)amount block:(JBBooleanResultBlock)block;

//对一系列key做原子增 @{key : @(2)....}
- (BOOL)incrementKeys:(NSDictionary *)keys error:(NSError **)error;

- (void)incrementKeysInBackground:(NSDictionary *)keys block:(JBBooleanResultBlock)block;


#pragma mark -
#pragma mark Get and set
- (NSArray *)allKeys;

- (id)objectForKey:(NSString *)key;

- (void)setObject:(id)object forKey:(NSString *)key;

- (void)setValue:(id)value forKey:(NSString *)key;

- (void)removeObjectForKey:(NSString *)key;

- (void)removeAllObjects;
//获取josn数据
- (NSMutableDictionary *)dictionaryForObject;

+ (JBObject *)object;


@end
