//
//  JBCacheManager.m
//  bugeiOS
//
//  Created by zhaopeng on 15/10/10.
//  Copyright © 2015年 buge. All rights reserved.
//

#import "JBCacheManager.h"
#import "NSString+MD5Digest.h"
#import "JBObject.h"


#define JBCachePath @"JavaBaas/JBCachePath"
#define JBUserCachePath @"JavaBaas/JBUserCachePath"

@implementation JBCacheManager {
    
}

static JBCacheManager *_cacheManager;


+ (JBCacheManager *)sharedJBCacheManager {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _cacheManager = [[JBCacheManager alloc] init];
    });
    return _cacheManager;
}

- (instancetype)init
{
    self = [super init];
    if (self) {
    }
    return self;
}


#pragma mark -数据缓存操作
- (void)createDirectoryAtPath:(NSString *)path andData:(id)data{
    NSString *md5Path = [path MD5HexDigest];
    NSArray *pathcaches=NSSearchPathForDirectoriesInDomains(NSCachesDirectory
                                                            , NSUserDomainMask
                                                            , YES);
    NSString *filePath = [[pathcaches objectAtIndex:0] stringByAppendingPathComponent:[NSString stringWithFormat:@"%@",JBCachePath]];
    NSString *dataPath = [[pathcaches objectAtIndex:0] stringByAppendingPathComponent:[NSString stringWithFormat:@"%@/%@",JBCachePath,md5Path]];
    [[NSFileManager defaultManager] createDirectoryAtPath:filePath withIntermediateDirectories:YES attributes:nil error:nil];
    [[NSFileManager defaultManager] createFileAtPath:dataPath contents:nil attributes:nil];
    if (data) {
        //数组转位nsdata防止油NSNull时写入文件不成功
        NSData *dataArray = [NSKeyedArchiver archivedDataWithRootObject:data];
        if (dataArray) {
            [dataArray writeToFile:dataPath atomically:YES];
        }
    }
}

- (void)readCacheFileAtPath:(NSString *)path block:(JBArrayResultBlock)block {
    NSString *md5Path = [path MD5HexDigest];
    NSArray *pathcaches=NSSearchPathForDirectoriesInDomains(NSCachesDirectory
                                                            , NSUserDomainMask
                                                            , YES);
    NSString *dataPath = [[pathcaches objectAtIndex:0] stringByAppendingPathComponent:[NSString stringWithFormat:@"%@/%@",JBCachePath,md5Path]];
    NSData *data = [[NSData alloc] initWithContentsOfFile:dataPath];
    NSArray *array;
    if (data) {
        array = [NSKeyedUnarchiver unarchiveObjectWithData:data];
    }
    block(array, nil);
    
}


//清除缓存网络数据
- (void)clearQueryCacheFile {
    NSArray *pathcaches=NSSearchPathForDirectoriesInDomains(NSCachesDirectory
                                                            , NSUserDomainMask
                                                            , YES);
    NSString *dataPath = [[pathcaches objectAtIndex:0] stringByAppendingPathComponent:[NSString stringWithFormat:@"%@",JBCachePath]];
    [[NSFileManager defaultManager] removeItemAtPath:dataPath error:nil];
}



#pragma mark - 用户操作


//清除本地用户
- (BOOL)clearJBUserCacheFile {
    NSArray *pathcaches=NSSearchPathForDirectoriesInDomains(NSCachesDirectory
                                                            , NSUserDomainMask
                                                            , YES);
    NSString *dataPath = [[pathcaches objectAtIndex:0] stringByAppendingPathComponent:[NSString stringWithFormat:@"%@/JBUserInfo",JBUserCachePath]];
    return [[NSFileManager defaultManager] removeItemAtPath:dataPath error:nil];
    
}


/**
 *  写入本地(系统当前用户)
 *
 *  @param object 用户信息
 *
 *  @return 写入状态
 */
- (BOOL)writeJBUserCacheFile:(id)object {
    NSArray *pathcaches=NSSearchPathForDirectoriesInDomains(NSCachesDirectory
                                                            , NSUserDomainMask
                                                            , YES);
    NSString *filePath = [[pathcaches objectAtIndex:0] stringByAppendingPathComponent:[NSString stringWithFormat:@"%@",JBUserCachePath]];
    NSString *dataPath = [[pathcaches objectAtIndex:0] stringByAppendingPathComponent:[NSString stringWithFormat:@"%@/JBUserInfo",JBUserCachePath]];
    [[NSFileManager defaultManager] createDirectoryAtPath:filePath withIntermediateDirectories:YES attributes:nil error:nil];
    [[NSFileManager defaultManager] createFileAtPath:dataPath contents:nil attributes:nil];
    if (object) {
        NSData *data = [NSKeyedArchiver archivedDataWithRootObject:object];
        if (data) {
            BOOL ret = [data writeToFile:dataPath atomically:YES];
            return ret;
        }
        return NO;
    }
    return NO;
}


/**
 *  读取本地用户信息
 *
 *  @return 当前用户
 */
- (JBUser *)readJBUserCacheFile {
    NSArray *pathcaches=NSSearchPathForDirectoriesInDomains(NSCachesDirectory
                                                            , NSUserDomainMask
                                                            , YES);
    NSString *dataPath = [[pathcaches objectAtIndex:0] stringByAppendingPathComponent:[NSString stringWithFormat:@"%@/JBUserInfo",JBUserCachePath]];
    NSData *data = [[NSData alloc] initWithContentsOfFile:dataPath];
    if (data) {
        NSDictionary *dict = [NSKeyedUnarchiver unarchiveObjectWithData:data];
        JBUser *jbuser = [[JBUser alloc] initWithDictionary:dict];
        jbuser.sessionToken = [jbuser objectForKey:@"sessionToken"];
        jbuser.password = [jbuser objectForKey:@"password"];
        jbuser.phone = [jbuser objectForKey:@"phone"];
        jbuser.email = [jbuser objectForKey:@"email"];
        if ([jbuser objectForKey:@"auth"]) {
            jbuser.auth = [[JBObject alloc] initWithDictionary:[jbuser objectForKey:@"auth"]];
        }
        return jbuser;
    }else {
        return nil;
    }
}


+ (BOOL)writeJBInstallation:(NSString *)installation {
    if (!installation) {
        return nil;
    }
    NSArray *pathcaches=NSSearchPathForDirectoriesInDomains(NSCachesDirectory
                                                            , NSUserDomainMask
                                                            , YES);
    NSString *filePath = [[pathcaches objectAtIndex:0] stringByAppendingPathComponent:[NSString stringWithFormat:@"JavaBaas"]];
    NSString *dataPath = [[pathcaches objectAtIndex:0] stringByAppendingPathComponent:[NSString stringWithFormat:@"JavaBaas/JBInstallation"]];
    [[NSFileManager defaultManager] createDirectoryAtPath:filePath withIntermediateDirectories:YES attributes:nil error:nil];
    [[NSFileManager defaultManager] createFileAtPath:dataPath contents:nil attributes:nil];
    NSError *error;
    return [installation writeToFile:dataPath atomically:YES encoding:NSUTF8StringEncoding error:&error];

    
}
+ (NSString *)readJBInstallation {
    NSArray *pathcaches=NSSearchPathForDirectoriesInDomains(NSCachesDirectory
                                                            , NSUserDomainMask
                                                            , YES);
    NSString *dataPath = [[pathcaches objectAtIndex:0] stringByAppendingPathComponent:[NSString stringWithFormat:@"JavaBaas/JBInstallation"]];
    NSError *error;
    NSString *installation = [[NSString alloc] initWithContentsOfFile:dataPath encoding:NSUTF8StringEncoding error:&error];
    if (error) {
        return nil;
    }else {
        return installation;
    }
}



@end
