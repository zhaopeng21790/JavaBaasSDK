//
//  HttpRequestManager.m
//  LeanCloud_Test
//
//  Created by zhaopeng on 15/9/23.
//  Copyright © 2015年 zhaopeng. All rights reserved.
//

#import "HttpRequestManager.h"
#import "JBCacheManager.h" 
#import "JBOSCloud.h"
#import "NSString+MD5Digest.h"
#import "JBUser.h"

@implementation HttpRequestManager

//post方法 创建一个对象
+ (void)postObjectWithoutDataWithUrlPath:(NSString *)urlPath parameters:(NSDictionary *)parameters
                                   success:(void (^)(AFHTTPRequestOperation *operation, id responseObject))success
                                   failure:(void (^)(AFHTTPRequestOperation *operation, NSError *error))failure {
    NSString *baseUrl = [JBOSCloud getBaseUrlString];
    //    unix时间戳  精确到毫秒
    NSString *urlString = [NSString stringWithFormat:@"%@%@", baseUrl, urlPath];
    NSString *string = [urlString stringByAddingPercentEncodingWithAllowedCharacters:[NSCharacterSet URLQueryAllowedCharacterSet]];
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    [self setHttpHearderWithHttpRequestOperationManager:manager];
    //发送请求
    [manager POST:string parameters:parameters success:^(AFHTTPRequestOperation *operation, id responseObject) {
        success(operation, responseObject);
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        [self checkSessionToken:operation];
        failure(operation, error);
    }];
}


+ (void)getObjectWithUrlPath:(NSString *)urlPath parameters:(NSMutableDictionary *)parameters
                       success:(void (^)(AFHTTPRequestOperation *operation, id responseObject))success
                       failure:(void (^)(AFHTTPRequestOperation *operation, NSError *error))failure {
    
    kJBCachePolicyCache cachePolicy = [[parameters objectForKey:@"cachePolicy"] intValue];
    [parameters removeObjectForKey:@"cachePolicy"];
    
    NSMutableString *paramString = [NSMutableString string];
    NSArray *keyArray = [parameters allKeys];
    for (int i=0; i<keyArray.count; i++) {
        NSString *keyString = [keyArray objectAtIndex:i];
        NSString *valueString = [parameters objectForKey:keyString];
        [paramString appendString:[NSString stringWithFormat:@"%@=%@",keyString,valueString]];
        if (i != keyArray.count-1) {
            [paramString appendString:@"&"];
        }
    }
    
    NSString *baseUrl = [JBOSCloud getBaseUrlString];
    
    NSString *urlString;
    
    if (paramString.length) {
        urlString = [NSString stringWithFormat:@"%@%@?%@", baseUrl, urlPath, paramString];
    }else {
        urlString = [NSString stringWithFormat:@"%@%@", baseUrl, urlPath];
    }
    
    NSString *string = [urlString stringByAddingPercentEncodingWithAllowedCharacters:[NSCharacterSet URLQueryAllowedCharacterSet]];
    
    
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    
    [self setHttpHearderWithHttpRequestOperationManager:manager];
    
    
    if (cachePolicy == kJBCachePolicyIgnoreCache) {
        [manager GET:string parameters:nil success:^(AFHTTPRequestOperation *operation, id responseObject) {
            success(operation, responseObject);
        } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
            [self checkSessionToken:operation];
            failure(operation, error);
        }];
    }else if (cachePolicy == kJBCachePolicyCacheOnly) {
        [[JBCacheManager sharedJBCacheManager] readCacheFileAtPath:urlString block:^(NSArray *objects, NSError *error) {
            success(nil, objects);
        }];
    }else if (cachePolicy == kJBCachePolicyCacheThenNetwork) {
        [[JBCacheManager sharedJBCacheManager] readCacheFileAtPath:urlString block:^(NSArray *objects, NSError *error) {
            success(nil, objects);
            [manager GET:string parameters:nil success:^(AFHTTPRequestOperation *operation, id responseObject) {
                [[JBCacheManager sharedJBCacheManager] createDirectoryAtPath:urlString andData:responseObject];
                success(operation, responseObject);
            } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
                [self checkSessionToken:operation];
                failure(operation, error);
            }];
        }];
    }else {
        [manager GET:string parameters:nil success:^(AFHTTPRequestOperation *operation, id responseObject) {
            [[JBCacheManager sharedJBCacheManager] createDirectoryAtPath:urlString andData:responseObject];
            success(operation, responseObject);
        } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
            [self checkSessionToken:operation];
            failure(operation, error);
        }];
    }
}

//put方法 更新对象
+ (void)updateObjectWithUrlPath:(NSString *)urlPath parameters:(NSDictionary *)dict
                          success:(void (^)(AFHTTPRequestOperation *operation, id responseObject))success
                          failure:(void (^)(AFHTTPRequestOperation *operation, NSError *error))failure {
    
    NSString *baseUrl = [JBOSCloud getBaseUrlString];
    NSString *urlString = [NSString stringWithFormat:@"%@%@", baseUrl, urlPath];
    NSString *string = [urlString stringByAddingPercentEncodingWithAllowedCharacters:[NSCharacterSet URLQueryAllowedCharacterSet]];
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    [self setHttpHearderWithHttpRequestOperationManager:manager];
    [manager PUT:string parameters:dict success:^(AFHTTPRequestOperation *operation, id responseObject) {
        success(operation, responseObject);
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        [self checkSessionToken:operation];
        failure(operation, error);
    }];
}




//get方法 获取类对象
+ (void)queryObjectWithUrlPath:(NSString *)urlPath queryParam:(NSMutableDictionary *)queryDict
                         success:(void (^)(AFHTTPRequestOperation *operation, id responseObject))success
                         failure:(void (^)(AFHTTPRequestOperation *operation, NSError *error))failure{
    
    kJBCachePolicyCache cachePolicy = [[queryDict objectForKey:@"cachePolicy"] intValue];
    [queryDict removeObjectForKey:@"cachePolicy"];
    
    NSMutableString *paramString = [NSMutableString string];
    NSArray *keyArray = [queryDict allKeys];
    for (int i=0; i<keyArray.count; i++) {
        NSString *keyString = [keyArray objectAtIndex:i];
        NSString *valueString = [queryDict objectForKey:keyString];
        [paramString appendString:[NSString stringWithFormat:@"%@=%@",keyString,valueString]];
        if (i != keyArray.count-1) {
            [paramString appendString:@"&"];
        }
    }

    NSString *baseUrl = [JBOSCloud getBaseUrlString];
    NSString *urlString;
    
    if (paramString.length) {
        urlString = [NSString stringWithFormat:@"%@%@?%@", baseUrl, urlPath, paramString];
    }else {
        urlString = [NSString stringWithFormat:@"%@%@", baseUrl, urlPath];
    }
    NSString *string = [urlString stringByAddingPercentEncodingWithAllowedCharacters:[NSCharacterSet URLQueryAllowedCharacterSet]];
    
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    
    [self setHttpHearderWithHttpRequestOperationManager:manager];
    
    if (cachePolicy == kJBCachePolicyIgnoreCache) {
        [manager GET:string parameters:nil success:^(AFHTTPRequestOperation *operation, id responseObject) {
            success(operation, responseObject);
        } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
            [self checkSessionToken:operation];
            failure(operation, error);
        }];
    }else if (cachePolicy == kJBCachePolicyCacheOnly) {
        [[JBCacheManager sharedJBCacheManager] readCacheFileAtPath:urlString block:^(NSArray *objects, NSError *error) {
            if (objects.count) {
                success(nil, objects);
            }else {
                success(nil, nil);
            }
        }];
    }else if (cachePolicy == kJBCachePolicyCacheThenNetwork) {
        [[JBCacheManager sharedJBCacheManager] readCacheFileAtPath:urlString block:^(NSArray *objects, NSError *error) {
            success(nil, objects);
            [manager GET:string parameters:nil success:^(AFHTTPRequestOperation *operation, id responseObject) {
                [[JBCacheManager sharedJBCacheManager] createDirectoryAtPath:urlString andData:responseObject];
                success(operation, responseObject);
            } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
                [self checkSessionToken:operation];
                failure(operation, error);
            }];
        }];
    }else {
        [manager GET:string parameters:nil success:^(AFHTTPRequestOperation *operation, id responseObject) {
            [[JBCacheManager sharedJBCacheManager] createDirectoryAtPath:urlString andData:responseObject];
            success(operation, responseObject);
        } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
            [self checkSessionToken:operation];
            failure(operation, error);
        }];
    }
}


+ (void)deleteObjectWithUrlPath:(NSString *)urlPath queryParam:(NSMutableDictionary *)queryDict
                          success:(void (^)(AFHTTPRequestOperation *operation, id responseObject))success
                          failure:(void (^)(AFHTTPRequestOperation *operation, NSError *error))failure{
    NSMutableString *paramString = [NSMutableString string];
    NSArray *keyArray = [queryDict allKeys];
    for (int i=0; i<keyArray.count; i++) {
        NSString *keyString = [keyArray objectAtIndex:i];
        NSString *valueString = [queryDict objectForKey:keyString];
        [paramString appendString:[NSString stringWithFormat:@"%@=%@",keyString,valueString]];
        if (i != keyArray.count-1) {
            [paramString appendString:@"&"];
        }
    }
    
    NSString *baseUrl = [JBOSCloud getBaseUrlString];
    NSString *urlString;
    
    if (paramString.length) {
        urlString = [NSString stringWithFormat:@"%@%@?%@", baseUrl, urlPath, paramString];
    }else {
        urlString = [NSString stringWithFormat:@"%@%@", baseUrl, urlPath];
    }
    
    NSString *string = [urlString stringByAddingPercentEncodingWithAllowedCharacters:[NSCharacterSet URLQueryAllowedCharacterSet]];
    
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    
    [self setHttpHearderWithHttpRequestOperationManager:manager];
    
    [manager DELETE:string parameters:nil success:^(AFHTTPRequestOperation *operation, id responseObject) {
        success(operation, responseObject);
        
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        [self checkSessionToken:operation];
        failure(operation, error);
    }];
}


//post方法 创建一个对象

+ (void)postObjectWithUrlString:(NSString *)urlString parameters:(NSDictionary *)parameters
                       success:(void (^)(AFHTTPRequestOperation *operation, id responseObject))success
                       failure:(void (^)(AFHTTPRequestOperation *operation, NSError *error))failure {
    
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    
    [self setHttpHearderWithHttpRequestOperationManager:manager];
    NSString *string = [urlString stringByAddingPercentEncodingWithAllowedCharacters:[NSCharacterSet URLQueryAllowedCharacterSet]];
    //发送请求
    [manager POST:string parameters:parameters success:^(AFHTTPRequestOperation *operation, id responseObject) {
        success(operation, responseObject);
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        failure(operation, error);
    }];
}



+ (void)getObjectWithUrlString:(NSString *)urlString
                       success:(void (^)(AFHTTPRequestOperation *operation, id responseObject))success
                       failure:(void (^)(AFHTTPRequestOperation *operation, NSError *error))failure {
    //    unix时间戳  精确到毫秒
    
    NSString *string = [urlString stringByAddingPercentEncodingWithAllowedCharacters:[NSCharacterSet URLQueryAllowedCharacterSet]];
    
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    
    [self setHttpHearderWithHttpRequestOperationManager:manager];
    
    //发送请求
    [manager GET:string parameters:nil success:^(AFHTTPRequestOperation *operation, id responseObject) {
        success(operation, responseObject);
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        [self checkSessionToken:operation];
        failure(operation, error);
    }];
}


+ (void)cloudWithFunName:(NSString *)funName parameters:(NSDictionary *)parameters success:(void (^)(AFHTTPRequestOperation *operation, id))success failure:(void (^)(AFHTTPRequestOperation *, NSError *error))failure {
    
    NSMutableString *paramString = [NSMutableString string];
    NSArray *keyArray = [parameters allKeys];
    for (int i=0; i<keyArray.count; i++) {
        NSString *keyString = [keyArray objectAtIndex:i];
        NSString *valueString = [parameters objectForKey:keyString];
        [paramString appendString:[NSString stringWithFormat:@"%@=%@",keyString,valueString]];
        if (i != keyArray.count-1) {
            [paramString appendString:@"&"];
        }
    }
    NSString *baseUrl = [JBOSCloud getBaseUrlString];
    NSString *urlString = [NSString stringWithFormat:@"%@cloud/%@?%@",baseUrl,funName,paramString];
    NSString *string = [urlString stringByAddingPercentEncodingWithAllowedCharacters:[NSCharacterSet URLQueryAllowedCharacterSet]];
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    [self setHttpHearderWithHttpRequestOperationManager:manager];
    
    //发送请求
    [manager GET:string parameters:nil success:^(AFHTTPRequestOperation *operation, id responseObject) {
        success(operation, responseObject);
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        [self checkSessionToken:operation];
        failure(operation, error);
    }];
}


+ (id)cloudWithFunName:(NSString *)funName parameters:(NSDictionary *)parameters error:(NSError *__autoreleasing *)error {
    NSMutableString *paramString = [NSMutableString string];
    NSArray *keyArray = [parameters allKeys];
    for (int i=0; i<keyArray.count; i++) {
        NSString *keyString = [keyArray objectAtIndex:i];
        NSString *valueString = [parameters objectForKey:keyString];
        [paramString appendString:[NSString stringWithFormat:@"%@=%@",keyString,valueString]];
        if (i != keyArray.count-1) {
            [paramString appendString:@"&"];
        }
    }
    NSString *baseUrl = [JBOSCloud getBaseUrlString];
    NSString *urlString = [NSString stringWithFormat:@"%@cloud/%@?%@",baseUrl,funName,paramString];
    NSString *string = [urlString stringByAddingPercentEncodingWithAllowedCharacters:[NSCharacterSet URLQueryAllowedCharacterSet]];
    return [self synchronousWithMethod:@"GET" urlString:string parameters:nil error:error];
}



//同步方法
+ (id)synchronousWithMethod:(NSString *)method urlString:(NSString *)urlString parameters:(NSDictionary *)parameters error:(NSError **)error {
    AFJSONRequestSerializer *requestSerializer = [AFJSONRequestSerializer serializer];
    NSString *baseUrl = [JBOSCloud getBaseUrlString];
    NSString *url = [NSString stringWithFormat:@"%@%@", baseUrl, urlString];
    NSString *string = [url stringByAddingPercentEncodingWithAllowedCharacters:[NSCharacterSet URLQueryAllowedCharacterSet]];
    NSMutableURLRequest *request = [requestSerializer requestWithMethod:method URLString:string parameters:parameters error:error];
    AFHTTPRequestOperation *operation = [[AFHTTPRequestOperation alloc] initWithRequest:request];
    AFHTTPResponseSerializer *responseSerializer = [AFJSONResponseSerializer serializer];
    //使用https
    AFSecurityPolicy *security = [AFSecurityPolicy policyWithPinningMode:AFSSLPinningModeNone];
    //不检验证书
    security.allowInvalidCertificates = YES;
    //不信任主机
    security.validatesDomainName = NO;
    operation.securityPolicy = security;
    NSString *appId = [JBOSCloud getApplicationId];
    NSString *clientKey = [JBOSCloud getClientKey];
    NSString *tempTime = [self getUnixDate];
    NSString *source = [NSString stringWithFormat:@"%@:%@",clientKey, tempTime];
    NSString *md5String = [source MD5HexDigest];
    [request setValue:tempTime forHTTPHeaderField:@"JB-Timestamp"];
    [request setValue:appId forHTTPHeaderField:@"JB-AppId"];
    [request setValue:md5String forHTTPHeaderField:@"JB-Sign"];
    [request setValue:@"ios" forHTTPHeaderField:@"JB-Plat"];
    [request setValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
    JBUser *currentUser = [JBUser currentUser];
    if (currentUser.sessionToken && ![currentUser.sessionToken isEqualToString:@""]) {
        [request setValue:currentUser.sessionToken forHTTPHeaderField:@"JB-SessionToken"];
    }
    [operation setResponseSerializer:responseSerializer];
    [operation start];
    [operation waitUntilFinished];
    
    if (operation.response.statusCode == 400 || operation.response.statusCode == 200) {
        return operation.responseObject;
    }else {
        if (error) {
            *error = [NSError errorWithDomain:@"网络链接失败" code:JBError_URL_ERROR userInfo:@{NSLocalizedDescriptionKey:@"网络链接失败"}];
        }
        return nil;
    }
}


+ (void)setHttpHearderWithHttpRequestOperationManager:(AFHTTPRequestOperationManager *)manager {
    //使用https
    AFSecurityPolicy *security = [AFSecurityPolicy policyWithPinningMode:AFSSLPinningModeNone];
    //不检验证书
    security.allowInvalidCertificates = YES;
    //不信任主机
    security.validatesDomainName = NO;
    manager.securityPolicy = security;
    
    //申明返回的结果是json类型
    manager.responseSerializer = [AFJSONResponseSerializer serializer];
    //申明请求的数据是json类型
    manager.requestSerializer = [AFJSONRequestSerializer serializer];
    
    NSString *appId = [JBOSCloud getApplicationId];
    NSString *clientKey = [JBOSCloud getClientKey];
    NSString *tempTime = [self getUnixDate];
    NSString *source = [NSString stringWithFormat:@"%@:%@",clientKey, tempTime];
    NSString *md5String = [source MD5HexDigest];
    [ manager.requestSerializer setValue:tempTime forHTTPHeaderField:@"JB-Timestamp"];
    [ manager.requestSerializer setValue:appId forHTTPHeaderField:@"JB-AppId"];
    [ manager.requestSerializer setValue:md5String forHTTPHeaderField:@"JB-Sign"];
    [ manager.requestSerializer setValue:@"ios" forHTTPHeaderField:@"JB-Plat"];
    [ manager.requestSerializer setValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
    JBUser *currentUser = [JBUser currentUser];
    if (currentUser.sessionToken && ![currentUser.sessionToken isEqualToString:@""]) {
        [manager.requestSerializer setValue:currentUser.sessionToken forHTTPHeaderField:@"JB-SessionToken"];
    }
}

+ (void)checkSessionToken:(AFHTTPRequestOperation *)operation {
    if (operation.responseObject) {
        int code = [[operation.responseObject objectForKey:@"code"] intValue];
        if (code == 1310) {
            [JBUser logout];
        }
    }
}
+ (AFSecurityPolicy*)customSecurityPolicy {
    AFSecurityPolicy *securityPolicy = [AFSecurityPolicy defaultPolicy];
    [securityPolicy setAllowInvalidCertificates:YES];
    return securityPolicy;
}

+ (NSString *)getUnixDate {
    NSTimeInterval time=[[NSDate date] timeIntervalSince1970];
    time *= 1000;
    long long dValue = [[[NSUserDefaults standardUserDefaults] objectForKey:@"serverTime"] longLongValue];
    long long int currentTime=(long long int)time+dValue;      //NSTimeInterval返回的是double类型
    NSString *tempTime = [NSString stringWithFormat:@"%lld",currentTime];
    return tempTime;
}


@end



























