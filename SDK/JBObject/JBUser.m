//
//  JBUser.m
//  LeanCloud_Test
//
//  Created by zhaopeng on 15/9/29.
//  Copyright © 2015年 zhaopeng. All rights reserved.
//

#import "JBUser.h"
#import "JBInterface.h"
#import "HttpRequestManager.h"
#import "JBCacheManager.h"

#import "JBOSCloud.h"

@implementation JBUser

+ (instancetype)objectWithoutDataWithObjectId:(NSString *)objectId {
    JBUser *object = [[JBUser alloc] init];
    object.objectId = objectId;
    [object setValue:@"Pointer" forKey:@"__type"];
    [object setValue:objectId forKey:@"_id"];
    object.className = @"_User";
    return object;
}


- (void)setSessionToken:(NSString *)sessionToken {
    _sessionToken = sessionToken;
    if (sessionToken) {
        [self setObject:sessionToken forKey:@"sessionToken"];
    }
}


- (void)setUsername:(NSString *)username {
    _username = username;
    if (username) {
        [self setObject:username forKey:@"username"];
    }
}

- (void)setPassword:(NSString *)password {
    _password = password;
    if (password) {
        [self setObject:password forKey:@"password"];
    }
}

- (void)setPhone:(NSString *)phone {
    _phone = phone;
    if (phone) {
        [self setObject:phone forKey:@"phone"];
    }
}


- (void)setEmail:(NSString *)email {
    _email = email;
    if (email) {
        [self setObject:email forKey:@"email"];
    }
}

- (void)setAuth:(JBObject *)auth {
    _auth = auth;
    if (auth) {
        [self setObject:[auth dictionaryForObject] forKey:@"auth"];
    }
}

+ (JBUser *)user {
    JBUser *user = [[JBUser alloc] init];
    user.className = @"_User";
    return user;
}

//注册
- (id)signUp:(NSError *__autoreleasing *)error {
    NSString *urlString = [JBInterface getInterfaceWithPragma:@{@"className":@"_User"}];
    NSDictionary *parameters = [self dictionaryForObject];
    id responseObject = [HttpRequestManager synchronousWithMethod:@"POST" urlString:urlString parameters:parameters error:error];
    if (error) {
        if (*error) {
            return nil;
        }
    }
    if (responseObject) {
        int code = [[responseObject objectForKey:@"code"] intValue];
        NSString *message = [responseObject objectForKey:@"message"];
        if (code > 0 && message) {
            if (error) {
                *error = [NSError errorWithDomain:message code:code userInfo:@{NSLocalizedDescriptionKey:message}];
            }
            return nil;
        }
        return [[JBObject alloc] initWithDictionary:responseObject];
    }else {
        return nil;
    }
    
}

- (void)signUpInBackGroundWithBlock:(JBIdResultBlock)block {
    NSString *urlPath = [JBInterface getInterfaceWithPragma:@{@"className":@"_User"}];
    NSDictionary *parameters = [self dictionaryForObject];
    [HttpRequestManager postObjectWithoutDataWithUrlPath:urlPath parameters:parameters success:^(AFHTTPRequestOperation *operation, id responseObject) {
        block(responseObject, nil);
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        if (operation.responseObject) {
            int code = [[operation.responseObject objectForKey:@"code"] intValue];
            if (code == 2010) {
                code = JBError_NICKNAME_ALREADY_EXIST;
            }
            NSError *customError = [NSError errorWithDomain:[operation.responseObject objectForKey:@"message"] code:code userInfo:operation.responseObject];
            block(operation.responseObject, customError);
        }else {
            block(nil, error);
        }
    }];
}

#warning 修改密码后需要fetch来获取sessionToken
//修改密码
- (BOOL)updatePasswork:(NSString *)password newPassword:(NSString *)newPassword error:(NSError *__autoreleasing *)error {
    if (!self.objectId) {
        *error = [NSError errorWithDomain:@"without user id" code:JBError_NO_USER userInfo:@{NSLocalizedDescriptionKey:@"without user id"}];
        return NO;
    }
    NSString *urlString = [NSString stringWithFormat:@"user/%@/updatePassword", self.objectId];
    NSMutableDictionary *parameters = [NSMutableDictionary dictionary];
    [parameters setObject:newPassword forKey:@"newPassword"];
    [parameters setObject:password forKey:@"oldPassword"];
    id responseObject = [HttpRequestManager synchronousWithMethod:@"PUT" urlString:urlString parameters:parameters error:error];
    if (error) {
        if (*error) {
            return NO;
        }
    }
    if (responseObject) {
        int code = [[responseObject objectForKey:@"code"] intValue];
        NSString *message = [responseObject objectForKey:@"message"];
        if (code > 0 && message) {
            if (error) {
                *error = [NSError errorWithDomain:message code:code userInfo:@{NSLocalizedDescriptionKey:message}];
            }
            return NO;
        }
        return YES;
    }else {
        return YES;
    }
    
}

- (void)updatePassword:(NSString *)password newPassword:(NSString *)newPassword block:(JBIdResultBlock)block {
    if (!self.objectId) {
        NSError *error = [NSError errorWithDomain:@"without user id" code:JBError_NO_USER userInfo:@{NSLocalizedDescriptionKey:@"without user id"}];
        block(nil, error);
        return ;
    }
    NSString *urlString = [NSString stringWithFormat:@"user/%@/updatePassword", self.objectId];
    NSMutableDictionary *parameters = [NSMutableDictionary dictionary];
    [parameters setObject:newPassword forKey:@"newPassword"];
    [parameters setObject:password forKey:@"oldPassword"];
    
    [HttpRequestManager updateObjectWithUrlPath:urlString parameters:parameters success:^(AFHTTPRequestOperation *operation, id responseObject) {
        block(responseObject, nil);
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        if (operation.responseObject) {
            int code = [[operation.responseObject objectForKey:@"code"] intValue];
            if (code == 2010) {
                code = JBError_NICKNAME_ALREADY_EXIST;
            }
            NSError *customError = [NSError errorWithDomain:[operation.responseObject objectForKey:@"message"] code:code userInfo:operation.responseObject];
            block(operation.responseObject, customError);
        }else {
            block(nil, error);
        }
    }];
}

//登录:(用户名和密码)
+ (id)logInWithUsername:(NSString *)username password:(NSString *)password error:(NSError *__autoreleasing *)error {
    NSString *urlString = [NSString stringWithFormat:@"user/login?username=%@&password=%@",username, password];
    id responseObject = [HttpRequestManager synchronousWithMethod:@"GET" urlString:urlString parameters:nil error:error];
    if (error) {
        if (*error) {
            return 0;
        }
    }
    if (responseObject) {
        int code = [[responseObject objectForKey:@"code"] intValue];
        NSString *message = [responseObject objectForKey:@"message"];
        if (code > 0 && message) {
            if (error) {
                *error = [NSError errorWithDomain:message code:code userInfo:@{NSLocalizedDescriptionKey:message}];
            }
            return 0;
        }
        [[JBCacheManager sharedJBCacheManager] writeJBUserCacheFile:responseObject];
        return [[JBObject alloc] initWithDictionary:responseObject];
    }else {
        return nil;
    }
}

+ (void)logInWithUsernameInBackground:(NSString *)username password:(NSString *)password block:(JBObjectResultBlock)block {
    NSString *baseUrl = [JBOSCloud getBaseUrlString];
    NSString *urlString = [NSString stringWithFormat:@"%@user/login?username=%@&password=%@",baseUrl,username, password];
    [HttpRequestManager getObjectWithUrlString:urlString success:^(AFHTTPRequestOperation *operation, id responseObject) {
        [[JBCacheManager sharedJBCacheManager] writeJBUserCacheFile:responseObject];
        JBObject *obj = [[JBObject alloc] initWithDictionary:responseObject];
        block(obj, nil);
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        if (operation.responseObject) {
            int code = [[operation.responseObject objectForKey:@"code"] intValue];
            NSError *customError = [NSError errorWithDomain:[operation.responseObject objectForKey:@"message"] code:code userInfo:operation.responseObject];
            block(nil, customError);
        }else {
            block(nil, error);
        }
    }];
}



//第三方登录
+ (id)logInWithAuthData:(NSDictionary *)auth authType:(JBPlatform)platform error:(NSError *__autoreleasing *)error {
    NSString *plat = [self getPlatform:platform];
    NSString *urlString = [NSString stringWithFormat:@"user/loginWithSns/%@" ,plat];
    NSString *token = [auth objectForKey:@"accessToken"];
    NSString *uid = [auth objectForKey:@"uid"];
    id responseObject = [HttpRequestManager synchronousWithMethod:@"POST" urlString:urlString parameters:@{@"accessToken":token, @"uid":uid} error:error];
    if (error) {
        if (*error) {
            return 0;
        }
    }
    if (responseObject) {
        int code = [[responseObject objectForKey:@"code"] intValue];
        NSString *message = [responseObject objectForKey:@"message"];
        if (code > 0 && message) {
            if (error) {
                *error = [NSError errorWithDomain:message code:code userInfo:@{NSLocalizedDescriptionKey:message}];
            }
            return 0;
        }
        [[JBCacheManager sharedJBCacheManager] writeJBUserCacheFile:responseObject];
        return [[JBObject alloc] initWithDictionary:responseObject];
    }else {
        return nil;
    }
}

+ (void)logInWithAuthDataInBackground:(NSDictionary *)auth authType:(JBPlatform)platform block:(JBObjectResultBlock)block {
    NSString *plat = [self getPlatform:platform];
    NSString *path = [NSString stringWithFormat:@"user/loginWithSns/%@" ,plat];
    NSString *token = [auth objectForKey:@"accessToken"];
    NSString *uid = [auth objectForKey:@"uid"];
    [HttpRequestManager postObjectWithoutDataWithUrlPath:path parameters:@{@"accessToken":token, @"uid":uid} success:^(AFHTTPRequestOperation *operation, id responseObject) {
        [[JBCacheManager sharedJBCacheManager] writeJBUserCacheFile:responseObject];
        JBObject *obj = [[JBObject alloc] initWithDictionary:responseObject];
        block(obj, nil);
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        if (operation.responseObject) {
            int code = [[operation.responseObject objectForKey:@"code"] intValue];
            NSError *customError = [NSError errorWithDomain:[operation.responseObject objectForKey:@"message"] code:code userInfo:operation.responseObject];
            block(nil, customError);
        }else {
            block(nil, error);
        }
    }];
}


//绑定
- (BOOL)addAuthData:(NSDictionary *)auth platform:(JBPlatform)platform error:(NSError *__autoreleasing *)error {
    if (!self.objectId) {
        *error = [NSError errorWithDomain:@"without user id" code:JBError_NO_USER userInfo:@{NSLocalizedDescriptionKey:@"without user id"}];
        return NO;
    }
    NSString *plat = [self getPlatform:platform];
    NSString *urlPath = [JBInterface getInterfaceWithPragma:@{@"authType":@"binding", @"id":self.objectId,@"platform":plat}];
    id responseObject = [HttpRequestManager synchronousWithMethod:@"POST" urlString:urlPath parameters:auth error:error];
    if (error) {
        if (*error) {
            return NO;
        }
    }
    if (responseObject) {
        int code = [[responseObject objectForKey:@"code"] intValue];
        NSString *message = [responseObject objectForKey:@"message"];
        if (code > 0 && message) {
            if (error) {
                *error = [NSError errorWithDomain:message code:code userInfo:@{NSLocalizedDescriptionKey:message}];
            }
            return NO;
        }
        return YES;
    }else {
        return NO;
    }
}

- (void)addAuthDataInBackground:(NSDictionary *)auth platform:(JBPlatform)platform block:(JBIdResultBlock)block {
    if (!self.objectId) {
        NSError *error = [NSError errorWithDomain:@"without user id" code:JBError_NO_USER userInfo:@{NSLocalizedDescriptionKey:@"without user id"}];
        block(nil, error);
        return ;
    }
    NSString *plat = [self getPlatform:platform];
    NSString *urlPath = [JBInterface getInterfaceWithPragma:@{@"authType":@"binding", @"id":self.objectId,@"platform":plat}];
    [HttpRequestManager postObjectWithoutDataWithUrlPath:urlPath parameters:auth success:^(AFHTTPRequestOperation *operation, id responseObject) {
        block(responseObject, nil);
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        if (operation.responseObject) {
            int code = [[operation.responseObject objectForKey:@"code"] intValue];
            NSError *customError = [NSError errorWithDomain:[operation.responseObject objectForKey:@"message"] code:code userInfo:operation.responseObject];
            block(nil, customError);
        }else {
            block(nil, error);
        }
    }];
}

//解绑
- (BOOL)deleteAuthDataForPlatform:(JBPlatform)platform error:(NSError *__autoreleasing *)error {
    if (!self.objectId) {
        *error = [NSError errorWithDomain:@"without user id" code:JBError_NO_USER userInfo:@{NSLocalizedDescriptionKey:@"without user id"}];
        return NO;
    }
    NSString *plat = [self getPlatform:platform];
    NSString *urlPath = [JBInterface getInterfaceWithPragma:@{@"authType":@"release", @"id":self.objectId,@"platform":plat}];
    id responseObject = [HttpRequestManager synchronousWithMethod:@"DELETE" urlString:urlPath parameters:nil error:error];
    if (error) {
        if (*error) {
            return NO;
        }
    }
    if (responseObject) {
        int code = [[responseObject objectForKey:@"code"] intValue];
        NSString *message = [responseObject objectForKey:@"message"];
        if (code > 0 && message) {
            if (error) {
                *error = [NSError errorWithDomain:message code:code userInfo:@{NSLocalizedDescriptionKey:message}];
            }
            
            return NO;
        }
        return YES;
    }else {
        return NO;
    }
}

- (void)deleteAuthDataForPlatformInBackground:(JBPlatform)platform block:(JBBooleanResultBlock)block {
    if (!self.objectId) {
        NSError *error = [NSError errorWithDomain:@"without user id" code:JBError_NO_USER userInfo:@{NSLocalizedDescriptionKey:@"without user id"}];
        block(NO, error);
        return ;
    }
    NSString *plat = [self getPlatform:platform];
    NSString *urlPath = [JBInterface getInterfaceWithPragma:@{@"authType":@"release", @"id":self.objectId,@"platform":plat}];
    
    [HttpRequestManager deleteObjectWithUrlPath:urlPath queryParam:nil success:^(AFHTTPRequestOperation *operation, id responseObject) {
        block(YES, nil);
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        if (operation.responseObject) {
            int code = [[operation.responseObject objectForKey:@"code"] intValue];
            NSError *customError = [NSError errorWithDomain:[operation.responseObject objectForKey:@"message"] code:code userInfo:operation.responseObject];
            block(NO, customError);
        }else {
            block(NO, error);
        }
    }];
}


+ (BOOL)logout {
    return [[JBCacheManager sharedJBCacheManager] clearJBUserCacheFile];
}


+ (JBUser *)currentUser {
    JBUser *jbUser = [[JBCacheManager sharedJBCacheManager] readJBUserCacheFile];
    return jbUser;
}

+ (NSString *)getPlatform:(JBPlatform)platform {
    NSString *plat;
    if (platform == JBPlatformSinaWeibo) {
        plat = @"weibo";
    }else if (platform == JBPlatformQQ) {
        plat = @"qq";
    }else if (platform == JBPlatformWeixin) {
        plat = @"weixin";
    }
    return  plat;
}

- (NSString *)getPlatform:(JBPlatform)platform {
    NSString *plat;
    if (platform == JBPlatformSinaWeibo) {
        plat = @"weibo";
    }else if (platform == JBPlatformQQ) {
        plat = @"qq";
    }else if (platform == JBPlatformWeixin) {
        plat = @"weixin";
    }
    return  plat;
}



@end
