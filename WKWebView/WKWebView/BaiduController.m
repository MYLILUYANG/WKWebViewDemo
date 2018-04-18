//
//  BaiduController.m
//  WKWebView
//
//  Created by liluyang on 2018/4/13.
//  Copyright © 2018年 tamaidan. All rights reserved.
//

#import "BaiduController.h"
#import <WebKit/WebKit.h>
#import "pushViewController.h"
@interface BaiduController ()<WKUIDelegate, WKNavigationDelegate, WKScriptMessageHandler>
@property (nonatomic, strong) WKWebView *webView;
@property (nonatomic, strong) UIProgressView *progressView;
@end

@implementation BaiduController


- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor whiteColor];
    
    WKWebViewConfiguration *config = [[WKWebViewConfiguration alloc] init];
//    注入方法 messageSend 在js中通过注入的方法向原生OC传值。
    config.userContentController = [[WKUserContentController alloc] init];
    [config.userContentController addScriptMessageHandler:self name:@"messageSend"];
//    偏好设置
    config.preferences = [[WKPreferences alloc] init];
    config.preferences.minimumFontSize = 0;
    config.preferences.javaScriptEnabled = YES;
    config.preferences.javaScriptCanOpenWindowsAutomatically = NO;
    _webView = [[WKWebView alloc] initWithFrame:CGRectMake(0, 100, [UIScreen mainScreen].bounds.size.width, [UIScreen mainScreen].bounds.size.height) configuration:config];
    
//    [_webView loadRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:@"http://localhost:8080"]]];
//如果使用本地html文件
    NSURL *path = [[NSBundle mainBundle] URLForResource:@"NativeJS" withExtension:@"html"];
    [_webView loadRequest:[NSURLRequest requestWithURL:path]];
    _webView.UIDelegate = self;
    _webView.navigationDelegate = self;
    [self.view addSubview:_webView];
    
//    监听_webview 的状态
    [_webView addObserver:self forKeyPath:@"loading" options:NSKeyValueObservingOptionNew context:nil];
    [_webView addObserver:self forKeyPath:@"title" options:NSKeyValueObservingOptionNew context:nil];
    [_webView addObserver:self forKeyPath:@"estimaedProgress" options:NSKeyValueObservingOptionNew context:nil];
    

//    原生主动调用js方法
    UIButton *button = [[UIButton alloc] initWithFrame:CGRectMake(0, 64, [UIScreen mainScreen].bounds.size.width, 40)];
    [button setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    [button setTitle:@"原生button调用js的 jsSendConfirmToOC 方法" forState:UIControlStateNormal];
    [button addTarget:self action:@selector(btnAction) forControlEvents:UIControlEventTouchUpInside];
    button.layer.cornerRadius = 20;
    button.layer.masksToBounds = YES;
    button.backgroundColor =[UIColor lightGrayColor];
    [self.view addSubview:button];
    
    
}

-(void)btnAction{
    NSString *js = @"jsSendConfirmToOC()";
//    NSString *js = @"jsSendAlertToOC()";
//    NSString *js = @"jsSendInputToOC()";
//    NSString *js = @"jsSendMessageToOC()";
    
    [self.webView evaluateJavaScript:js completionHandler:^(id _Nullable resp, NSError * _Nullable error) {
        NSLog(@"error = %@ , response = %@",error, resp);
    }];
}

-(void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary<NSKeyValueChangeKey,id> *)change context:(void *)context
{
    if ([keyPath isEqualToString:@"loading"]) {
        NSLog(@"loading");
    }else if ([keyPath isEqualToString:@"title"]){
        self.title = self.webView.title;
    }else if ([keyPath isEqualToString:@"estimaedProgress"]){
       self.progressView.progress = self.webView.estimatedProgress;
    }
}

-(void)webView:(WKWebView *)webView didFinishNavigation:(WKNavigation *)navigation
{
    NSLog(@"加载完成");
}



#pragma mark - WKScriptMessageHandler
//当js 通过 注入的方法 @“messageSend” 时会调用代理回调。 原生收到的所有信息都通过此方法接收。
-(void)userContentController:(WKUserContentController *)userContentController didReceiveScriptMessage:(WKScriptMessage *)message
{
    NSLog(@"原生收到了js发送过来的消息 message.body = %@",message.body);
    if ([message.name isEqualToString:@"messageSend"]) {
        pushViewController *congtoller = [[pushViewController alloc] init];
        [self.navigationController pushViewController:congtoller animated:YES];
    }
}


#pragma mark - WKUIDelegate
//通过js alert 显示一个警告面板，调用原生会走此方法。
- (void)webView:(WKWebView *)webView runJavaScriptAlertPanelWithMessage:(NSString *)message initiatedByFrame:(WKFrameInfo *)frame completionHandler:(void (^)(void))completionHandler
{
    NSLog(@"显示一个JavaScript警告面板, message = %@",message);

    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"温馨提示" message:message preferredStyle:UIAlertControllerStyleAlert];
    
    [alertController addAction:[UIAlertAction actionWithTitle:@"确认" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        completionHandler();
    }]];
    
    [self presentViewController:alertController animated:YES completion:nil];
}
//通过 js confirm 显示一个确认面板，调用原生会走此方法。
- (void)webView:(WKWebView *)webView runJavaScriptConfirmPanelWithMessage:(NSString *)message initiatedByFrame:(WKFrameInfo *)frame completionHandler:(void (^)(BOOL result))completionHandler
{
    NSLog(@"运行JavaScript确认面板， message = %@", message);
    UIAlertController *action = [UIAlertController alertControllerWithTitle:@"温馨提示" message:message preferredStyle:UIAlertControllerStyleAlert];
    [action addAction:[UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
        completionHandler(NO);
    }] ];
    
    [action addAction:[UIAlertAction actionWithTitle:@"确认" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        completionHandler(YES);
    }]];
    
    [self presentViewController:action animated:YES completion:nil];

}
//显示输入框
- (void)webView:(WKWebView *)webView runJavaScriptTextInputPanelWithPrompt:(NSString *)prompt defaultText:(nullable NSString *)defaultText initiatedByFrame:(WKFrameInfo *)frame completionHandler:(void (^)(NSString * _Nullable result))completionHandler
{
    
    NSLog(@"显示一个JavaScript文本输入面板, message = %@",prompt);
    UIAlertController *controller = [UIAlertController alertControllerWithTitle:defaultText message:prompt preferredStyle:UIAlertControllerStyleAlert];
    
    [controller addTextFieldWithConfigurationHandler:^(UITextField * _Nonnull textField) {
        textField.textColor = [UIColor redColor];
    }];
    
    [controller addAction:[UIAlertAction actionWithTitle:@"输入信息" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        completionHandler([[controller.textFields lastObject] text]);
    }]];
    
    [self presentViewController:controller animated:YES completion:nil];
    
}
-(UIProgressView *)progressView
{
    if (!_progressView) {
        _progressView = [[UIProgressView alloc] initWithFrame:CGRectMake(0, 70, 300, 10)];
        _progressView.trackTintColor = [UIColor lightGrayColor];
        _progressView.progressTintColor = [UIColor yellowColor];
    }
    return _progressView;
}


@end
