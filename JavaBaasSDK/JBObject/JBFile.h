//
//  JBFile.h
//  
//
//  Created by zhaopeng on 15/10/9.
//  Copyright © 2015年 buge. All rights reserved.
//

#import "JBObject.h"
#import "JBConstants.h"


@interface JBFile : JBObject

@property (nonatomic, strong) NSString *url;

@property (nonatomic, strong) NSString *name;

+ (id)fileWithData:(NSData *)data;

+ (id)fileWithName:(NSString *)name data:(NSData *)data;

+ (id)fileWithURL:(NSURL *)url;

- (void)saveInBackgroundWithBlock:(JBIdResultBlock)block;

- (void)saveInBackgroundWithBlock:(JBIdResultBlock)block progressBlock:(JBProgressBlock)progressBlock;


@end
