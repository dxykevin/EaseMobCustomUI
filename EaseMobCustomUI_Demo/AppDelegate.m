//
//  AppDelegate.m
//  EaseMobCustomUI_Demo
//
//  Created by HoldCourt on 16/7/4.
//  Copyright © 2016年 HoldCourt. All rights reserved.
//

#import "AppDelegate.h"
#import "EMSDK.h"
#define kAppKey @"easemob-demo#chatdemoui"
@interface AppDelegate () <EMClientDelegate,EMChatManagerDelegate>

@end

@implementation AppDelegate


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    // Override point for customization after application launch.
    
    HCLog(@"%@",NSHomeDirectory());
    
    /** 初始化 */
    EMOptions *options = [EMOptions  optionsWithAppkey:kAppKey];
    options.apnsCertName = nil;
    [[EMClient sharedClient] initializeSDKWithOptions:options];
    
    [[EMClient sharedClient] addDelegate:self delegateQueue:nil];
    [[EMClient sharedClient].chatManager addDelegate:self delegateQueue:nil];
    
    /** 判断是否自动登录 */
    if ([[EMClient sharedClient].options isAutoLogin]) {
        self.window.rootViewController = [UIStoryboard storyboardWithName:@"Main" bundle:nil].instantiateInitialViewController;
    }
    return YES;
}

// APP进入后台
- (void)applicationDidEnterBackground:(UIApplication *)application
{
    [[EMClient sharedClient] applicationDidEnterBackground:application];
}

// APP将要从后台返回
- (void)applicationWillEnterForeground:(UIApplication *)application
{
    [[EMClient sharedClient] applicationWillEnterForeground:application];
}

/** 自动登录返回的回调 */
- (void)didAutoLoginWithError:(EMError *)aError {
    
    if (!aError) {
        NSLog(@"自动登录成功");
    } else {
        NSLog(@"自动登录失败 === %@",aError);
    }
}

- (void)dealloc {
    
    [[EMClient sharedClient] removeDelegate:self];
    [[EMClient sharedClient].chatManager removeDelegate:self];
}
@end
