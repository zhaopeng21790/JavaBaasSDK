//
//  JBConfigManager.m
//  Buge
//
//  Created by zhaopeng on 15/12/2.
//  Copyright © 2015年 Buge. All rights reserved.
//

#import "JBOSCloud.h"
#import "JBInstallation.h"
#import "JBCacheManager.h"
#import "HttpRequestManager.h"


@implementation JBOSCloud {
    NSMutableDictionary *_configDict;
}

static JBOSCloud *_jbOSCloud;

+ (JBOSCloud *)shareJBOSCloud {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _jbOSCloud = [[super allocWithZone:NULL] init];
    });
    return _jbOSCloud;
}

+ (instancetype)allocWithZone:(struct _NSZone *)zone {
    return [JBOSCloud shareJBOSCloud];
}


- (instancetype)init
{
    self = [super init];
    if (self) {
        if (!_configDict) {
            _configDict = [[NSMutableDictionary alloc] init];
        }
    }
    return self;
}


- (void)setValue:(id)value forKey:(NSString *)key {
    [_configDict setValue:value forKey:key];
}

- (NSString *)objectForKey:(NSString *)key {
    return [_configDict objectForKey:key];
}


+ (void)setApplicationId:(NSString *)applicationId clientKey:(NSString *)clientKey baseUrl:(NSString *)baseUrlString {
    [[JBOSCloud shareJBOSCloud] setValue:applicationId forKey:@"applicationId"];
    [[JBOSCloud shareJBOSCloud] setValue:clientKey forKey:@"clientKey"];
    [[JBOSCloud shareJBOSCloud] setValue:baseUrlString forKey:@"baseUrl"];
    JBInstallation *installation = [JBInstallation currentInstallation];
    NSString *objectId = [JBCacheManager readJBInstallation];
    if (objectId) {
        installation.objectId = objectId;
    }else {
        JBObject *object = [JBObject objectWithClassName:@"_Installation"];
        [object setObject:installation.deviceToken forKey:@"deviceToken"];
        [object setObject:installation.deviceType forKey:@"deviceType"];
        [object saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
            installation.objectId = object.objectId;
            [JBCacheManager writeJBInstallation:installation.objectId];
        }];
    }
    
    [self getServerTimeBlock:^(id object, NSError *error) {
        if (!error) {
            NSNumber *num = (NSNumber *)object;
            long long serverTime = num.longLongValue;
            NSTimeInterval time=[[NSDate date] timeIntervalSince1970];
            time *= 1000;
            long long dValue = serverTime-time;
            NSString *str = [NSString stringWithFormat:@"%lld", dValue];
            [JBCacheManager writeJBServerTime:str];
        }
    }];
}

//获取服务器时间
+ (void)getServerTimeBlock:(JBIdResultBlock)block {
    NSString *baseUrl = [self getBaseUrlString];
    NSString *urlPath = [NSString stringWithFormat:@"%@/time", baseUrl];
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    AFSecurityPolicy *security = [AFSecurityPolicy policyWithPinningMode:AFSSLPinningModeNone];
    //不检验证书
    security.allowInvalidCertificates = YES;
    //不信任主机
    security.validatesDomainName = NO;
    manager.securityPolicy = security;
    manager.responseSerializer = [AFHTTPResponseSerializer serializer];
    //发送请求
    [manager GET:urlPath parameters:nil success:^(AFHTTPRequestOperation *operation, id responseObject) {
        NSString *serverTime = [[NSString alloc] initWithData:responseObject encoding:NSUTF8StringEncoding];
        block([NSNumber numberWithLongLong:serverTime.longLongValue], nil);
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        block(@(0), error);
    }];
}




+ (NSString *)getBaseUrlString {
    return [[JBOSCloud shareJBOSCloud] objectForKey:@"baseUrl"];
}


+ (NSString *)getApplicationId {
    return [[JBOSCloud shareJBOSCloud] objectForKey:@"applicationId"];
}

+ (NSString *)getClientKey {
    return [[JBOSCloud shareJBOSCloud] objectForKey:@"clientKey"];
}






@end
