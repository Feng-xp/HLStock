//
//  ViewController.m
//  HLStock
//
//  Created by qzp on 14/11/10.
//  Copyright (c) 2014年 HuiLian. All rights reserved.
//

#import "ViewController.h"
#import "LFStockCell.h"
#import "LFAddStockViewController.h"
#import "LFStorageManager.h"
#import "MJRefresh.h"
#import "LFStockDetailViewController.h"

#define BASE_URL        @"http://hq.sinajs.cn/list="

#define TINT_COLOR      [UIColor colorWithRed:255.0/255.0 green:252.0/255.0 blue:248.0/255.0 alpha:1]

@interface ViewController () <NSURLConnectionDelegate,UITableViewDataSource,UITableViewDelegate>

@property (nonatomic)   UITableView *tableView;

@property (nonatomic)   NSMutableArray      *stockList;
@property (nonatomic)   NSMutableDictionary *stockData;

@property (nonatomic)   NSURLConnection *connection;
@property (nonatomic)   NSMutableData   *receivedData;

@property (nonatomic)   BOOL    canEditing;
@property (nonatomic)   NSTimer *timer;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    
    self.view.backgroundColor = [UIColor whiteColor];
    self.title = @"自选股";
    
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"添加" style:UIBarButtonItemStylePlain target:self action:@selector(onAddRemoveAction:)];
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"编辑" style:UIBarButtonItemStylePlain target:self action:@selector(onEditAction:)];
    
    _tableView = [[UITableView alloc] initWithFrame:self.view.bounds style:UITableViewStylePlain];
    _tableView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    _tableView.delegate = self;
    _tableView.dataSource = self;
    _tableView.allowsMultipleSelectionDuringEditing = YES;
    _tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    _tableView.backgroundColor = TINT_COLOR;
    [_tableView registerNib:[UINib nibWithNibName:@"LFStockCell" bundle:nil] forCellReuseIdentifier:@"LFStockCell"];
    [self.view addSubview:_tableView];
    
    [self.tableView addHeaderWithTarget:self action:@selector(requestToUpdateStockData) dateKey:@"StockListUpdate"];
    
    // 设置文字(也可以不设置,默认的文字在MJRefreshConst中修改)
    self.tableView.headerPullToRefreshText = @"下拉刷新";
    self.tableView.headerReleaseToRefreshText = @"释放刷新";
    self.tableView.headerRefreshingText = @"刷新中...";
    
    self.canEditing = NO;
    
    [self loadDataFromStorage];
    
    if ([_stockList count] > 0) {
        [self requestToUpdateStockData];
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self.timer invalidate];
    [self startTimer];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    [self.timer invalidate];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(applicationWillResignActive:)
                                                 name:UIApplicationWillResignActiveNotification
                                               object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(applicationDidBecomeActive:)
                                                 name:UIApplicationDidBecomeActiveNotification
                                               object:nil];
}

- (void)viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:animated];
    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                    name:UIApplicationWillResignActiveNotification
                                                  object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                    name:UIApplicationDidBecomeActiveNotification
                                                  object:nil];
}

- (void)onTimerFired:(NSTimer *)timer
{
    NSLog(@"request data");
    [self requestToUpdateStockData];
}

- (void)applicationWillResignActive:(NSNotification *)notification
{
    [self pauseTimer];
}

- (void)applicationDidBecomeActive:(NSNotification *)notification
{
    [self startTimer];
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

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return 30;
}

- (CGFloat)tableView:(UITableView *)tableView estimatedHeightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 66;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    UIView *view = [[UIView alloc] initWithFrame:CGRectMake(0, 0, tableView.width, 30)];
    view.backgroundColor = [UIColor colorWithRed:59.0/255.0 green:152.0/255.0 blue:205.0/255.0 alpha:1];
    
    UILabel *nameLabel = [self createLabelWithText:@"名称"];
    nameLabel.left = 10;
    nameLabel.centerY = view.height/2;
    [view addSubview:nameLabel];
    
    UILabel *priceLabel = [self createLabelWithText:@"最新价"];
    priceLabel.centerX = tableView.width/2;
    priceLabel.centerY = view.height/2;
    [view addSubview:priceLabel];
    
    UILabel *rangeLabel = [self createLabelWithText:@"涨幅"];
    rangeLabel.right = tableView.width - 10;
    rangeLabel.centerY = view.height/2;
    [view addSubview:rangeLabel];
    
    return view;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    LFStockCell *cell = [tableView dequeueReusableCellWithIdentifier:@"LFStockCell"];
    [cell loadCellWithData:[_stockData dictionaryWithValuesForKeys:@[_stockList[indexPath.row]]]];
    cell.contentView.backgroundColor = TINT_COLOR;
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (!tableView.editing) {
        [tableView deselectRowAtIndexPath:indexPath animated:NO];
        LFStockDetailViewController *detailVC = [[LFStockDetailViewController alloc] initWithdata:[_stockData dictionaryWithValuesForKeys:@[_stockList[indexPath.row]]]];
        [self.navigationController pushViewController:detailVC animated:YES];
    }
}

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    return YES;
}

- (UITableViewCellEditingStyle)tableView:(UITableView *)tableView editingStyleForRowAtIndexPath:(NSIndexPath *)indexPath {
    return UITableViewCellEditingStyleDelete;
}

- (NSString *)tableView:(UITableView *)tableView titleForDeleteConfirmationButtonForRowAtIndexPath:(NSIndexPath *)indexPath{
    return @"删除自选";
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        NSString *stockCode = [_stockList objectAtIndex:indexPath.row];
        [_stockList removeObjectAtIndex:indexPath.row];
        [_stockData removeObjectForKey:stockCode];
        [self saveDataToStorage];
        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationAutomatic];
    }
}

#pragma mark -  NSUrlConnectionDelegate methods

- (void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response
{
    self.receivedData = [[NSMutableData alloc] init];
}

- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data
{
    [_receivedData appendData:data];
}

- (void)connectionDidFinishLoading:(NSURLConnection *)connection
{
    NSStringEncoding gbkEncoding =CFStringConvertEncodingToNSStringEncoding(kCFStringEncodingGB_18030_2000);
    NSString *asyReturn = [[NSString alloc] initWithData:_receivedData encoding:gbkEncoding];
   
    NSArray *stockArray = [asyReturn componentsSeparatedByString:@";"];
    for (NSInteger index = 0; index < [stockArray count] - 1; index ++) {
        NSString *string = [stockArray[index] componentsSeparatedByString:@"="][1];
        string = [string substringWithRange:NSMakeRange(1, [string length] - 2)];
        [_stockData setObject:[string componentsSeparatedByString:@","] forKey:_stockList[index]];
    }
    if (!self.tableView.isEditing) {
        [self.tableView reloadData];
    }
    [self saveDataToStorage];
    [self endRequest];
}

- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error
{
    NSLog(@"%@",connection);
    [self endRequest];
}

#pragma mark IBAction

- (void)onEditAction:(id)sender
{
    self.canEditing = !self.canEditing;
    [_tableView setEditing:self.canEditing animated:YES];
}

- (void)onAddRemoveAction:(id)sender
{
    if (self.canEditing) {
        //  删除
        NSArray *selectedIndexs = [_tableView indexPathsForSelectedRows];
        
        NSMutableArray *objectsToRemove = [NSMutableArray array];
        for (NSIndexPath *indexPath in selectedIndexs) {
            [objectsToRemove addObject:[_stockList objectAtIndex:indexPath.row]];
        }
        
        while ([objectsToRemove count] > 0) {
            NSString *stockCode = [objectsToRemove firstObject];
            [_stockList removeObject:stockCode];
            [objectsToRemove removeObjectAtIndex:0];
            [_stockData removeObjectForKey:stockCode];
        }
        
        [_tableView beginUpdates];
        [_tableView deleteRowsAtIndexPaths:selectedIndexs withRowAnimation:UITableViewRowAnimationAutomatic];
        [_tableView endUpdates];
        
        [self saveDataToStorage];
        [_tableView setEditing:NO animated:YES];
        self.canEditing = !self.canEditing;
    }
    else {
        //添加
        LFAddStockViewController *addVC = [[LFAddStockViewController alloc] init];
        __block typeof(self) weakSelf = self;
        addVC.action = ^(NSString *code){
            __block typeof(weakSelf) strongSelf = weakSelf;
            if (![strongSelf.stockList containsObject:code]) {
                [strongSelf.stockList addObject:code];
                [strongSelf requestToUpdateStockData];
            }
        };
        LFNavigationViewController *nav = [[LFNavigationViewController alloc] initWithRootViewController:addVC];
        [self presentViewController:nav animated:YES completion:nil];
    }
}

#pragma mark - Setter

- (void)setCanEditing:(BOOL)canEditing
{
    _canEditing = canEditing;
    if (self.canEditing) {
        [self pauseTimer];
        [self.navigationItem.rightBarButtonItem setTitle:@"取消"];
        [self.navigationItem.leftBarButtonItem setTitle:@"删除"];
    }
    else{
        [self startTimer];
        [self.navigationItem.rightBarButtonItem setTitle:@"编辑"];
        [self.navigationItem.leftBarButtonItem setTitle:@"添加"];
    }
}

#pragma mark - Private

- (void)loadDataFromStorage
{
    self.stockList = [NSMutableArray arrayWithArray:[[LFStorageManager shareInstance] stockList]];
    self.stockData = [NSMutableDictionary dictionaryWithDictionary:[[LFStorageManager shareInstance] stockData]];
}

- (void)saveDataToStorage
{
    [LFStorageManager shareInstance].stockList = [_stockList copy];
    [LFStorageManager shareInstance].stockData = [_stockData copy];
}

- (void)requestToUpdateStockData
{
    [self.connection cancel];
    if ([_stockList count] > 0) {
        //step 1:请求地址
        NSMutableString *urlString = [NSMutableString stringWithString:BASE_URL];
        NSString *stockStr = [_stockList componentsJoinedByString:@","];
        [urlString appendString:stockStr];
        NSURL *url = [NSURL URLWithString:urlString];
        //step 2:实例化一个request
        NSURLRequest *requrst = [NSURLRequest requestWithURL:url cachePolicy:NSURLRequestUseProtocolCachePolicy timeoutInterval:10.0];
        //step 3：创建链接
        self.connection = [[NSURLConnection alloc] initWithRequest:requrst delegate:self];
        
        [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:YES];
    }
    else {
        [self endRequest];
    }
}

- (void)endRequest
{
    [self.tableView headerEndRefreshing];
    [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
}

- (void)pauseTimer
{
    [self.timer invalidate];
    [self.connection cancel];
}

- (void)startTimer
{
    [self.timer invalidate];
    self.timer = [NSTimer timerWithTimeInterval:5 target:self selector:@selector(onTimerFired:) userInfo:nil repeats:YES];
    [[NSRunLoop currentRunLoop]addTimer:_timer forMode:NSRunLoopCommonModes];
    [self requestToUpdateStockData];
}

- (UILabel *)createLabelWithText:(NSString *)text
{
    UILabel *label = [[UILabel alloc] init];
    label.text = text;
    [label sizeToFit];
    label.textColor = [UIColor whiteColor];
    return label;
}

- (void)dealloc
{
    NSLog(@"%@",self);
}

@end
