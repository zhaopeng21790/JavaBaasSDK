//
//  JBCloud.m
//  bugeiOS
//
//  Created by zhaopeng on 15/10/15.
//  Copyright © 2015年 buge. All rights reserved.
//

#import "JBCloud.h"
#import "HttpRequestManager.h"

@implementation JBCloud

//云方法调用（同步）
+ (id)callFunction:(NSString *)function withParameters:(NSDictionary *)parameters error:(NSError *__autoreleasing *)error {
    
    id responseObject = [HttpRequestManager cloudWithFunName:function parameters:parameters error:error];
    if (error) {
        if (*error) {
            return nil;
        }
    }
    return responseObject;
}


//云方法调用（异步）
+ (void)callFunctionInBackground:(NSString *)function withParameters:(NSDictionary *)parameters block:(JBIdResultBlock)block {
    [HttpRequestManager cloudWithFunName:function parameters:parameters success:^(AFHTTPRequestOperation *operation, id responseObject) {
        @try {
            
            if (operation.responseObject) {
                int code = [[operation.responseObject objectForKey:@"code"] intValue];
                if (code == 0) {
                    block(responseObject, nil);
                }else {
                    NSError *customError = [NSError errorWithDomain:[operation.responseObject objectForKey:@"message"] code:code userInfo:operation.responseObject];
                    block(responseObject, customError);
                }
                
            }else {
                block(responseObject, nil);
            }
        }
        @catch (NSException *exception) {
            
        }
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
            if (operation.responseObject) {
                int code = [[operation.responseObject objectForKey:@"code"] intValue];
                NSError *customError = [NSError errorWithDomain:[operation.responseObject objectForKey:@"message"] code:code userInfo:operation.responseObject];
                block(nil, customError);
            }else {
                block(nil, error);
            }
    }];
}




@end
