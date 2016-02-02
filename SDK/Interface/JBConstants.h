//
//  JBConstants.h
//  Buge_SDK
//
//  Created by zhaopeng on 15/12/29.
//  Copyright © 2015年 Buge. All rights reserved.
//

@class JBObject;
@class JBUser;


#ifdef DEBUG
// 调试状态
#define MyLog(...) NSLog(__VA_ARGS__)
#else
// 发布状态
#define MyLog(...)
#endif


#define True @"true"
#define False @"false"



/**
 缓存策略
 */
typedef enum  {
    kJBCachePolicyDefault =0, //查询网络并更新缓存
    kJBCachePolicyIgnoreCache = 1,  //忽略缓存
    kJBCachePolicyCacheOnly = 2,    //只查缓存
    kJBCachePolicyCacheThenNetwork = 3,//先查缓存在查网络
    kJBCachePolicyNetworkOnly = 4,//只查网络
    
}kJBCachePolicyCache;


/**
 错误码
 */
typedef enum {
    JBError_NO_CLASSNAME = 5000,//without className
    JBError_NO_OBJECTID = 5001,//without id
    JBError_NO_USER = 5002,//without user 
    JBError_COUNT_ZORE = 5003,//count=0
    JBError_PARAMS_ERROR = 5004, //参数类型错误
    JBError_URL_ERROR = 5005,
    JBError_NICKNAME_ALREADY_EXIST = 5006


}JBErrorCode;


/**
 第三方平台
 */
typedef enum  {
    JBPlatformSinaWeibo=1,
    JBPlatformQQ=2,
    JBPlatformWeixin=3
}JBPlatform;


/**
 *  自定义回调信息
 */
typedef void (^JBBooleanResultBlock)(BOOL succeeded, NSError *error);
typedef void (^JBIntegerResultBlock)(NSInteger number, NSError *error);
typedef void (^JBArrayResultBlock)(NSArray *objects, NSError *error);
typedef void (^JBObjectResultBlock)(JBObject *object, NSError *error);
typedef void (^JBIntegerResultBlock)(NSInteger number, NSError *error);
typedef void (^JBUserResultBlock)(JBUser *user, NSError *error);
typedef void (^JBDataResultBlock)(NSData *data, NSError *error);
typedef void (^JBDataStreamResultBlock)(NSInputStream *stream, NSError *error);
typedef void (^JBStringResultBlock)(NSString *string, NSError *error);
typedef void (^JBIdResultBlock)(id object, NSError *error);
typedef void (^JBProgressBlock)(float percentDone);
typedef void (^JBDictionaryResultBlock)(NSDictionary * dict, NSError *error);




