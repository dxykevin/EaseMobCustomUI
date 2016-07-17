//
//  XYCallViewController.m
//  EaseMobCustomUI_Demo
//
//  Created by HoldCourt on 16/7/17.
//  Copyright © 2016年 HoldCourt. All rights reserved.
//

#import "XYCallViewController.h"

@interface XYCallViewController () <EMCallManagerDelegate>

@end

@implementation XYCallViewController

- (void)viewDidLoad {
    
    [super viewDidLoad];
    
    [self setup];
}

- (void)setup {
    
    /** 1.背景图片 */
    UIImageView *imgView = [[UIImageView alloc] init];
    imgView.frame = CGRectMake(0, 0, kScreenWidth, kScreenHeight);
    imgView.image = [UIImage imageNamed:@"callBg"];
    [self.view addSubview:imgView];
    
    UIView *contentView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, kScreenWidth, kScreenHeight)];
    contentView.backgroundColor = [UIColor clearColor];
    [self.view addSubview:contentView];
    
    /** 2.时间标签 */
    UILabel *timeLb = [[UILabel alloc] initWithFrame:CGRectMake(0, kWeChatPadding, kScreenWidth, kWeChatAllSubviewHeight)];
    timeLb.textAlignment = NSTextAlignmentCenter;
    timeLb.backgroundColor = [UIColor clearColor];
    [contentView addSubview:timeLb];
    
    /** 同意按钮 */
    XYButton *acceptBt = [XYButton createButton];
    acceptBt.frame = CGRectMake(kWeChatPadding * 2, kScreenHeight - kWeChatAllSubviewHeight - kWeChatPadding, (kScreenWidth - (kWeChatPadding * 2) * 3) / 2, kWeChatAllSubviewHeight);
    [acceptBt setTitle:@"同意" forState:(UIControlStateNormal)];
    [contentView addSubview:acceptBt];
    
    /** 拒绝按钮 */
    XYButton *cancelBt = [XYButton createButton];
    cancelBt.frame = CGRectMake(acceptBt.right + kWeChatPadding * 2, kScreenHeight - kWeChatAllSubviewHeight - kWeChatPadding, (kScreenWidth - (kWeChatPadding * 2) * 3) / 2, kWeChatAllSubviewHeight);
    [cancelBt setTitle:@"退出" forState:(UIControlStateNormal)];
    [contentView addSubview:cancelBt];
    
    acceptBt.block = ^(XYButton *bt) {
      
        [[EMClient sharedClient].callManager answerIncomingCall:self.currentSession.sessionId];
    };
    
    cancelBt.block = ^(XYButton *bt) {
    
        [[EMClient sharedClient].callManager endCall:self.currentSession.sessionId reason:EMCallEndReasonHangup];
        [self dismissViewControllerAnimated:YES completion:nil];
    };
    /** 代理 */
    [[EMClient sharedClient].callManager addDelegate:self delegateQueue:nil];
}

- (void)dealloc {
    
    [[EMClient sharedClient].callManager removeDelegate:self];
}

#pragma mark - EMCallManagerDelegate(实时语音通话代理)

@end
