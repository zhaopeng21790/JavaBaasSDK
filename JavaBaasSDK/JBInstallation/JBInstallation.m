//
//  JBInstallation.m
//  JavaBaas_iOS_SDK
//
//  Created by zhaopeng on 16/1/22.
//  Copyright © 2016年 Buge. All rights reserved.
//

#import "JBInstallation.h"
#import <UIKit/UIKit.h>

@implementation JBInstallation

static JBInstallation *_jbInstallation;

- (NSString *)deviceToken {
    NSString *identifierForVendor = [[UIDevice currentDevice].identifierForVendor UUIDString];
    return identifierForVendor;
}

- (NSString *)deviceType {
    return @"ios";
}


+ (instancetype)currentInstallation {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _jbInstallation = [[super allocWithZone:NULL] init];
    });
    return _jbInstallation;
}

+ (instancetype)allocWithZone:(struct _NSZone *)zone {
    return [JBInstallation currentInstallation];
}




@end
