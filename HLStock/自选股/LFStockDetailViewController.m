//
//  LFStockDetailViewController.m
//  HLStock
//
//  Created by qzp on 14/11/22.
//  Copyright (c) 2014年 HuiLian. All rights reserved.
//

#import "LFStockDetailViewController.h"

@interface LFStockDetailViewController ()

@property (nonatomic)   NSString        *stockCode;
@property (nonatomic)   NSDictionary    *stockData;
@property (nonatomic)   UIImageView     *stockImageView;

@end

@implementation LFStockDetailViewController

- (instancetype)initWithdata:(NSDictionary *)data
{
    self = [super init];
    if (self) {
        self.stockData = data;
        self.stockCode = [data allKeys][0];
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.title = [_stockData allValues][0][0];
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"刷新" style:UIBarButtonItemStylePlain target:self action:@selector(onRefreshAction:)];
    
    self.stockImageView = [[UIImageView alloc] initWithFrame:self.view.bounds];
    [self.view addSubview:_stockImageView];
    
    [self requestStockGraphic];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewDidLayoutSubviews
{
    [super viewDidLayoutSubviews];
    
    _stockImageView.size = CGSizeMake(self.view.width, 200);
    _stockImageView.centerX = self.view.width/2;
    _stockImageView.bottom = self.view.bottom;
}

- (void)onRefreshAction:(id)sender
{
    [self requestStockGraphic];
}

- (BOOL)shouldAutorotate
{
    return YES;
}

- (NSUInteger)supportedInterfaceOrientations
{
    return UIInterfaceOrientationMaskAllButUpsideDown;
}

#pragma mark - Private

- (void)requestStockGraphic
{
    [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:YES];
    [LFClientApi requestStockGraphic:_stockCode success:^(AFHTTPRequestOperation *operation, id responseObject) {
        self.stockImageView.image = responseObject;
        [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
    } cachedData:^(id responseObject) {
        self.stockImageView.image = responseObject;
    }];
}

@end
