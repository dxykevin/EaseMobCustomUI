//
//  XYSettingsViewController.m
//  EaseMobCustomUI_Demo
//
//  Created by HoldCourt on 16/7/6.
//  Copyright © 2016年 HoldCourt. All rights reserved.
//

#import "XYSettingsViewController.h"
#import "EMSDK.h"
#import "XYLoginViewController.h"
@interface XYSettingsViewController ()
@property (strong, nonatomic) UIButton *logoutBt;


@end

@implementation XYSettingsViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    
    [self.tableView registerClass:[UITableViewCell class] forCellReuseIdentifier:@"setCell"];
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

    return 1;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    /** 设置退出按钮的文字 */
    NSString *currentUserName = [[EMClient sharedClient] currentUsername
                                 ];
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"setCell" forIndexPath:indexPath];
    
    self.logoutBt = [UIButton buttonWithType:(UIButtonTypeSystem)];
    self.logoutBt.frame = CGRectMake(10, 10, 200, 30);
    [self.logoutBt setTitle:[NSString stringWithFormat:@"注销(%@)",currentUserName] forState:(UIControlStateNormal)];
    [self.logoutBt addTarget:self action:@selector(logout) forControlEvents:(UIControlEventTouchUpInside)];
    [cell.contentView addSubview:self.logoutBt];
    
    return cell;
}

- (void)logout {
    
    [[EMClient sharedClient] asyncLogout:YES success:^{
        NSLog(@"退出成功");
        NSLog(@"%@",[NSThread currentThread]);
        /** 回到主线程跳转 不然会异常 */
        [self performSelectorOnMainThread:@selector(backLogin) withObject:nil waitUntilDone:YES];
    } failure:^(EMError *aError) {
        NSLog(@"退出失败---%@",aError);
    }];
}

- (void)backLogin {
    
    NSLog(@"%@",[NSThread currentThread]);
    self.view.window.rootViewController = [UIStoryboard storyboardWithName:@"Login" bundle:nil].instantiateInitialViewController;
}
/*
// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return NO if you do not want the specified item to be editable.
    return YES;
}
*/

/*
// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        // Delete the row from the data source
        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
    } else if (editingStyle == UITableViewCellEditingStyleInsert) {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
    }   
}
*/

/*
// Override to support rearranging the table view.
- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath {
}
*/

/*
// Override to support conditional rearranging of the table view.
- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return NO if you do not want the item to be re-orderable.
    return YES;
}
*/

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
