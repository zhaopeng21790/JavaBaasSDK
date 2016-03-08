//
//  JBCloud.h
//  bugeiOS
//
//  Created by zhaopeng on 15/10/15.
//  Copyright © 2015年 buge. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "JBConstants.h"

@interface JBCloud : NSObject



/**
 *  <#Description#>
 *
 *  @param function   函数的名称
 *  @param parameters 传入的函数参数
 *  @param error      错误返回
 */
+ (id)callFunction:(NSString *)function withParameters:(NSDictionary *)parameters error:(NSError *__autoreleasing *)error;

+ (void)callFunctionInBackground:(NSString *)function withParameters:(NSDictionary *)parameters block:(JBIdResultBlock)block;





@end
