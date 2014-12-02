//
//  LFStorageManager.m
//  HLStock
//
//  Created by qzp on 14/11/22.
//  Copyright (c) 2014年 HuiLian. All rights reserved.
//

#import "LFStorageManager.h"

#define STOCK_LIST_KEY  @"stockList"
#define STOCK_DATA_KEY  @"stockData"

static LFStorageManager *instance;

@implementation LFStorageManager

+ (instancetype)shareInstance
{
    static dispatch_once_t once;
    dispatch_once(&once, ^{
        instance = [[LFStorageManager alloc] init];
    });
    return instance;
}

- (void)save
{
    NSUserDefaults *userDefaults = [[NSUserDefaults alloc] initWithSuiteName:@"group.com.feng.stock"];
    [userDefaults setObject:_stockList forKey:STOCK_LIST_KEY];
    [userDefaults setObject:_stockData forKey:STOCK_DATA_KEY];
    [userDefaults synchronize];
}

- (void)load
{
    NSUserDefaults *userDefaults = [[NSUserDefaults alloc] initWithSuiteName:@"group.com.feng.stock"];
    NSArray *data = [userDefaults objectForKey:STOCK_LIST_KEY];
    self.stockList = [NSArray arrayWithArray:data];
    
    NSDictionary *dict = [userDefaults objectForKey:STOCK_DATA_KEY];
    self.stockData = [NSDictionary dictionaryWithDictionary:dict];
}

@end
