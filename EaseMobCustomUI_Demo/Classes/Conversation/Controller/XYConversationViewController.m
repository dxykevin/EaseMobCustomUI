//
//  XYConversationViewController.m
//  EaseMobCustomUI_Demo
//
//  Created by HoldCourt on 16/7/5.
//  Copyright © 2016年 HoldCourt. All rights reserved.
//

#import "XYConversationViewController.h"
#import "EMSDK.h"
@interface XYConversationViewController () <EMClientDelegate,EMContactManagerDelegate,UIAlertViewDelegate>
/** 好友名字 */
@property (nonatomic,copy) NSString *buddyName;
@end

@implementation XYConversationViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    /** 监听网络状态的代理 */
    [[EMClient sharedClient] addDelegate:self delegateQueue:nil];
    /** 好友添加 删除等代理 */
    [[EMClient sharedClient].contactManager addDelegate:self delegateQueue:nil];
}

#pragma mark - EMClientDelegate
/** 网络连接状态变化发生的回调 */
- (void)didConnectionStateChanged:(EMConnectionState)aConnectionState {
    
    if (aConnectionState == EMConnectionDisconnected) {
        NSLog(@"网络未连接");
        self.navigationItem.title = @"网络未连接";
    } else {
        NSLog(@"网络连接成功");
        self.navigationItem.title = @"网络连接成功";
    }
}

#pragma mark - EMContactManagerDelegate
/**
 *  用户B同意用户A的加好友请求后，用户A会收到这个回调
 *
 *  @param aUsername 用户B
 */
- (void)didReceiveAgreedFromUsername:(NSString *)aUsername {
    
    NSString *message = [NSString stringWithFormat:@"用户%@同意了您的好友请求",aUsername];
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"添加好友" message:message delegate:nil cancelButtonTitle:nil otherButtonTitles:@"OK", nil];
    [alert show];
}

/**
 *  用户B拒绝用户A的加好友请求后，用户A会收到这个回调
 *
 *  @param aUsername 用户B
 */
- (void)didReceiveDeclinedFromUsername:(NSString *)aUsername {
    
    NSString *message = [NSString stringWithFormat:@"用户%@拒绝了您的好友请求",aUsername];
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"添加好友" message:message delegate:nil cancelButtonTitle:nil otherButtonTitles:@"OK", nil];
    [alert show];
}

/**
 *  用户B删除与用户A的好友关系后，用户A会收到这个回调
 *
 *  @param aUsername 用户B
 */
- (void)didReceiveDeletedFromUsername:(NSString *)aUsername {
    
    NSString *message = [NSString stringWithFormat:@"您已被%@用户删除",aUsername];
    NSLog(@"您已被%@用户删除",aUsername);
    UIAlertController *alertC = [UIAlertController alertControllerWithTitle:@"提示" message:message preferredStyle:(UIAlertControllerStyleAlert)];
    [self presentViewController:alertC animated:YES completion:^{
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(3 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            [alertC dismissViewControllerAnimated:YES completion:nil];
        });
    }];
}

/**
 *   用户B同意用户A的好友申请后，用户A和用户B都会收到这个回调
 *
 *  @param aUsername 用户好友关系的另一方
 */
- (void)didReceiveAddedFromUsername:(NSString *)aUsername {
    
}

/**
 *  用户B申请加A为好友后，用户A会收到这个回调
 *
 *  @param aUsername 用户B
 *  @param aMessage  好友邀请信息
 */
- (void)didReceiveFriendInvitationFromUsername:(NSString *)aUsername
                                       message:(NSString *)aMessage {
    
    
}

- (void)dealloc {
    
    [[EMClient sharedClient] removeDelegate:self];
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
#warning Incomplete implementation, return the number of sections
    return 0;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
#warning Incomplete implementation, return the number of rows
    return 0;
}

@end
