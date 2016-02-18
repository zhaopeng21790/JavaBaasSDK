//
//  JBObject.m
//  LeanCloud_Test
//
//  Created by zhaopeng on 15/9/28.
//  Copyright © 2015年 zhaopeng. All rights reserved.
//

#import "JBObject.h"
#import <objc/runtime.h>
#import "JBInterface.h"
#import "HttpRequestManager.h"
#import "JBInterface.h"

@implementation JBObject {
    NSMutableDictionary *_dictionary;
    NSMutableDictionary *_pointerDictionary;
}

- (instancetype)initWithDictionary:(NSDictionary *)dictionay {
    self = [super init];
    if (self) {
        if (dictionay) {
            _dictionary = nil;
            _dictionary = [[NSMutableDictionary alloc] initWithDictionary:dictionay];
            long long createdaAt = [[dictionay objectForKey:@"createdAt"] longLongValue];
            _createdAt = [self getDateWithTime:createdaAt];
            long long updatedAt = [[dictionay objectForKey:@"updatedAt"] longLongValue];
            _updatedAt = [self getDateWithTime:updatedAt];
            _objectId = [dictionay objectForKey:@"_id"];
            _className = [dictionay objectForKey:@"className"];
            NSDictionary *aclDictionary = [dictionay objectForKey:@"acl"];
            _acl = [JBACL ACL];
            _acl.aclDictionary = [NSMutableDictionary dictionaryWithDictionary:aclDictionary];
        }
        
    }
    return self;
}

- (void)setAcl:(JBACL *)acl {
    [self setObject:acl.aclDictionary forKey:@"acl"];
}

- (NSDate *)getDateWithTime:(long long)time {
    NSTimeInterval tempMilli = time;
    NSTimeInterval seconds = tempMilli/1000.0;
    NSDate *date = [NSDate dateWithTimeIntervalSince1970:seconds];
    return date;
}

+ (JBObject *)object {
    return [[JBObject alloc] init];
}


- (instancetype)init
{
    self = [super init];
    if (self) {
        _dictionary = [NSMutableDictionary dictionary];
    }
    return self;
}

+ (instancetype)objectWithClassName:(NSString *)className {
    if (className) {
        JBObject *object = [[JBObject alloc] init];
        [object setValue:@"Pointer" forKey:@"__type"];
        object.className = className;
        return object;
    }
    return nil;
}


+ (instancetype)objectWithoutDataWithObjectId:(NSString *)objectId {
    if (objectId) {
        JBObject *object = [[JBObject alloc] init];
        [object setValue:@"Pointer" forKey:@"__type"];
        [object setValue:objectId forKey:@"_id"];
        object.objectId = objectId;
        return object;
    }
    return nil;
}


+ (instancetype)objectWithoutDataWithClassName:(NSString *)className objectId:(NSString *)objectId {
    JBObject *object = [[JBObject alloc] init];
    if (className && objectId) {
        [object setValue:@"Pointer" forKey:@"__type"];
        [object setValue:objectId forKey:@"_id"];
        object.className = className;
        object.objectId = objectId;
        return object;
    }
    return nil;
}

- (void)setClassName:(NSString *)className {
    _className = className;
    if (className) {
        [_dictionary setObject:className forKey:@"className"];
    }
}

- (void)setObjectId:(NSString *)objectId {
    _objectId = objectId;
    if (_objectId) {
        [_dictionary setObject:objectId forKey:@"_id"];
    }
}




#pragma mark- increment

- (BOOL)isIntType:(NSNumber *)amount {
    if (strcmp([amount objCType], @encode(int)) == 0 || strcmp([amount objCType], @encode(NSInteger)) == 0 || strcmp([amount objCType], @encode(int64_t)) == 0) {
        return YES;
    }
    return NO;
}



- (BOOL)incrementKey:(NSString *)key error:(NSError *__autoreleasing *)error {
    id responseObject = [self incrementHttpWithParamsSync:@{key:@(1)} error:error];
    if (responseObject) {
        int code = [[responseObject objectForKey:@"code"] intValue];
        if (code == 0) {
            return YES;
        }
        return NO;
    }else {
        return NO;
    }
}

- (void)incrementKeyInBackground:(NSString *)key block:(JBBooleanResultBlock)block {
    [self incrementHttpWithParamsInBackground:@{key:@(1)} block:block];
}

- (BOOL)incrementKey:(NSString *)key byAmount:(NSNumber *)amount error:(NSError *__autoreleasing *)error {
    if (amount) {
        if ([self isIntType:amount]) {
            id responseObject = [self incrementHttpWithParamsSync:@{key:amount} error:error];
            if (responseObject) {
                int code = [[responseObject objectForKey:@"code"] intValue];
                if (code == 0) {
                    return YES;
                }
                return NO;
            }else {
                return NO;
            }
        }else {
            if (error) {
                *error = [NSError errorWithDomain:@"参数类型错误" code:JBError_PARAMS_ERROR userInfo:@{NSLocalizedDescriptionKey:@"参数类型错误"}];
            }
            return NO;
        }
    }else {
        if (error) {
            *error = [NSError errorWithDomain:@"count ＝ 0" code:JBError_COUNT_ZORE userInfo:@{NSLocalizedDescriptionKey:@"count ＝ 0"}];
        }
        return NO;
    }
}

- (void)incrementKeyInBackground:(NSString *)key byAmount:(NSNumber *)amount block:(JBBooleanResultBlock)block {
    if (amount){
        if ([self isIntType:amount]) {
            [self incrementHttpWithParamsInBackground:@{key:amount} block:block];
        }else {
            NSError *error = [NSError errorWithDomain:@"参数类型错误" code:JBError_PARAMS_ERROR userInfo:@{NSLocalizedDescriptionKey:@"参数类型错误"}];
            block(NO, error);
        }
    }else {
        NSError *error = [NSError errorWithDomain:@"count ＝ 0" code:JBError_COUNT_ZORE userInfo:@{NSLocalizedDescriptionKey:@"count ＝ 0"}];
        block(NO, error);
    }
}

- (BOOL)incrementKeys:(NSDictionary *)keys error:(NSError *__autoreleasing *)error {
    NSArray *array = [keys allKeys];
    BOOL temp = NO;
    for (NSString *key in array) {
        id value = [keys objectForKey:key];
        if (![value isKindOfClass:[NSNumber class]]) {
            temp = YES;
            break;
        }else if (![self isIntType:value]) {
            temp = YES;
            break;
        }
    }
    if (temp) {
        if (error) {
           *error = [NSError errorWithDomain:@"参数类型错误" code:JBError_PARAMS_ERROR userInfo:@{NSLocalizedDescriptionKey:@"参数类型错误"}];
        }
        return NO;
    }
    id responseObject = [self incrementHttpWithParamsSync:keys error:error];
    if (responseObject) {
        int code = [[responseObject objectForKey:@"code"] intValue];
        if (code == 0) {
            return YES;
        }
        return NO;
    }else {
        return NO;
    }
}


- (void)incrementKeysInBackground:(NSDictionary *)keys block:(JBBooleanResultBlock)block {
    NSArray *array = [keys allKeys];
    BOOL temp = NO;
    for (NSString *key in array) {
        id value = [keys objectForKey:key];
        if (![value isKindOfClass:[NSNumber class]]) {
            temp = YES;
            break;
        }else if (![self isIntType:value]) {
            temp = YES;
            break;
        }
    }
    if (temp) {
        NSError *error = [NSError errorWithDomain:@"参数类型错误" code:JBError_PARAMS_ERROR userInfo:@{NSLocalizedDescriptionKey:@"参数类型错误"}];
        block(NO, error);
        return;
    }
    [self incrementHttpWithParamsInBackground:keys block:block];
}



- (id)incrementHttpWithParamsSync:(NSDictionary *)dictionary error:(NSError *__autoreleasing *)error{
    NSString *urlPath = [JBInterface getInterfaceWithPragma:@{@"className":_className, @"_id":_objectId}];
    NSString *string = [urlPath stringByAppendingString:@"/inc"];
    id responseObject = [HttpRequestManager synchronousWithMethod:@"PUT" urlString:string parameters:dictionary error:error];
    if (error) {
        if (*error) {
            return nil;
        }
    }
    int code = [[responseObject objectForKey:@"code"] intValue];
    NSString *message = [responseObject objectForKey:@"message"];
    if (code != 0 && message) {
        if (error) {
            *error = [NSError errorWithDomain:message code:code userInfo:@{NSLocalizedDescriptionKey:message}];
        }
        return nil;
    }
    return responseObject;
}


- (void)incrementHttpWithParamsInBackground:(NSDictionary *)dictionary block:(JBBooleanResultBlock)block{
    if (!_objectId || !_className) {
        NSString *domain = _objectId == nil ? @"without id" : @"without className";
        JBErrorCode code = _objectId == nil ? JBError_NO_OBJECTID : JBError_NO_CLASSNAME;
        NSError *error = [NSError errorWithDomain:domain code:code userInfo:@{NSLocalizedDescriptionKey:@"without id"}];
        block(NO, error);
        return;
    }
    NSString *urlPath = [JBInterface getInterfaceWithPragma:@{@"className":_className, @"_id":_objectId}];
    NSString *string = [urlPath stringByAppendingString:@"/inc"];
    
    [HttpRequestManager updateObjectWithUrlPath:string parameters:dictionary success:^(AFHTTPRequestOperation *operation, id responseObject) {
        block(YES, nil);
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        if (operation.responseObject) {
            int code = [[operation.responseObject objectForKey:@"code"] intValue];
            NSError *customError = [NSError errorWithDomain:[operation.responseObject objectForKey:@"message"] code:code userInfo:operation.responseObject];
            block(NO, customError);
        }else {
            block(NO, error);
        }
    }];
}


#pragma mark - set, get



- (NSArray *)allKeys {
    return [_dictionary allKeys];
}

- (void)setValue:(id)value forKey:(NSString *)key {
    if (![value isKindOfClass:[JBObject class]]) {
        [_dictionary setValue:value forKey:key];
    }else {
        NSDictionary *dict = [NSMutableDictionary dictionary];
        if ([[value objectForKey:@"__type"] isEqualToString:@"File"]) {
            [dict setValue:@"File" forKey:@"__type"];
            [dict setValue:[value objectForKey:@"_id"] forKey:@"_id"];
        }else if ([[value objectForKey:@"__type"] isEqualToString:@"Pointer"]) {
            [dict setValue:@"Pointer" forKey:@"__type"];
            [dict setValue:[value objectForKey:@"className"] forKey:@"className"];
            [dict setValue:[value objectForKey:@"_id"] forKey:@"_id"];
        }else {
            dict = [value dictionaryForObject];
        }
        [_dictionary setValue:dict forKey:key];
    }
}

- (void)setObject:(id)object forKey:(NSString *)key {
    if (![object isKindOfClass:[JBObject class]]) {
        [_dictionary setValue:object forKey:key];
    }else {
        NSDictionary *dict = [NSMutableDictionary dictionary];
        NSString *_id = [object objectForKey:@"_id"];
        if (_id) {
            if ([[object objectForKey:@"__type"] isEqualToString:@"File"]) {
                [dict setValue:@"File" forKey:@"__type"];
                [dict setValue:[object objectForKey:@"_id"] forKey:@"_id"];
            }else if ([[object objectForKey:@"__type"] isEqualToString:@"Pointer"]) {
                [dict setValue:@"Pointer" forKey:@"__type"];
                [dict setValue:[object objectForKey:@"className"] forKey:@"className"];
                [dict setValue:[object objectForKey:@"_id"] forKey:@"_id"];
            }
            [_dictionary setValue:dict forKey:key];
        }
    }
}


- (NSMutableDictionary *)dictionaryForObject {
    return _dictionary;
}

- (void)removeObjectForKey:(NSString *)key {
    [_dictionary removeObjectForKey:key];
}

- (void)removeAllObjects {
    [_dictionary removeAllObjects];
}

- (id)objectForKey:(NSString *)key {
    return [_dictionary objectForKey:key];
}


#pragma mark - save,fetch, delete

- (BOOL)save:(NSError *__autoreleasing *)error {
    
    if (!_className) {
        if (error) {
            *error = [NSError errorWithDomain:@"without className" code:JBError_NO_CLASSNAME userInfo:@{NSLocalizedDescriptionKey:@"without className"}];
        }
        return NO;
    }
    NSString *urlPath;
    if (_objectId) {
        urlPath = [JBInterface getInterfaceWithPragma:@{@"className":_className,@"_id":_objectId}];
        id responseObject = [HttpRequestManager synchronousWithMethod:@"PUT" urlString:urlPath parameters:_dictionary error:error];
        if (error) {
            if (*error) {
                return NO;
            }
        }
        if (responseObject) {
            int code = [[responseObject objectForKey:@"code"] intValue];
            NSString *message = [responseObject objectForKey:@"message"];
            if (code != 0 && message) {
                if (error) {
                    *error = [NSError errorWithDomain:message code:code userInfo:@{NSLocalizedDescriptionKey:message}];
                }
                return NO;
            }
            return YES;
        }else {
            return NO;
        }
    }else {
        urlPath = [JBInterface getInterfaceWithPragma:@{@"className":_className}];
        id responseObject = [HttpRequestManager synchronousWithMethod:@"POST" urlString:urlPath parameters:_dictionary error:error];
        if (error) {
            if (*error) {
                return NO;
            }
        }
        if (responseObject) {
            int code = [[responseObject objectForKey:@"code"] intValue];
            NSString *message = [responseObject objectForKey:@"message"];
            if (code != 0 && message) {
                if (error) {
                    *error = [NSError errorWithDomain:message code:code userInfo:@{NSLocalizedDescriptionKey:message}];
                }
                return NO;
            }
            NSDictionary *dictionary = [responseObject objectForKey:@"data"];
            if (dictionary) {
                self.objectId = [dictionary objectForKey:@"_id"];
            }
            return YES;
        }else {
            return NO;
        }
        
    }
}

- (void)saveInBackgroundWithBlock:(JBBooleanResultBlock)block {
    if (!_className) {
        NSError *error = [NSError errorWithDomain:@"without className" code:JBError_NO_CLASSNAME userInfo:@{NSLocalizedDescriptionKey:@"without className"}];
        block(NO, error);
        return ;
    }
    NSString *urlPath;
    if (_objectId) {
        //更新
        urlPath = [JBInterface getInterfaceWithPragma:@{@"className":_className, @"_id":_objectId}];
        [HttpRequestManager updateObjectWithUrlPath:urlPath parameters:_dictionary success:^(AFHTTPRequestOperation *operation, id responseObject) {
            block(YES, nil);
        } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
            if (operation.responseObject) {
                int code = [[operation.responseObject objectForKey:@"code"] intValue];
                NSError *customError = [NSError errorWithDomain:[operation.responseObject objectForKey:@"message"] code:code userInfo:operation.responseObject];
                block(NO, customError);
            }else {
                block(NO, error);
            }
        }];
    }else {
        urlPath = [JBInterface getInterfaceWithPragma:@{@"className":_className}];
        [HttpRequestManager postObjectWithoutDataWithUrlPath:urlPath parameters:_dictionary success:^(AFHTTPRequestOperation *operation, id responseObject) {
            NSDictionary *dictionary = [responseObject objectForKey:@"data"];
            if (dictionary) {
                self.objectId = [dictionary objectForKey:@"_id"];
            }
            block(YES, nil);
        } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
            if (operation.responseObject) {
                int code = [[operation.responseObject objectForKey:@"code"] intValue];
                NSError *customError = [NSError errorWithDomain:[operation.responseObject objectForKey:@"message"] code:code userInfo:operation.responseObject];
                block(NO, customError);
            }else {
                block(NO, error);
            }
        }];
    }
    
    
}

- (JBObject *)fetch:(NSError *__autoreleasing *)error {
    if (!_objectId) {
        if (error) {
            *error = [NSError errorWithDomain:@"without id" code:JBError_NO_CLASSNAME userInfo:@{NSLocalizedDescriptionKey:@"without id"}];
        }
        return nil;
    }
    
    if (!_className) {
        if (error) {
            *error = [NSError errorWithDomain:@"without className" code:JBError_NO_CLASSNAME userInfo:@{NSLocalizedDescriptionKey:@"without className"}];
        }
        return nil;
    }
    NSString *urlPath = [NSString stringWithFormat:@"object/%@/%@", _className, _objectId];
    id responseObject = [HttpRequestManager synchronousWithMethod:@"GET" urlString:urlPath parameters:_dictionary error:error];
    if (error) {
        if (*error) {
            return nil;
        }
    }
    if (responseObject) {
        int code = [[responseObject objectForKey:@"code"] intValue];
        NSString *message = [responseObject objectForKey:@"message"];
        if (code != 0 && message) {
            if (error) {
                *error = [NSError errorWithDomain:message code:code userInfo:@{NSLocalizedDescriptionKey:message}];
            }
            return nil;
        }
        return [[JBObject alloc] initWithDictionary:responseObject];
    }else {
        return nil;
    }
}

- (void)fetchInBackgroundWithBlock:(JBObjectResultBlock)block {
    if (!_objectId) {
        NSError *error = [NSError errorWithDomain:@"without id" code:JBError_NO_CLASSNAME userInfo:@{NSLocalizedDescriptionKey:@"without id"}];
        block(nil, error);
        return;
    }
    if (!_className) {
        NSError *error = [NSError errorWithDomain:@"without className" code:JBError_NO_CLASSNAME userInfo:@{NSLocalizedDescriptionKey:@"without className"}];
        block(nil, error);
        return;
    }
    NSString *urlPath = [JBInterface getInterfaceWithPragma:@{@"className":_className, @"_id":_objectId}];
    [HttpRequestManager getObjectWithUrlPath:urlPath parameters:nil success:^(AFHTTPRequestOperation *operation, id responseObject) {
        JBObject *object = [[JBObject alloc] initWithDictionary:responseObject];
        block(object, nil);
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

- (BOOL)delete:(NSError *__autoreleasing *)error {
    if (!_objectId) {
        if (error) {
            *error = [NSError errorWithDomain:@"without id" code:JBError_NO_CLASSNAME userInfo:@{NSLocalizedDescriptionKey:@"without id"}];
        }
        
        return NO;
    }
    if (!_className) {
        if (error) {
            *error = [NSError errorWithDomain:@"without className" code:JBError_NO_CLASSNAME userInfo:@{NSLocalizedDescriptionKey:@"without className"}];
        }
        
        return NO;
    }
    NSString *urlPath = [JBInterface getInterfaceWithPragma:@{@"className":_className, @"_id":_objectId}];
    id responseObject = [HttpRequestManager synchronousWithMethod:@"DELETE" urlString:urlPath parameters:_dictionary error:error];
    if (error) {
        if (*error) {
            return NO;
        }
    }
    if (responseObject) {
        int code = [[responseObject objectForKey:@"code"] intValue];
        NSString *message = [responseObject objectForKey:@"message"];
        if (code != 0 && message) {
            if (error) {
                *error = [NSError errorWithDomain:message code:code userInfo:@{NSLocalizedDescriptionKey:message}];
            }
            return NO;
        }
        return YES;
    }else {
        return YES;
    }
}

- (void)deleteInBackgroundWithBlock:(JBBooleanResultBlock)block {
    if (!_objectId) {
        NSError *error = [NSError errorWithDomain:@"without id" code:JBError_NO_CLASSNAME userInfo:@{NSLocalizedDescriptionKey:@"without id"}];
        block(NO, error);
        return;
    }
    
    if (!_className) {
        NSError *error = [NSError errorWithDomain:@"without className" code:JBError_NO_CLASSNAME userInfo:@{NSLocalizedDescriptionKey:@"without className"}];
        block(NO, error);
        return;
    }
    NSString *urlPath = [JBInterface getInterfaceWithPragma:@{@"className":_className, @"_id":_objectId}];
    [HttpRequestManager deleteObjectWithUrlPath:urlPath queryParam:nil success:^(AFHTTPRequestOperation *operation, id responseObject) {
        block(YES, nil);
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        if (operation.responseObject) {
            int code = [[operation.responseObject objectForKey:@"code"] intValue];
            NSError *customError = [NSError errorWithDomain:[operation.responseObject objectForKey:@"message"] code:code userInfo:operation.responseObject];
            block(NO, customError);
        }else {
            block(NO, error);
        }
    }];
}



@end















