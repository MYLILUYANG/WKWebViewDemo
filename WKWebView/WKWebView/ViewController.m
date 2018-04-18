//
//  ViewController.m
//  WKWebView
//
//  Created by liluyang on 2018/4/13.
//  Copyright © 2018年 tamaidan. All rights reserved.
//

#import "ViewController.h"
#import "BaiduController.h"
@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    UIButton * test1  =[ UIButton buttonWithType:UIButtonTypeCustom];
    test1.backgroundColor = [UIColor lightGrayColor];
    [test1 setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];

    test1.titleLabel.font = [UIFont systemFontOfSize:14];
    [test1 setTitle:@"点击进入html页面" forState:UIControlStateNormal];
    test1.frame = CGRectMake(0, 0, 200, 100);
    test1.center = self.view.center;
    [test1 addTarget:self action:@selector(testAction) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:test1];
}

-(void)testAction
{
    BaiduController *baidu = [[BaiduController alloc] init];
    [self.navigationController pushViewController:baidu animated:YES];
}
@end
