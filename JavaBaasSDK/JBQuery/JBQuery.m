//
//  JBQuery.m
//  LeanCloud_Test
//
//  Created by zhaopeng on 15/9/23.
//  Copyright © 2015年 zhaopeng. All rights reserved.
//

#import "JBQuery.h"
#import "JBInterface.h"
#import "JBUser.h"
#import "HttpRequestManager.h"

@implementation JBQuery


+ (JBQuery *)queryWithClassName:(NSString *)className {
    JBQuery *query = [[JBQuery alloc] init];
    query.className = className;
    return query;
}

- (instancetype)init
{
    self = [super init];
    if (self) {
        self.paramDictionary = [NSMutableDictionary dictionary];
        self.dictionary = [[NSMutableDictionary alloc] init];
        self.orMutableString = [NSMutableString string];
        self.inQueryMutableString = [NSMutableString string];
        self.orderKeyDictionary = [NSMutableDictionary dictionary];
        self.orderKeyArray = [NSMutableArray array];
    }
    return self;
}

//翻译约束条件
- (NSMutableDictionary *)getQueryConditions {
    NSMutableString *whereString = [NSMutableString string];
    NSArray *keyArray_1 = [_dictionary allKeys];
    for (int i=0; i<keyArray_1.count; i++) {
        if (i == 0) {
            [whereString appendString:@"\"$and\":["];
        }
        NSString *key_1 = [keyArray_1 objectAtIndex:i];
        NSMutableDictionary *dict_1 = [_dictionary objectForKey:key_1];
        NSArray *keyArray_2 = [dict_1 allKeys];
        for (int j=0; j<keyArray_2.count; j++) {
            NSString *key_2 = [keyArray_2 objectAtIndex:j];
            NSString *value_2 = [dict_1 objectForKey:key_2];
            [whereString appendString:[NSString stringWithFormat:@"{\"%@\":%@},", key_1, value_2]];
        }
    }
    
    if (whereString.length) {
        if (self.orMutableString.length) {
            [whereString appendString:[NSString stringWithFormat:@"{%@}]",self.orMutableString]];
        }else {
            [whereString replaceCharactersInRange:NSMakeRange(whereString.length-1, 1) withString:@"]"];
        }
        if (self.inQueryMutableString.length) {
            NSArray *array = [self.inQueryMutableString componentsSeparatedByString:@"$*&"];
            [whereString appendString:@","];
            [whereString appendString:[NSString stringWithFormat:@"\"%@\":{%@}", [array objectAtIndex:1], [array objectAtIndex:0]]];
        }
    }else {
        if (self.orMutableString.length) {
            [whereString appendString:[NSString stringWithFormat:@"%@",self.orMutableString]];
        }
        if (self.inQueryMutableString.length) {
            NSArray *array = [self.inQueryMutableString componentsSeparatedByString:@"$*&"];
            [whereString appendString:@","];
            [whereString appendString:[NSString stringWithFormat:@"\"%@\":{%@}", [array objectAtIndex:1], [array objectAtIndex:0]]];
        }
    }
    if (whereString.length) {
        [self.paramDictionary setValue:[NSString stringWithFormat:@"{%@}",whereString] forKey:@"where"];
    }
    
    if (self.orderKeyArray.count) {
        NSMutableString *mutableOrderString = [NSMutableString string];
        for (NSString *keyStr in self.orderKeyArray) {
            NSString *orderStr = [NSString stringWithFormat:@"\"%@\":%@,", keyStr, [self.orderKeyDictionary objectForKey:keyStr]];
            [mutableOrderString appendString:orderStr];
        }
        [mutableOrderString deleteCharactersInRange:NSMakeRange(mutableOrderString.length-1, 1)];
        [_paramDictionary setValue:[NSString stringWithFormat:@"{%@}", mutableOrderString] forKey:@"order"];
    }
    
    return self.paramDictionary;
}


- (id)findObjects:(NSError *__autoreleasing *)error {
    NSMutableDictionary *param = [self getQueryConditions];
    NSError *tempError = [self checkClassName];
    if (tempError) {
        if (error) {
            *error = tempError;
        }
        return nil;
    }
    
    if (self.className) {
        NSString *urlPath = [JBInterface getInterfaceWithParam:@{@"className":self.className, @"find":@(YES)}];
        id responseObject = [HttpRequestManager synchronousWithMethod:@"GET" urlString:urlPath parameters:param error:error];
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
        NSArray *jsonArray = (NSArray *)responseObject;
        NSMutableArray *mutableArray = [NSMutableArray arrayWithCapacity:jsonArray.count];
        for (NSDictionary *dict in jsonArray) {
            JBObject *object = [[JBObject alloc] initWithDictionary:dict];
            [mutableArray addObject:object];
        }
        NSArray *array = [NSArray arrayWithArray:mutableArray];
        return array;
    }else {
        if (error) {
            *error = [self checkClassName];;
        }
        return nil;
    }
}

- (void)findObjectsInBackgroundWithBlock:(JBArrayResultBlock)block {
    NSError *error = [self checkClassName];
    if (error) {
        block(nil, error);
        return ;
    }
    NSMutableDictionary *param = [self getQueryConditions];
    
    NSString *urlPath = [JBInterface getInterfaceWithParam:@{@"className":self.className, @"find":@(YES)}];
    
    [HttpRequestManager queryObjectWithUrlPath:urlPath queryParam:param success:^(AFHTTPRequestOperation *operation, id responseObject) {
        BOOL temp = NO;
        NSMutableArray *mutableArray;
        @try {
            NSArray *jsonArray = (NSArray *)responseObject;
            mutableArray = [NSMutableArray arrayWithCapacity:jsonArray.count];
            for (NSDictionary *dict in jsonArray) {
                JBObject *object = [[JBObject alloc] initWithDictionary:dict];
                [mutableArray addObject:object];
            }
        }
        @catch (NSException *exception) {
            temp = YES;
        }
        @finally {
            if (temp) {
                block(nil, [NSError errorWithDomain:@"缓存出错" code:9000 userInfo:@{@"code":@(9000), @"domain":@"缓存出错"}]);
            }else {
                block([NSArray arrayWithArray:mutableArray], nil);
            }
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

+ (JBUser *)getUserObjectWithId:(NSString *)objectId error:(NSError *__autoreleasing *)error {
    JBQuery *query = [JBQuery queryWithClassName:@"_User"];
    NSMutableDictionary *param = [query getQueryConditions];
    NSString *urlPath = [JBInterface getInterfaceWithParam:@{@"className":@"_User", @"_id":objectId,@"find":@(YES)}];
    id responseObject = [HttpRequestManager synchronousWithMethod:@"GET" urlString:urlPath parameters:param error:error];
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
        return [[JBUser alloc] initWithDictionary:responseObject];
    }else {
        return nil;
    }
    
}

+ (JBObject *)getObjectOfClass:(NSString *)objectClass objectId:(NSString *)objectId error:(NSError *__autoreleasing *)error {
    JBQuery *query = [JBQuery queryWithClassName:objectClass];
    query.className = objectClass;
    NSError *tempError = [query checkClassName];
    if (tempError) {
        if (error) {
            *error = tempError;
        }
        return nil;
    }
    NSMutableDictionary *param = [query getQueryConditions];
    NSString *urlPath = [JBInterface getInterfaceWithParam:@{@"className":query.className, @"_id":objectId,@"find":@(YES)}];
    id responseObject = [HttpRequestManager synchronousWithMethod:@"GET" urlString:urlPath parameters:param error:error];
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


- (void)getObjectInBackgroundWithId:(NSString *)objectId block:(JBObjectResultBlock)block {
    NSError *error = [self checkClassName];
    if (error) {
        block(nil, error);
        return ;
    }
    NSMutableDictionary *param = [self getQueryConditions];
    NSString *urlPath = [JBInterface getInterfaceWithParam:@{@"className":self.className, @"_id":objectId,@"find":@(YES)}];
    [HttpRequestManager getObjectWithUrlPath:urlPath parameters:param success:^(AFHTTPRequestOperation *operation, id responseObject) {
        NSDictionary *dict = responseObject;
        JBObject *object = [[JBObject alloc] initWithDictionary:dict];
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


- (NSInteger)countObjects:(NSError *__autoreleasing *)error {
    NSError *tempError = [self checkClassName];
    if (tempError) {
        if (error) {
            *error = tempError;
        }
        return 0;
    }
    NSMutableDictionary *param = [self getQueryConditions];
    NSString *urlPath = [JBInterface getInterfaceWithParam:@{@"className":[NSString stringWithFormat:@"%@/count", self.className]}];
    id responseObject = [HttpRequestManager synchronousWithMethod:@"GET" urlString:urlPath parameters:param error:error];
    if (error) {
        if (*error) {
            return 0;
        }
    }
    int code = [[responseObject objectForKey:@"code"] intValue];
    NSString *message = [responseObject objectForKey:@"message"];
    if (code != 0 && message) {
        if (error) {
            *error = [NSError errorWithDomain:message code:code userInfo:@{NSLocalizedDescriptionKey:message}];
        }
        return 0;
    }
    return [[[responseObject objectForKey:@"data"] objectForKey:@"count"] integerValue];
}

- (void)countObjectsInBackgroundWithBlock:(JBIntegerResultBlock)block {
    NSError *error = [self checkClassName];
    if (error) {
        block(0, error);
        return ;
    }
    NSMutableDictionary *param = [self getQueryConditions];
    NSString *urlPath = [JBInterface getInterfaceWithParam:@{@"className":[NSString stringWithFormat:@"%@/count", self.className]}];
    [HttpRequestManager queryObjectWithUrlPath:urlPath queryParam:param success:^(AFHTTPRequestOperation *operation, id responseObject) {
        NSInteger count = [[[responseObject objectForKey:@"data"] objectForKey:@"count"] integerValue];
        block(count, nil);
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        block(0, error);
    }];
}


//
- (void)deleteAllInBackgroundWithBlock:(JBBooleanResultBlock)block {
    NSError *error = [self checkClassName];
    if (error) {
        block(NO, error);
        return ;
    }
    NSMutableDictionary *param = [self getQueryConditions];
    NSString *urlPath = [JBInterface getInterfaceWithParam:@{@"className":[NSString stringWithFormat:@"%@/deleteByQuery", self.className]}];
    [HttpRequestManager deleteObjectWithUrlPath:urlPath queryParam:param success:^(AFHTTPRequestOperation *operation, id responseObject) {
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


- (NSError *)checkClassName {
    if (!self.className) {
        NSError *error = [NSError errorWithDomain:@"without className" code:JBError_NO_CLASSNAME userInfo:@{NSLocalizedDescriptionKey:@"without className"}];
        return error;
    }
    return nil;
    
}



#pragma mark query

- (void) queryAssertValidEqualityClauseClass:(id)object {
    static NSArray *classes;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        classes = @[[NSString class], [NSNumber class], [NSDate class], [NSNull class],[NSArray class], [NSObject class], [JBObject class], [NSDictionary class]];
    });
    
    for (Class class in classes) {
        if ([object isKindOfClass:class]) {
            return;
        }
    }
    NSAssert(0, @"参数类型不匹配");
}

- (void)checksupportClass:(id)value {
    NSAssert(![value isKindOfClass:[JBObject class]], @"参数传入类型错误,[JBObject class]不支持");
}


- (NSString *)getWhereString:(id)value {
    NSString *string;
    if ([value isKindOfClass:[NSNumber class]]) {
        NSNumber *num = (NSNumber *)value;
        if ([num isKindOfClass:NSClassFromString(@"__NSCFBoolean")]) {
            if (num.boolValue) {
                string = @"true";
            }else {
                string = @"false";
            }
        }else {
            string = [NSString stringWithFormat:@"%@", value];
        }
        
    }else if ([value isKindOfClass:[NSArray class]]) {
        NSArray *array = (NSArray *)value;
        NSMutableString *mutableString = [[NSMutableString alloc] init];
        for (int i=0; i<array.count; i++) {
            id obj = [array objectAtIndex:i];
            NSString *str = [self getWhereString:obj];
            [mutableString appendString:[NSString stringWithFormat:@"%@",str]];
            if (i != array.count-1) {
                [mutableString appendString:@","];
            }
        }
        string = [NSString stringWithFormat:@"[%@]", mutableString];
    }else if ([value isKindOfClass:[JBObject class]]) {
        NSDictionary *dict = [value dictionaryForObject];
        NSString *objectIdString = [dict objectForKey:@"_id"];
        NSString *className = [dict objectForKey:@"className"];
        string = [NSString stringWithFormat:@"{\"__type\":\"Pointer\",\"className\":\"%@\",\"_id\":\"%@\"}",className, objectIdString];
        
    }else if ([value isKindOfClass:[NSDictionary class]]){
        NSDictionary *dict = (NSDictionary *)value;
        NSMutableString *mutableString = [NSMutableString string];
        for (int i=0;i<[dict allKeys].count; i++) {
            NSString *keyString = [[dict allKeys] objectAtIndex:i];
            NSString *value_id = [dict objectForKey:keyString];
            [mutableString appendString:[NSString stringWithFormat:@"\"%@\":\"%@\"", keyString, value_id]];
            if (i != [dict allKeys].count-1) {
                [mutableString appendString:@","];
            }
        }
        string = [NSString stringWithString:[NSString stringWithFormat:@"{%@}", mutableString]];
    }else if ([value isKindOfClass:[NSDate class]]) {
        NSDate *date = (NSDate *)value;
        long long time = (long long)(date.timeIntervalSince1970*1000);
        string = [NSString stringWithFormat:@"%lld", time];
    }else {
        if ([value isEqualToString:@"true"] || [value isEqualToString:@"false"]) {
            string = [NSString stringWithFormat:@"%@",value];
        }else {
            string = [NSString stringWithFormat:@"\"%@\"",value];
        }
    }
    return string;
}



- (void)coverConditions:(NSString *)key value:(NSString *)string keyValue2:(NSString *)key2 {
    NSMutableDictionary *dict_1 = [_dictionary objectForKey:key];
    if (!dict_1) {
        dict_1 = [[NSMutableDictionary alloc] init];
    }
    [dict_1 setObject:string forKey:key2];
    [_dictionary setObject:dict_1 forKey:key];
}

- (void)whereKey:(NSString *)key equalTo:(id)value {
    [self queryAssertValidEqualityClauseClass:value];
    NSString *string = [self getWhereString:value];
    [self coverConditions:key value:string keyValue2:@"equal"];
}

- (void)whereKeyExists:(NSString *)key {
    NSString *string = [NSString stringWithFormat:@"{\"$exists\":%@}", @"true" ];
    [self coverConditions:key value:string keyValue2:@"$exists"];
    
}

- (void)whereKeyDoesNotExist:(NSString *)key {
    NSString *string = [NSString stringWithFormat:@"{\"$exists\":%@}", @"false" ];
    [self coverConditions:key value:string  keyValue2:@"$exists"];
}


- (void)whereKey:(NSString *)key notEqualTo:(id)value {
    [self queryAssertValidEqualityClauseClass:value];
    NSString *string = [NSString stringWithFormat:@"{\"$ne\":%@}", [self getWhereString:value]];
    [self coverConditions:key value:string  keyValue2:@"equal"];
}


- (void)whereKey:(NSString *)key lessThan:(id)value {
    [self queryAssertValidEqualityClauseClass:value];
    [self checksupportClass:value];
    NSString *string = [NSString stringWithFormat:@"{\"$lt\":%@}", [self getWhereString:value]];
    [self coverConditions:key value:string  keyValue2:@"$lt"];
}

- (void)whereKey:(NSString *)key greaterThan:(id)value {
    [self queryAssertValidEqualityClauseClass:value];
    [self checksupportClass:value];
    NSString *string = [NSString stringWithFormat:@"{\"$gt\":%@}", [self getWhereString:value]];
    [self coverConditions:key value:string keyValue2:@"$gt"];
}


- (void)whereKey:(NSString *)key lessThanOrEqualTo:(id)value {
    [self queryAssertValidEqualityClauseClass:value];
    [self checksupportClass:value];
    NSString *string = [NSString stringWithFormat:@"{\"$lte\":%@}", [self getWhereString:value]];
    [self coverConditions:key value:string  keyValue2:@"$lte"];
}


- (void)whereKey:(NSString *)key greaterThanOrEqualTo:(id)value {
    [self queryAssertValidEqualityClauseClass:value];
    [self checksupportClass:value];
    NSString *string = [NSString stringWithFormat:@"{\"$gte\":%@}", [self getWhereString:value]];
    [self coverConditions:key value:string  keyValue2:@"$gte"];
}

- (void)whereKey:(NSString *)key containedIn:(NSArray *)array {
    NSString *string = [NSString stringWithFormat:@"{\"$in\":%@}", [self getWhereString:array]];
    [self coverConditions:key value:string keyValue2:@"$in"];
}


- (void)whereKey:(NSString *)key notContainedIn:(NSArray *)array {
    NSString *string = [NSString stringWithFormat:@"{\"$nin\":%@}", [self getWhereString:array]];
    [self coverConditions:key value:string keyValue2:@"$nin"];
}


- (void)whereKey:(NSString *)key matchesRegex:(NSString *)regex {
    NSString *string = [NSString stringWithFormat:@"{\"$regex\":\"%@\"}", regex];
    [self coverConditions:key value:string keyValue2:@"$regex"];
}

- (void)whereKey:(NSString *)key matchesRegex:(NSString *)regex modifiers:(NSString *)modifiers {
    NSString *string = [NSString stringWithFormat:@"{\"$regex\":\"%@\",\"$options\":\"%@\"}", regex, modifiers];
    [self coverConditions:key value:string keyValue2:@"$regex"];
}


- (void)whereKey:(NSString *)key containsString:(NSString *)substring {
    NSString *string = [NSString stringWithFormat:@"{\"$regex\":\".*%@.*\"}", substring];
    [self coverConditions:key value:string keyValue2:@"$regex"];
}

- (void)whereKey:(NSString *)key hasPrefix:(NSString *)prefix {
    NSString *string = [NSString stringWithFormat:@"{\"$regex\":\"^%@.*\"}", prefix];
    [self coverConditions:key value:string keyValue2:@"$regex"];
}


- (void)whereKey:(NSString *)key hasSuffix:(NSString *)suffix {
    NSString *string = [NSString stringWithFormat:@"{\"$regex\":\".*%@$\"}", suffix];
    [self coverConditions:key value:string keyValue2:@"$regex"];
}



- (void)whereKey:(NSString *)key matchesQuery:(JBQuery *)query {
    NSString *deleteString = @"{\"$and\":[";
    NSString *tempString = [[query getQueryConditions] objectForKey:@"where"];
    NSMutableString *whereString = [NSMutableString stringWithString:tempString];
    [whereString replaceCharactersInRange:NSMakeRange(0, deleteString.length) withString:@""];
    [whereString replaceCharactersInRange:NSMakeRange(whereString.length-2, 2) withString:@""];
    NSString *string = [NSString stringWithFormat:@"\"$sub\":{\"where\":{\"$and\":[%@]},\"searchClass\":\"%@\"}", whereString, query.className];
    [self.inQueryMutableString appendString:string];
    [self.inQueryMutableString appendString:[NSString stringWithFormat:@"$*&%@", key]];
}


- (void)whereKey:(NSString *)key matchesKey:(NSString *)matchesKey matchesClass:(NSString *)matchesClass inQuery:(JBQuery *)query {
    
    NSString *deleteString = @"{\"$and\":[";
    NSString *tempString = [[query getQueryConditions] objectForKey:@"where"];
    NSMutableString *whereString = [NSMutableString stringWithString:tempString];
    [whereString replaceCharactersInRange:NSMakeRange(0, deleteString.length) withString:@""];
    [whereString replaceCharactersInRange:NSMakeRange(whereString.length-2, 2) withString:@""];
    NSString *string = [NSString stringWithFormat:@"\"$sub\":{\"where\":{\"$and\":[%@]},\"searchClass\":\"%@\",\"targetClass\":\"%@\",\"searchKey\":\"%@\"}", whereString, query.className, matchesClass, matchesKey];
    [self.inQueryMutableString appendString:string];
    [self.inQueryMutableString appendString:[NSString stringWithFormat:@"$*&%@", key]];
    
}

- (void)setLimit:(NSInteger)limit {
    _limit = limit;
    [_paramDictionary setValue:@(limit) forKey:@"limit"];
}

- (void)setSkip:(NSInteger)skip {
    _skip = skip;
    [_paramDictionary setValue:@(skip) forKey:@"skip"];
}

- (void)orderByAscending:(NSString *)key {
    [self.orderKeyDictionary removeAllObjects];
    [self.orderKeyArray removeAllObjects];
    [self.orderKeyArray addObject:key];
    [self.orderKeyDictionary setObject:@(1) forKey:key];
}

- (void)orderByDescending:(NSString *)key {
    [self.orderKeyDictionary removeAllObjects];
    [self.orderKeyArray removeAllObjects];
    [self.orderKeyArray addObject:key];
    [self.orderKeyDictionary setObject:@(-1) forKey:key];
}


- (void)addAscendingOrder:(NSString *)key {
    [self.orderKeyArray removeObject:key];
    [self.orderKeyDictionary setObject:@(1) forKey:key];
    [self.orderKeyArray addObject:key];
}

- (void)addDescendingOrder:(NSString *)key {
    [self.orderKeyArray removeObject:key];
    [self.orderKeyDictionary setObject:@(-1) forKey:key];
    [self.orderKeyArray addObject:key];
}

- (void)includeKey:(NSString *)key {
    NSString *string = [_paramDictionary objectForKey:@"include"];
    NSMutableString *mutableString;
    if (string) {
        mutableString = [NSMutableString stringWithString:string];
    }else {
        mutableString = [NSMutableString string];
    }
    if (mutableString.length) {
        [mutableString appendString:@","];
    }
    [mutableString appendString:[NSString stringWithFormat:@"%@", key]];
    [_paramDictionary setValue:mutableString forKey:@"include"];
}

- (void)setCachePolicy:(kJBCachePolicyCache)cachePolicy {
    [_paramDictionary setValue:@(cachePolicy) forKey:@"JBCachePolicy"];
}


+ (JBQuery *)orQueryWithSubqueries:(NSArray *)array {
    NSAssert(array.count, @"条件为空");
    JBQuery *firstQuery = [array firstObject];
    NSArray *firstArray = [NSArray arrayWithObject:firstQuery.className];
    for (JBQuery *query in array) {
        BOOL ret = [firstArray containsObject:query.className];
        NSAssert(ret, @"参数类型不匹配");
    }
    JBQuery *query = [JBQuery queryWithClassName:firstQuery.className];
    NSMutableString *orMutableString = [NSMutableString string];
    NSString *tempString = @"{\"$and\":[";
    int i =0;
    for (JBQuery *tempQuery in array) {
        if (i == 0) {
            [orMutableString appendString:@"\"$or\":["];
        }
        NSString *string = [[tempQuery getQueryConditions] objectForKey:@"where"];
        NSMutableString *whereString = [NSMutableString stringWithString:string];
        [whereString replaceCharactersInRange:NSMakeRange(0, tempString.length) withString:@""];
        [whereString replaceCharactersInRange:NSMakeRange(whereString.length-2, 2) withString:@""];
        BOOL ret = [whereString containsString:@","];
        if (ret) {
            [orMutableString appendString:[NSString stringWithFormat:@"{\"$and\":[%@]}", whereString]];
            
        }else {
            [orMutableString appendString:[NSString stringWithFormat:@"%@", whereString]];
        }
        [orMutableString appendString:@","];
        i++;
    }
    [orMutableString replaceCharactersInRange:NSMakeRange(orMutableString.length-1, 1) withString:@"]"];
    query.orMutableString = orMutableString;
    return query;
}

@end
























