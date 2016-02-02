//
//  JBInterface.m
//  Buge
//
//  Created by zhaopeng on 15/10/20.
//  Copyright © 2015年 Buge. All rights reserved.
//

#import "JBInterface.h"

@implementation JBInterface

+ (NSString *)getInterfaceWithPragma:(NSDictionary *)dict {
    
    NSString *string;
    NSString *className = [dict objectForKey:@"className"];
    NSString *objectId = [dict objectForKey:@"id"];
    
    if ([className isEqualToString:@"_User"]) {
        if (objectId) {
            string = [NSString stringWithFormat:@"user/%@", objectId];
        }else {
            string = @"user/";
        }
    }else if ([className isEqualToString:@"_Installation"]) {
        if (objectId) {
            string = [NSString stringWithFormat:@"user/%@", objectId];
        }else {
            string = @"installation/";
        }
    }else if(className){
        if (objectId) {
            string = [NSString stringWithFormat:@"object/%@/%@",className ,objectId];
        }else {
            string = [NSString stringWithFormat:@"object/%@",className];
        }
    }
    
    NSString *authType = [dict objectForKey:@"authType"];
    NSString *platform = [dict objectForKey:@"platform"];
    if (platform) {
        if (objectId) {
            string = [NSString stringWithFormat:@"user/%@/%@/%@", objectId, authType,platform];
        }
    }
    
    return string;
}


@end
