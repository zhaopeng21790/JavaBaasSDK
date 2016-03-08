//
//  JBUser.h
//
//
//  Created by zhaopeng on 15/9/29.
//  Copyright © 2015年 zhaopeng. All rights reserved.
//

#import "JBObject.h"
#import "JBConstants.h"



@interface JBUser : JBObject

@property (nonatomic, strong) NSString *username;

@property (nonatomic, strong) NSString *password;

@property (nonatomic, strong) NSString *phone;

@property (nonatomic, strong) NSString *email;

@property (nonatomic, strong) NSString *sessionToken;
//用户授权信息
@property (nonatomic, strong) NSDictionary *auth;


+ (JBUser *)user;

/**
 *  注册（同步方法）
 *
 *  @param error 返回错误
 *
 *  @return <#return value description#>
 */
- (BOOL)signUp:(NSError **)error;


/**
 *  注册（异步方法）
 *
 *  @param block block description
 */
- (void)signUpInBackgroundWithBlock:(JBBooleanResultBlock)block;

/**
 *  更新密码(同步)
 *
 *  @param password    旧密码
 *  @param newPassword 新密码
 *  @param error       执行结果返回error
 *
 *  @return <#return value description#>
 */
- (BOOL)updatePassword:(NSString *)password newPassword:(NSString *)newPassword error:(NSError **)error;

/**
 *  更新密码(异步)
 *
 *  @param password    旧密码
 *  @param newPassword 新密码
 *  @param error       执行结果返回error
 *
 *  @return <#return value description#>
 */
- (void)updatePassword:(NSString *)password newPassword:(NSString *)newPassword block:(JBBooleanResultBlock)block;


/**
 *  用户名密码登录（同步）
 *
 *  @param username 用户名
 *  @param password <#password description#>
 *  @param error    <#error description#>
 *
 *  @return <#return value description#>
 */
+ (id)logInWithUsername:(NSString *)username password:(NSString *)password error:(NSError **)error;


/**
 *  用户名密码登录（异步）
 *
 *  @param username 用户名
 *  @param password <#password description#>
 *  @param error    <#error description#>
 *
 *  @return <#return value description#>
 */
+ (void)logInWithUsernameInBackground:(NSString *)username password:(NSString *)password block:(JBUserResultBlock)block;




/**
 *  第三方登录（同步）
 *
 *  @param auth     第三方授权信息key分别为：@"accessToken"，@"uid"
 *  @param platform 第三方平台
 *
 */
+ (id)logInWithAuthData:(NSDictionary *)auth authType:(JBPlatform)platform error:(NSError **)error;


/**
 *  第三方登录（异步）
 *
 *  @param auth     第三方授权信息
 *  @param platform 第三方平台
 *
 *  @return <#return value description#>
 */
+ (void)logInWithAuthDataInBackground:(NSDictionary *)auth authType:(JBPlatform)platform block:(JBUserResultBlock)block;


/**
 *  绑定第三方信息（同步）
 *
 *  @param auth     <#auth description#>
 *  @param platform <#platform description#>
 *
 *  @return <#return value description#>
 */
- (BOOL)addAuthData:(NSDictionary *)auth platform:(JBPlatform)platform error:(NSError **)error;


/**
 *  邦迪第三方信息（异步）
 *
 *  @param auth     <#auth description#>
 *  @param platform <#platform description#>
 *
 *  @return <#return value description#>
 */
- (void)addAuthDataInBackground:(NSDictionary *)auth platform:(JBPlatform)platform block:(JBIdResultBlock)block;


/**
 *  解绑（同步）
 *
 *  @param platform <#platform description#>
 *  @param error    <#error description#>
 *
 *  @return <#return value description#>
 */
- (BOOL)deleteAuthDataForPlatform:(JBPlatform)platform error:(NSError **)error;


/**
 *  解绑(异步)
 *
 *  @param platform 第三方平台
 */
- (void)deleteAuthDataForPlatformInBackground:(JBPlatform)platform block:(JBBooleanResultBlock)block;


/**
 *  登出
 */
+ (BOOL)logout;

/**
 *  获取当前用户
 *
 *  @return 登出状态
 */
+ (JBUser *)currentUser;


/*!
 *  @param newUser 新的 JBUser 实例
 *  @param save 是否需要把 newUser 保存到本地缓存。如果 newUser==nil && save==YES，则会清除本地缓存
 * Note: 请注意不要随意调用这个函数！
 */
+(void)changeCurrentUser:(JBUser *)newUser
                    save:(BOOL)save;





@end
