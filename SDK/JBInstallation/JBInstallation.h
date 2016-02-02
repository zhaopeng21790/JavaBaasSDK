//
//  JBInstallation.h
//  JavaBaas_iOS_SDK
//
//  Created by zhaopeng on 16/1/22.
//  Copyright © 2016年 Buge. All rights reserved.
//

#import "JBObject.h"

@interface JBInstallation : JBObject

@property (nonatomic, strong, readonly) NSString *deviceType;

@property (nonatomic, strong, readonly) NSString *deviceToken;

+ (instancetype)currentInstallation;

@end
