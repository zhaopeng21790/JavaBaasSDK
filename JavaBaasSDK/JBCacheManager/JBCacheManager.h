//
//  JBCacheManager.h
//  bugeiOS
//
//  Created by zhaopeng on 15/10/10.
//  Copyright © 2015年 buge. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "JBConstants.h"
#import "JBUser.h"

@interface JBCacheManager : NSObject

+ (JBCacheManager *)sharedJBCacheManager;

- (void)createDirectoryAtPath:(NSString *)path andData:(id)data;

- (void)readCacheFileAtPath:(NSString *)path block:(JBArrayResultBlock)block;

- (void)clearQueryCacheFile;

/**
 *  获取本地系统用户
 */
- (JBUser *)readJBUserCacheFile;


/**
 *  写入本地（系统用户）
 *
 *  @param object 用户信息
 *
 */
- (BOOL)writeJBUserCacheFile:(id)object;

/**
 *  清除本地用户信息
 *
 */
- (BOOL)clearJBUserCacheFile;

+ (BOOL)writeJBInstallation:(NSString *)installation;

+ (NSString *)readJBInstallation;


+ (BOOL)writeJBServerTime:(NSString *)serverTime;

+ (NSString *)readJBServerTime;


@end
