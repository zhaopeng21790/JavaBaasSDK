//
//  HttpRequestManager.h
//  LeanCloud_Test
//
//  Created by zhaopeng on 15/9/23.
//  Copyright © 2015年 zhaopeng. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "AFNetworking.h"




@interface HttpRequestManager : NSObject

/**
 *  创建对象
 *
 *  @param clazzName  表名
 *  @param parameters 创建数据 NSDictionary
 */
+ (void)postObjectWithoutDataWithUrlPath:(NSString *)urlPath parameters:(NSDictionary *)parameters
                                   success:(void (^)(AFHTTPRequestOperation *operation, id responseObject))success
                                   failure:(void (^)(AFHTTPRequestOperation *operation, NSError *error))failure;

/**
 *  获取一个对象的数据
 *
 *  @param clazzName  表名
 *  @param objectId   数据对应id
 *  @param parameters 查询条件
 *  @param success    成功
 *  @param failure    失败
 */
+ (void)getObjectWithUrlPath:(NSString *)urlPath parameters:(NSMutableDictionary *)parameters
                       success:(void (^)(AFHTTPRequestOperation *operation, id responseObject))success
                       failure:(void (^)(AFHTTPRequestOperation *operation, NSError *error))failure;


/**
 *  更新对象
 *
 *  @param className 表名
 *  @param objectId  对象id
 *  @param dict      更新数据 NSDictionary
 */
+ (void)updateObjectWithUrlPath:(NSString *)urlPath parameters:(NSDictionary *)dict
                          success:(void (^)(AFHTTPRequestOperation *operation, id responseObject))success
                          failure:(void (^)(AFHTTPRequestOperation *operation, NSError *error))failure;

/**
 *  查询
 *
 *  @param clazzName 表名
 *  @param queryString      where条件
 */
+ (void)queryObjectWithUrlPath:(NSString *)urlPath queryParam:(NSMutableDictionary *)queryDict
                         success:(void (^)(AFHTTPRequestOperation *operation, id responseObject))success
                         failure:(void (^)(AFHTTPRequestOperation *operation, NSError *error))failure;


/**
 *  删除对象
 *
 *  @param clazzName 表名
 *  @param objectId  对象id
 */
+ (void)deleteObjectWithUrlPath:(NSString *)urlPath queryParam:(NSMutableDictionary *)queryDict
                          success:(void (^)(AFHTTPRequestOperation *operation, id responseObject))success
                          failure:(void (^)(AFHTTPRequestOperation *operation, NSError *error))failure;

/**
 *  发起post请求
 *
 *  @param urlString  url
 *  @param parameters <#parameters description#>
 *  @param success    <#success description#>
 *  @param failure    <#failure description#>
 */
+ (void)postObjectWithUrlString:(NSString *)urlString parameters:(NSDictionary *)parameters
                        success:(void (^)(AFHTTPRequestOperation *operation, id responseObject))success
                        failure:(void (^)(AFHTTPRequestOperation *operation, NSError *error))failure;


/**
 *  发起一个http请求
 *
 *  @param urlString url
 *  @param success   成功回调
 *  @param failure   失败回调
 */
+ (void)getObjectWithUrlString:(NSString *)urlString
                       success:(void (^)(AFHTTPRequestOperation *operation, id responseObject))success
                       failure:(void (^)(AFHTTPRequestOperation *operation, NSError *error))failure;




+ (void)cloudWithFunName:(NSString *)funName parameters:(NSDictionary *)parameters
                    success:(void (^)(AFHTTPRequestOperation *operation, id responseObject))success
                    failure:(void (^)(AFHTTPRequestOperation *operation, NSError *error))failure;


+ (id)cloudWithFunName:(NSString *)funName parameters:(NSDictionary *)parameters error:(NSError **)error;


+ (id)synchronousWithMethod:(NSString *)method urlString:(NSString *)urlString parameters:(NSDictionary *)parameters error:(NSError **)error ;



@end
