//
//  JBInstallation.h
//  JavaBaas_iOS_SDK
//
//  Created by zhaopeng on 16/1/22.
//  Copyright © 2016年 Buge. All rights reserved.
//

#import "JBObject.h"

@interface JBInstallation : JBObject

//对iOS来说deviceType = ios
@property (nonatomic, strong, readonly) NSString *deviceType;

//设备的唯一标识
@property (nonatomic, strong, readonly) NSString *deviceToken;

+ (instancetype)currentInstallation;

+ (void)getCurrentInstallationIdBlock:(JBIdResultBlock)block;


@end
