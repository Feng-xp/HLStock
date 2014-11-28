//
//  LFClientApi.h
//  HLStock
//
//  Created by qzp on 14/11/22.
//  Copyright (c) 2014年 HuiLian. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "AFNetworking.h"

@interface LFClientApi : NSObject

//  获取股票数据
+ (void)requestStockData:(NSString *)stockCode
                    success:(void (^)(AFHTTPRequestOperation *operation, id responseObject))success
                    failure:(void (^)(AFHTTPRequestOperation *operation, NSError *error))failure
                 cachedData:(void (^)(id responseObject))cachedData;

//  获取股票K线图
+ (void)requestStockGraphic:(NSString *)stockCode
                   success:(void (^)(AFHTTPRequestOperation *operation, id responseObject))success
                   failure:(void (^)(AFHTTPRequestOperation *operation, NSError *error))failure
                cachedData:(void (^)(id responseObject))cachedData;

@end
