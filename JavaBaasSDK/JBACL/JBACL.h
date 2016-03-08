//
//  JBACL.h
//  LeanCloud_Test
//
//  Created by zhaopeng on 15/9/27.
//  Copyright © 2015年 zhaopeng. All rights reserved.
//

#import <Foundation/Foundation.h>
@class JBUser;

@interface JBACL : NSObject



@property (nonatomic, strong) NSMutableDictionary *aclDictionary;
/** @name Creating an ACL */

/*!
 创建一个ACL
 */
+ (JBACL *)ACL;


/**
 *  设置全局可读权限
 */
- (void)setPublicReadAccess:(BOOL)allowed;



/**
 *  设置全局可写权限
 */
- (void)setPublicWriteAccess:(BOOL)allowed;




/**
 *  针对某个用户设置可读权限
 *
 *  @param allowed yes:可读
 *  @param userId  用户id
 */
- (void)setReadAccess:(BOOL)allowed forUserId:(NSString *)userId;

/**
 *  针对某个用户设置可写权限
 *
 *  @param allowed yes:可写
 *  @param userId  用户id
 */
- (void)setWriteAccess:(BOOL)allowed forUserId:(NSString *)userId;


/**
 *  针对某个用户设置可读权限
 *
 *  @param allowed yes:可读
 *  @param userId  用户JBUser
 */
- (void)setReadAccess:(BOOL)allowed forUser:(JBUser *)user;



/**
 *  针对某个用户设置可写权限
 *
 *  @param allowed yes:可读
 *  @param userId  用户JBUser
 */
- (void)setWriteAccess:(BOOL)allowed forUser:(JBUser *)user;



@end
