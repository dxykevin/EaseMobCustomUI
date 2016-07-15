//
//  XYAddressBookViewController.m
//  EaseMobCustomUI_Demo
//
//  Created by HoldCourt on 16/7/5.
//  Copyright © 2016年 HoldCourt. All rights reserved.
//

#import "XYAddressBookViewController.h"
#import "XYChatViewController.h"
#import "EMSDK.h"
@interface XYAddressBookViewController () <EMContactManagerDelegate,UIAlertViewDelegate>
@property (nonatomic,strong) NSArray *buddylist;
/** 好友名字 */
@property (nonatomic,copy) NSString *buddyName;
@end

@implementation XYAddressBookViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [[EMClient sharedClient].contactManager addDelegate:self delegateQueue:nil];
    
    [self.tableView registerClass:[UITableViewCell class] forCellReuseIdentifier:@"addressCell"];
    
    self.buddylist = [[EMClient sharedClient].contactManager getContactsFromDB];
    NSLog(@"self.buddylist == %@",self.buddylist);
    
    if (self.buddylist.count == 0) {
        /** 数据库没有好友记录 从服务器获取 */
        EMError *error = nil;
        self.buddylist = [[EMClient sharedClient].contactManager getContactsFromServerWithError:&error];
        NSLog(@"数据库没有好友记录 从服务器获取 --- %@",self.buddylist);
    }
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    
    /** 获取对应好友 */
    NSString *buddyName = self.buddylist[indexPath.row];
    /** 删除好友 */
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        EMError *error = [[EMClient sharedClient].contactManager deleteContact:buddyName];
        if (!error) {
            NSLog(@"删除成功");
            [self getContactsFromServerAndReload];
        }
    }
}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {

    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {

    return self.buddylist.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"addressCell"];
    
    cell.imageView.image = [UIImage imageNamed:@"chatListCellHead"];
    
    cell.textLabel.text = self.buddylist[indexPath.row];
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
    XYChatViewController *chatVC = [[XYChatViewController alloc] init];
    /** push进去后隐藏tabBar */
    chatVC.hidesBottomBarWhenPushed = YES;
    chatVC.conversationID = self.buddylist[indexPath.row];
    [self.navigationController pushViewController:chatVC animated:YES];
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    return 60;
}

#pragma mark - EMContactManagerDelegate

/**
 *  用户B同意用户A的加好友请求后，用户A会收到这个回调
 *
 *  @param aUsername 用户B
 */
- (void)didReceiveAgreedFromUsername:(NSString *)aUsername {
    
    /** 把新的好友显示在列表上 */
    NSArray *buddyList = [[EMClient sharedClient].contactManager getContactsFromDB];
    NSLog(@"好友添加请求同意 %@",buddyList);
    self.buddylist = buddyList;
    [self.tableView reloadData];
}

/**
 *  用户B申请加A为好友后，用户A会收到这个回调
 *
 *  @param aUsername 用户B
 *  @param aMessage  好友邀请信息
 */
- (void)didReceiveFriendInvitationFromUsername:(NSString *)aUsername
                                       message:(NSString *)aMessage {
    
    NSLog(@"收到好友申请");
    self.buddyName = aUsername;
    NSString *message = [NSString stringWithFormat:@"%@想加您为好友",aUsername];
    NSLog(@"message == %@",message);
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"好友申请" message:message delegate:self cancelButtonTitle:@"拒绝" otherButtonTitles:@"接受", nil];
    [alert show];
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
    
    if (buttonIndex == 0) {
        /** 拒绝 */
        EMError *error = [[EMClient sharedClient].contactManager declineInvitationForUsername:self.buddyName];
        if (!error) {
            NSLog(@"拒绝已发送");
        }
    } else {
        /** 接受 */
        EMError *error = [[EMClient sharedClient].contactManager acceptInvitationForUsername:self.buddyName];
        if (!error) {
            NSLog(@"发送同意成功");
            /** 从服务器获取新的好友列表 */
            [self getContactsFromServerAndReload];
        }
    }
}

/**
 *  用户B删除与用户A的好友关系后，用户A会收到这个回调
 *
 *  @param aUsername 用户B
 */
- (void)didReceiveDeletedFromUsername:(NSString *)aUsername {
    
    [self getContactsFromServerAndReload];
}

/** 从服务器重新获取好友列表 并刷新表格 */
- (void)getContactsFromServerAndReload {
    
    self.buddylist = [[EMClient sharedClient].contactManager getContactsFromServerWithError:nil];
    [self.tableView reloadData];
}

- (void)dealloc {
    
    [[EMClient sharedClient].contactManager removeDelegate:self];
}

- (NSArray *)buddylist {
    if (!_buddylist) {
        _buddylist = [NSArray array];
    }
    return _buddylist;
}

@end
