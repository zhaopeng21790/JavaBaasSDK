//
//  JBConfigManager.h
//  Buge
//
//  Created by zhaopeng on 15/12/2.
//  Copyright © 2015年 Buge. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "JBConstants.h"

@interface JBOSCloud : NSObject

+ (JBOSCloud *)shareJBOSCloud;


- (void)setValue:(id)value forKey:(NSString *)key;

- (NSString *)objectForKey:(NSString *)key;


/**
 *  应用初始化
 *
 *  @param applicationId 应用id
 *  @param clientKey     应用key
 *  @param baseUrlString    基址
 */
+ (void)setApplicationId:(NSString *)applicationId clientKey:(NSString *)clientKey baseUrl:(NSString *)baseUrlString;

/**
 *  get Application Id
 *
 *  @return Application Id
 */
+ (NSString *)getApplicationId;

/**
 *  get Client Key
 *
 *  @return Client Key
 */
+ (NSString *)getClientKey;


/**
 *  获取应用基址
 
 *
 *  @return
 */
+ (NSString *)getBaseUrlString;


@end
