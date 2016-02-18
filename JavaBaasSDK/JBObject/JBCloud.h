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

+ (id)callFunction:(NSString *)function withParameters:(NSDictionary *)parameters error:(NSError *__autoreleasing *)error;

/*!
 Calls the given cloud function with the parameters provided asynchronously and calls the given block when it is done.
 @param function The function name to call.
 @param parameters The parameters to send to the function.
 @param block The block to execute. The block should have the following argument signature:(id result, NSError *error).
 */
+ (void)callFunctionInBackground:(NSString *)function withParameters:(NSDictionary *)parameters block:(JBIdResultBlock)block;





@end
