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


@implementation JBOSCloud {
    NSMutableDictionary *_configDict;
}

static JBOSCloud *_jbOSCloud;

+ (JBOSCloud *)shareJBOSCloud {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _jbOSCloud = [[JBOSCloud alloc] init];
    });
    return _jbOSCloud;
}

- (instancetype)init
{
    self = [super init];
    if (self) {
        _configDict = [[NSMutableDictionary alloc] init];
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
