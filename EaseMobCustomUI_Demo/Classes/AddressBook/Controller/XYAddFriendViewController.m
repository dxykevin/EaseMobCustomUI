//
//  XYAddFriendViewController.m
//  EaseMobCustomUI_Demo
//
//  Created by HoldCourt on 16/7/5.
//  Copyright © 2016年 HoldCourt. All rights reserved.
//

#import "XYAddFriendViewController.h"
#import "EMSDK.h"
@interface XYAddFriendViewController ()
@property (weak, nonatomic) IBOutlet UITextField *addFriendTF;

@end

@implementation XYAddFriendViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
}

/** 添加好友 */
- (IBAction)addFriend:(id)sender {
   
    EMError *error = [[EMClient sharedClient].contactManager addContact:self.addFriendTF.text message:[NSString stringWithFormat:@"我是%@\n我想加你为好友",[[EMClient sharedClient] currentUsername]]];
    
    if (error) {
        NSLog(@"添加好友有问题--%@",error);
    } else {
        NSLog(@"添加好友没有问题");
    }
}

#pragma mark - EMChatManagerDelegate


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
