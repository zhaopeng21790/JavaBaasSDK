//
//  JBACL.m
//  LeanCloud_Test
//
//  Created by zhaopeng on 15/9/27.
//  Copyright © 2015年 zhaopeng. All rights reserved.
//

#import "JBACL.h"
#import "JBUser.h"

@implementation JBACL

static JBACL *_acl;

+ (JBACL *)ACL {
    _acl = [[JBACL alloc] init];
    return _acl;
}

+ (JBACL *)ACLWithUser:(JBUser *)user {
    _acl = [[JBACL alloc] init];
    return _acl;
}

- (instancetype)init
{
    self = [super init];
    if (self) {
        _aclDictionary = [[NSMutableDictionary alloc] init];
    }
    return self;
}


- (void)setPublicReadAccess:(BOOL)allowed {
    NSMutableDictionary *dict = [_aclDictionary objectForKey:@"*"];
    if (!dict) {
        dict = [NSMutableDictionary dictionary];
    }
    if (allowed) {
        [dict setValue:@(allowed) forKey:@"read"];
        [_aclDictionary setObject:dict forKey:@"*"];
    }
}

- (void)setPublicWriteAccess:(BOOL)allowed {
    NSMutableDictionary *dict = [_aclDictionary objectForKey:@"*"];
    if (!dict) {
        dict = [NSMutableDictionary dictionary];
    }
    if (allowed) {
        [dict setValue:@(allowed) forKey:@"write"];
        [_aclDictionary setObject:dict forKey:@"*"];
    }
    
}

- (void)setReadAccess:(BOOL)allowed forUser:(JBUser *)user {
    NSMutableDictionary *dict = [_aclDictionary objectForKey:user.objectId];
    if (!dict) {
        dict = [NSMutableDictionary dictionary];
    }
    if (allowed) {
        [dict setValue:@(allowed) forKey:@"read"];
        [_aclDictionary setObject:dict forKey:user.objectId];
    }
    
}

- (void)setReadAccess:(BOOL)allowed forUserId:(NSString *)userId {
    NSMutableDictionary *dict = [_aclDictionary objectForKey:userId];
    if (!dict) {
        dict = [NSMutableDictionary dictionary];
    }
    if (allowed) {
        [dict setValue:@(allowed) forKey:@"read"];
        [_aclDictionary setObject:dict forKey:userId];
    }
}


- (void)setWriteAccess:(BOOL)allowed forUser:(JBUser *)user {
    NSMutableDictionary *dict = [_aclDictionary objectForKey:user.objectId];
    if (!dict) {
        dict = [NSMutableDictionary dictionary];
    }
    if (allowed) {
        [dict setValue:@(allowed) forKey:@"write"];
        [_aclDictionary setValue:dict forKey:user.objectId];
    }
}

- (void)setWriteAccess:(BOOL)allowed forUserId:(NSString *)userId {
    NSMutableDictionary *dict = [_aclDictionary objectForKey:userId];
    if (!dict) {
        dict = [NSMutableDictionary dictionary];
    }
    if (allowed) {
        [dict setValue:@(allowed) forKey:@"write"];
        [_aclDictionary setValue:dict forKey:userId];
    }
}




@end
