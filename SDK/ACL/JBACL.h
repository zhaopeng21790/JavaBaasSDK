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
 Creates an ACL with no permissions granted.
 */
+ (JBACL *)ACL;

/** @name Controlling Public Access */

/*!
 Set whether the public is allowed to read this object.
 @param allowed allowed or not
 */

- (void)setPublicReadAccess:(BOOL)allowed;



/*!
 Set whether the public is allowed to write this object.
 @param allowed allowed or not
 */
- (void)setPublicWriteAccess:(BOOL)allowed;




/*!
 Set whether the given user id is allowed to read this object.
 @param allowed allowed or not
 @param userId the JBUser's objectId
 */
- (void)setReadAccess:(BOOL)allowed forUserId:(NSString *)userId;

/*!
 Set whether the given user id is allowed to write this object.
 @param allowed allowed or not
 @param userId the JBUser's objectId
 */
- (void)setWriteAccess:(BOOL)allowed forUserId:(NSString *)userId;


/*!
 Set whether the given user is allowed to read this object.
 @param allowed allowed or not
 @param user the JBUser
 */
- (void)setReadAccess:(BOOL)allowed forUser:(JBUser *)user;



/*!
 Set whether the given user is allowed to write this object.
 @param allowed allowed or not
 @param user the JBUser
 */
- (void)setWriteAccess:(BOOL)allowed forUser:(JBUser *)user;



@end
