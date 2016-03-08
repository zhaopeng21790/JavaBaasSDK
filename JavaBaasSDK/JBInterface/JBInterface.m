//
//  JBInterface.m
//  Buge
//
//  Created by zhaopeng on 15/10/20.
//  Copyright © 2015年 Buge. All rights reserved.
//

#import "JBInterface.h"

@implementation JBInterface

+ (NSString *)getInterfaceWithParam:(NSDictionary *)dict {
    
    NSString *string;
    NSString *className = [dict objectForKey:@"className"];
    NSString *objectId = [dict objectForKey:@"_id"];
    BOOL find = [[dict objectForKey:@"find"] boolValue];
    NSString *authType = [dict objectForKey:@"authType"];
    NSString *platform = [dict objectForKey:@"platform"];
    
    if (platform) {
        if (objectId) {
            string = [NSString stringWithFormat:@"user/%@/%@/%@", objectId, authType,platform];
        }
    }else {
        if (find) {
            if (objectId) {
                string = [NSString stringWithFormat:@"object/%@/%@",className ,objectId];
            }else {
                string = [NSString stringWithFormat:@"object/%@",className];
            }
        }else {
            if ([className isEqualToString:@"_User"]) {
                if (objectId) {
                    string = [NSString stringWithFormat:@"user/%@", objectId];
                }else {
                    string = @"user/";
                }
            }else if ([className isEqualToString:@"_Installation"]) {
                if (objectId) {
                    string = [NSString stringWithFormat:@"installation/%@", objectId];
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
        }
        
    }
    return string;
}



@end
