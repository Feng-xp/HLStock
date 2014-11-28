//
//  LFAddStockViewController.m
//  HLStock
//
//  Created by qzp on 14/11/22.
//  Copyright (c) 2014年 HuiLian. All rights reserved.
//

#import <QuartzCore/QuartzCore.h>
#import "LFAddStockViewController.h"
#import "RadioGroup.h"
#import "RadioBox.h"

@interface LFAddStockViewController ()

@property (weak, nonatomic) IBOutlet UITextField *textField;

@property (weak, nonatomic) IBOutlet UIButton *addButon;

@property (nonatomic) IBOutlet RadioGroup *radioGroup;
@property (nonatomic) IBOutlet RadioBox *radioBox1;
@property (nonatomic) IBOutlet RadioBox *radioBox2;

@end

@implementation LFAddStockViewController

- (instancetype)init
{
    if ((self = [super initWithNibName:NSStringFromClass([self class]) bundle:[NSBundle mainBundle]])) {
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    self.title = @"添加自选股";
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"返回" style:UIBarButtonItemStylePlain target:self action:@selector(onBackAction:)];
    
    //代码实现
    self.radioBox1 = [[RadioBox alloc] initWithFrame:CGRectMake(12, 18, 100, 25)];
    self.radioBox2 = [[RadioBox alloc] initWithFrame:CGRectMake(12, 51, 100, 25)];
    
    _radioBox1.text = @"上海";
    _radioBox2.text = @"深圳";
    _radioBox1.value = 0;
    _radioBox2.value = 1;
    
    NSArray *controls = [NSArray arrayWithObjects:_radioBox1,_radioBox2, nil];
    
    self.radioGroup = [[RadioGroup alloc] initWithFrame:CGRectMake(176, 171, 124, 226) WithControl:controls];
    
    _radioGroup.backgroundColor = [UIColor clearColor];
    _radioGroup.textFont = [UIFont systemFontOfSize:14.0];
    _radioGroup.selectValue = 0;
    [self.view addSubview:_radioGroup];
    
    self.addButon.layer.borderColor = [[UIColor lightGrayColor] CGColor];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    [_textField becomeFirstResponder];
}

- (void)viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:animated];
    [_textField resignFirstResponder];
}

- (void)viewDidLayoutSubviews
{
    [super viewDidLayoutSubviews];
    _textField.height = 30;
    _radioGroup.frame = CGRectMake(10, _textField.bottom + 25, self.view.width - 2 * 10, 40);
    _radioBox1.frame = CGRectMake(60, (_radioGroup.height - 25)/2, 80, 25);
    _radioBox2.frame  =CGRectMake(_radioBox1.right + 30, _radioBox1.top, 80, 25);
}

#pragma mark - IBAction

- (void)onBackAction:(id)sender
{
    [self.textField resignFirstResponder];
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (IBAction)onAddAction:(id)sender {
    NSString *stockCode = self.textField.text;
    stockCode = [stockCode stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    if ([stockCode length] == 6) {
        if (self.action) {
            //上证股票以6开头，例6XXXXX
            //深证股票以0，2，3开头，例0XXXXX，2XXXXX，3XXXXX分别代表主板，中小板，创业板
            if ([stockCode hasPrefix:@"6"]) {
                stockCode = [NSString stringWithFormat:@"sh%@",stockCode];
            }
            else {
                stockCode = [NSString stringWithFormat:@"sz%@",stockCode];
            }
            self.action(stockCode);
        }
        [self onBackAction:nil];
    }
}

@end
