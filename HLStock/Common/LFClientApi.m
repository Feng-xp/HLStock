//
//  LFClientApi.m
//  HLStock
//
//  Created by qzp on 14/11/22.
//  Copyright (c) 2014年 HuiLian. All rights reserved.
//

#import "LFClientApi.h"

#define API_BASE_URL    @"http://hq.sinajs.cn/list="
#define API_IMAGE_URL   @"http://image.sinajs.cn/"

@implementation LFClientApi

+ (AFHTTPRequestOperationManager *)manager
{
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    AFHTTPResponseSerializer *jsonSerializer = [AFHTTPResponseSerializer serializer];
    manager.responseSerializer = jsonSerializer;
    return manager;
}

+ (id)cachedDataForUrlString:(NSString *)urlString withManager:(AFHTTPRequestOperationManager *)manager parameters:(NSDictionary *)parameters
{
    NSMutableURLRequest *request = [manager.requestSerializer requestWithMethod:@"GET" URLString:[[NSURL URLWithString:urlString relativeToURL:nil] absoluteString] parameters:parameters error:nil];
    NSCachedURLResponse* cachedResponse = [[NSURLCache sharedURLCache] cachedResponseForRequest:request];
    id responseObject = [manager.responseSerializer responseObjectForResponse:cachedResponse.response data:cachedResponse.data error:nil];
    return responseObject;
}

+ (void)requestStockData:(NSString *)stockCode
                 success:(void (^)(AFHTTPRequestOperation *operation, id responseObject))success
                 failure:(void (^)(AFHTTPRequestOperation *operation, NSError *error))failure
              cachedData:(void (^)(id responseObject))cachedData
{
    AFHTTPRequestOperationManager *manager = [LFClientApi manager];
    
    NSString *urlString = [NSString stringWithFormat:@"%@%@",API_BASE_URL,stockCode];
    [manager GET:urlString parameters:nil success:^(AFHTTPRequestOperation *operation, id responseObject) {
        if (success) {
            success(operation,responseObject);
        }
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        if (failure) {
            failure(operation, error);
        }
    }];
    
    if (cachedData) {
        id responseObject = [LFClientApi cachedDataForUrlString:urlString withManager:manager parameters:nil];
        if (responseObject) {
            cachedData(responseObject);
        }
    }
}

+ (void)requestStockGraphic:(NSString *)stockCode
                    success:(void (^)(AFHTTPRequestOperation *operation, id responseObject))success
                    failure:(void (^)(AFHTTPRequestOperation *operation, NSError *error))failure
                 cachedData:(void (^)(id responseObject))cachedData
{
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    AFImageResponseSerializer *imageSerializer = [AFImageResponseSerializer serializer];
    manager.responseSerializer = imageSerializer;
    
    NSString *urlString = [NSString stringWithFormat:@"%@%@%@.gif",API_IMAGE_URL,@"newchart/daily/n/",stockCode];
    
    [manager GET:urlString parameters:nil success:^(AFHTTPRequestOperation *operation, id responseObject) {
        if (success) {
            success(operation,responseObject);
        }
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        if (failure) {
            failure(operation, error);
        }
    }];
    
    if (cachedData) {
        id responseObject = [LFClientApi cachedDataForUrlString:urlString withManager:manager parameters:nil];
        if (responseObject) {
            cachedData(responseObject);
        }
    }
}

@end
