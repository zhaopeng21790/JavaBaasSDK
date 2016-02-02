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
 Increments the given key by 1.
 @param key The key.
 */
- (void)incrementKey:(NSString *)key error:(NSError **)error;

- (void)incrementKeyInBackground:(NSString *)key block:(JBBooleanResultBlock)block;

/*!
 Increments the given key by a number.objectWithClassName
 @param key The key.
 @param amount The amount to increment.
 */
- (void)incrementKey:(NSString *)key byAmount:(NSNumber *)amount error:(NSError **)error;

- (void)incrementKeyInBackground:(NSString *)key byAmount:(NSNumber *)amount block:(JBBooleanResultBlock)block;

/*!
 Increments the given keys (NSDictionary).
 */
- (void)incrementKeys:(NSDictionary *)keys error:(NSError **)error;

- (void)incrementKeysInBackground:(NSDictionary *)keys block:(JBBooleanResultBlock)block;


#pragma mark -
#pragma mark Get and set
- (NSArray *)allKeys;
/*!
 Returns the object associated with a given key.
 @param key The key that the object is associated with.
 @return The value associated with the given key, or nil if no value is associated with key.
 */
- (id)objectForKey:(NSString *)key;

/*!
 Sets the object associated with a given key.
 @param object The object.
 @param key The key.
 */
- (void)setObject:(id)object forKey:(NSString *)key;

- (void)setValue:(id)value forKey:(NSString *)key;

/*!
 Unsets a key on the object.
 @param key The key.
 */
- (void)removeObjectForKey:(NSString *)key;

- (void)removeAllObjects;


/*!
 Generate JSON dictionary from JBObject or its subclass object.
 */
- (NSMutableDictionary *)dictionaryForObject;

+ (JBObject *)object;


@end
