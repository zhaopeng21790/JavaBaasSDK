//
//  JBFile.m
//  bugeiOS
//
//  Created by zhaopeng on 15/10/9.
//  Copyright © 2015年 buge. All rights reserved.
//

#import "JBFile.h"
#import "QiniuSDK.h"
#import "HttpRequestManager.h"
#import "JBOSCloud.h"

@implementation JBFile

+ (instancetype)objectWithClassName:(NSString *)className {
    if (className) {
        JBFile *file = [[JBFile alloc] init];
        [file setValue:@"File" forKey:@"__type"];
        file.className = className;
        return file;
    }
    return nil;
}


+ (instancetype)objectWithoutDataWithObjectId:(NSString *)objectId {
    if (objectId) {
        JBFile *file = [[JBFile alloc] init];
        [file setValue:@"File" forKey:@"__type"];
        [file setValue:objectId forKey:@"_id"];
        file.objectId = objectId;
        return file;
    }
    return nil;
}



+ (id)fileWithData:(NSData *)data {
    JBFile *file = [[JBFile alloc] init];
    if (data) {
        [file setObject:data forKey:@"data"];
    }
    return file;
}

+ (id)fileWithName:(NSString *)name data:(NSData *)data {
    JBFile *file = [[JBFile alloc] init];
    if (data) {
        [file setObject:data forKey:@"data"];
    }
    if (name) {
        [file setObject:name forKey:@"name"];
    }
    return file;
}


+ (id)fileWithURL:(NSURL *)url {
    JBFile *file = [[JBFile alloc] init];
    NSData *data = [[NSData alloc] initWithContentsOfURL:url];
    if (data) {
        [file setObject:data forKey:@"data"];
    }
    return file;
}

- (void)saveInBackgroundWithBlock:(JBIdResultBlock)block progressBlock:(JBProgressBlock)progressBlock {
    NSString *baseUrl = [JBOSCloud getBaseUrlString];
    NSString *url = [NSString stringWithFormat:@"%@/api/file/getToken?fileName=iOS_File&platform=qiniu", baseUrl];
    [HttpRequestManager getObjectWithUrlString:url success:^(AFHTTPRequestOperation *operation, id responseObject) {
        QNUploadManager *upManager = [[QNUploadManager alloc] init];
        NSString *token = [[responseObject objectForKey:@"data"] objectForKey:@"token"];
        NSString *name;
        if ([[self dictionaryForObject] objectForKey:@"name"]) {
            name = [[self dictionaryForObject] objectForKey:@"name"];
        }else {
            name = [[responseObject objectForKey:@"data"] objectForKey:@"name"];
        }
        NSData *data = [[self dictionaryForObject] objectForKey:@"data"];
        QNUploadOption *uploadOption = [[QNUploadOption alloc] initWithMime:nil progressHandler:^(NSString *key, float percent) {
            MyLog(@"上传进度:---- %f", percent);
            progressBlock(percent);
        } params:nil checkCrc:YES cancellationSignal:nil];
        [upManager putData:data
                       key:name
                     token:token
                  complete: ^(QNResponseInfo *info, NSString *key, NSDictionary *resp) {
                      MyLog(@" --->> Info: %@  ", info);
                      MyLog(@" ---------------------");
                      MyLog(@" --->> Response: %@,  ", resp);//成功的信息在resp中
                      progressBlock(1.0);
                      block(resp, nil);
                  }
                    option:uploadOption];
        
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        block(nil, error);
    }];
}


- (void)saveInBackgroundWithBlock:(JBIdResultBlock)block {
    NSString *baseUrl = [JBOSCloud getBaseUrlString];
    NSString *url = [NSString stringWithFormat:@"%@/api/file/getToken?fileName=iOS_File&platform=qiniu", baseUrl];
    [HttpRequestManager getObjectWithUrlString:url success:^(AFHTTPRequestOperation *operation, id responseObject) {
        QNUploadManager *upManager = [[QNUploadManager alloc] init];
        NSString *token = [[responseObject objectForKey:@"data"] objectForKey:@"token"];
        NSString *name;
        if ([[self dictionaryForObject] objectForKey:@"name"]) {
            name = [[self dictionaryForObject] objectForKey:@"name"];
        }else {
            name = [[responseObject objectForKey:@"data"] objectForKey:@"name"];
        }
        NSData *data = [[self dictionaryForObject] objectForKey:@"data"];
        QNUploadOption *uploadOption = [[QNUploadOption alloc] initWithMime:nil progressHandler:^(NSString *key, float percent) {
            MyLog(@"-------------->%f", percent);
        } params:nil checkCrc:YES cancellationSignal:nil];
        
        [upManager putData:data
                       key:name
                     token:token
                  complete: ^(QNResponseInfo *info, NSString *key, NSDictionary *resp) {
                      MyLog(@" --->> Info: %@  ", info);
                      MyLog(@" ---------------------");
                      MyLog(@" --->> Response: %@,  ", resp);//成功的信息在resp中
                      block(resp, nil);
                  }
                    option:uploadOption];
        
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        block(nil, error);
    }];
}

@end
