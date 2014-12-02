//
//  TodayViewController.m
//  HLStockExtension
//
//  Created by qzp on 14/11/10.
//  Copyright (c) 2014年 HuiLian. All rights reserved.
//

#import "TodayViewController.h"
#import <NotificationCenter/NotificationCenter.h>
#import "HLStockViewCell.h"

#define BASE_URL                @"http://hq.sinajs.cn/list="
#define TABLEVIEW_CELL_HEIGHT   34
#define STOCK_LIST_KEY          @"stockList"
#define STOCK_DATA_KEY          @"stockData"

@interface TodayViewController () <NCWidgetProviding,UITableViewDelegate,UITableViewDataSource,NSURLConnectionDelegate>

@property (nonatomic)   UITableView *tableView;

@property (nonatomic)   NSArray             *stockList;
@property (nonatomic)   NSMutableDictionary *stockData;

@property (nonatomic)   NSURLConnection *connection;
@property (nonatomic)   NSMutableData   *receivedData;

@property (nonatomic,copy)  void (^completionHandler)(NCUpdateResult);

@end

@implementation TodayViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    
    _tableView = [[UITableView alloc] initWithFrame:self.view.bounds style:UITableViewStylePlain];
    _tableView.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;
    _tableView.delegate = self;
    _tableView.dataSource = self;
    _tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    
    [_tableView registerClass:[HLStockViewCell class] forCellReuseIdentifier:@"HLStockViewCell"];
    [self.view addSubview:_tableView];
    
    UIView *tapView = [[UIView alloc] initWithFrame:self.view.bounds];
    tapView.backgroundColor = [UIColor clearColor];
    tapView.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;
    [self.view addSubview:tapView];
    UITapGestureRecognizer *tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(onTapAction:)];
    [tapView addGestureRecognizer:tapGesture];
    
    NSUserDefaults *userDefaults = [[NSUserDefaults alloc] initWithSuiteName:@"group.com.feng.stock"];
    NSArray *data = [userDefaults objectForKey:STOCK_LIST_KEY];
    self.stockList = [NSArray arrayWithArray:data];
    
    NSDictionary *dict = [userDefaults objectForKey:STOCK_DATA_KEY];
    self.stockData = [[NSDictionary dictionaryWithDictionary:dict] mutableCopy];
}

#pragma mark - UITableViewDelegae && UITableViewDataSource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [_stockList count];
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return TABLEVIEW_CELL_HEIGHT;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    HLStockViewCell *cell = (HLStockViewCell *)[tableView dequeueReusableCellWithIdentifier:@"HLStockViewCell"];
    [cell loadData:[_stockData dictionaryWithValuesForKeys:@[_stockList[indexPath.row]]]];
    return cell;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)receivedAdditionalContent {
    self.preferredContentSize = CGSizeMake(self.view.frame.size.width, TABLEVIEW_CELL_HEIGHT * [_stockList count]);
}

- (void)widgetPerformUpdateWithCompletionHandler:(void (^)(NCUpdateResult))completionHandler {
    // Perform any setup necessary in order to update the view.
    
    // If an error is encountered, use NCUpdateResultFailed
    // If there's no update required, use NCUpdateResultNoData
    // If there's an update, use NCUpdateResultNewData
    
    //step 1:请求地址
    NSMutableString *urlString = [NSMutableString stringWithString:BASE_URL];
    NSString *stockStr = [_stockList componentsJoinedByString:@","];
    [urlString appendString:stockStr];
    NSURL *url = [NSURL URLWithString:urlString];
    
    //step 2:实例化一个request
    NSURLRequest *requrst = [NSURLRequest requestWithURL:url cachePolicy:NSURLRequestUseProtocolCachePolicy timeoutInterval:10.0];
    //step 3：创建链接
    self.connection = [[NSURLConnection alloc] initWithRequest:requrst delegate:self];
    
    self.completionHandler = completionHandler;
}

- (UIEdgeInsets)widgetMarginInsetsForProposedMarginInsets:(UIEdgeInsets)defaultMarginInsets
{
    return UIEdgeInsetsMake(0, 20, 0, 5);
}

#pragma mark-
#pragma NSUrlConnectionDelegate methods
- (void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response
{
    //接受一个服务端回话，再次一般初始化接受数据的对象
    self.receivedData = [[NSMutableData alloc] init];
}

- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data
{
    //接受返回数据，这个方法可能会被调用多次，因此将多次返回数据加起来
    [_receivedData appendData:data];
}

- (void)connectionDidFinishLoading:(NSURLConnection *)connection
{
    NSStringEncoding gbkEncoding =CFStringConvertEncodingToNSStringEncoding(kCFStringEncodingGB_18030_2000);
    NSString *asyReturn = [[NSString alloc] initWithData:_receivedData encoding:gbkEncoding];
    [self receivedAdditionalContent];
    if (self.completionHandler) {
        NSArray *stockArray = [asyReturn componentsSeparatedByString:@";"];
        for (NSInteger index = 0; index < [stockArray count] - 1; index ++) {
            NSString *string = [stockArray[index] componentsSeparatedByString:@"="][1];
            string = [string substringWithRange:NSMakeRange(1, [string length] - 2)];
            [_stockData setObject:[string componentsSeparatedByString:@","] forKey:_stockList[index]];
        }
        [self.tableView reloadData];
        self.completionHandler(NCUpdateResultNewData);
    }
}

- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error
{
    [self receivedAdditionalContent];
    if (self.completionHandler) {
        self.completionHandler(NCUpdateResultFailed);
    }
}

- (void)dealloc
{
    self.connection = nil;
}

#pragma mark - Private

- (void)onTapAction:(UITapGestureRecognizer *)gesture
{
    if (gesture.state == UIGestureRecognizerStateEnded) {
        [self openURLContainingAPP];
    }
}

- (void)openURLContainingAPP
{
    [self.extensionContext openURL:[NSURL URLWithString:@"LFStock://"]
                 completionHandler:^(BOOL success) {
                     NSLog(@"open url result:%d",success);
                 }];
}

@end
