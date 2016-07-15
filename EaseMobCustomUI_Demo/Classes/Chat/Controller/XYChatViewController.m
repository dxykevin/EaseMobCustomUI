//
//  XYChatViewController.m
//  EaseMobCustomUI_Demo
//
//  Created by HoldCourt on 16/7/6.
//  Copyright © 2016年 HoldCourt. All rights reserved.
//

#import "XYChatViewController.h"
#import "XYToolView.h"
#import "XYChatViewCell.h"

@interface XYChatViewController () <UITableViewDelegate,UITableViewDataSource,EMChatManagerDelegate>
@property (nonatomic,strong) UITableView *tableView;
@property (nonatomic,strong) XYToolView *toolView;
/** 消息数组 */
@property (nonatomic,strong) NSMutableArray *messageData;
@end

@implementation XYChatViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    self.title = self.conversationID;
    
    /** 注册消息代理 */
    [[EMClient sharedClient].chatManager addDelegate:self delegateQueue:nil];
    
    self.view.backgroundColor = [UIColor grayColor];
    
    XYToolView *toolView = [[XYToolView alloc] initWithFrame:CGRectMake(0, kScreenHeight - 44, kScreenWidth, 44)];
    [self.view addSubview:toolView];
//    toolView.moreBlock = ^() {
//        NSLog(@"%s",__func__);
//        EMTextMessageBody *body = [[EMTextMessageBody alloc] initWithText:@"积极急急急急急急急急急急急急急急急急急急急急急急急急急急急急急急就是的覅偶见否"];
//        EMMessage *message = [[EMMessage alloc] initWithConversationID:@"hc11" from:@"havego" to:@"hc11" body:body ext:nil];
//        [[EMClient sharedClient].chatManager asyncSendMessage:message progress:nil completion:nil];
//    };
    self.toolView = toolView;
    
    UITableView *myView = [[UITableView alloc] init];
    myView.contentInset = UIEdgeInsetsMake(64, 0, 0, 0);
    myView.frame = CGRectMake(0, 0, kScreenWidth, kScreenHeight - 44);
    self.tableView = myView;
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    self.tableView.separatorStyle = UITableViewCellEditingStyleNone;
    [self.view addSubview:myView];
    
    [self.tableView registerClass:[XYChatViewCell class] forCellReuseIdentifier:@"chatCell"];
    
    /** 加载数据 */
    [self loadData];
    
    [self scrollBottom];
    
    /** 监听键盘 */
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillShown:) name:UIKeyboardWillShowNotification object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillHiden:) name:UIKeyboardWillHideNotification object:nil];
}

/** 加载数据 */
- (void)loadData {

    EMConversation *conversation = [[EMClient sharedClient].chatManager getConversation:self.conversationID type:(EMConversationTypeChat) createIfNotExist:YES];
    /** 最近消息列表 */
    NSArray *recentMsgArr = [conversation loadMoreMessagesFromId:nil limit:20 direction:(EMMessageSearchDirectionUp)];
    self.messageData = [NSMutableArray arrayWithArray:recentMsgArr];
}

- (void)keyboardWillShown:(NSNotification *)notification {
    
    CGFloat height = [notification.userInfo[UIKeyboardFrameEndUserInfoKey] CGRectValue].size.height;
    CGRect frame = self.toolView.frame;
    frame.origin.y = kScreenHeight - frame.size.height - height;
    self.toolView.frame = frame;
    self.tableView.frame = CGRectMake(0, -height, kScreenWidth, kScreenHeight - 44);

    [UIView animateWithDuration:0.25 animations:^{
        [self.view layoutIfNeeded];
    }];
}

- (void)keyboardWillHiden:(NSNotification *)notification {
    
    CGRect frame = self.toolView.frame;
    frame.origin.y = kScreenHeight - frame.size.height;
    self.toolView.frame = frame;
    self.tableView.frame = CGRectMake(0, 0, kScreenWidth, kScreenHeight - 44);

    [UIView animateWithDuration:0.25 animations:^{
        [self.view layoutIfNeeded];
    }];
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    
    /** 拖拽回收键盘 */
    [self.view endEditing:YES];
}

- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    
    /** 拖拽回收键盘 */
    [self.view endEditing:YES];
}

/** 滑动到最底部 */
- (void)scrollBottom {
    
    if (self.messageData.count == 0) {
        return;
    }
    NSIndexPath *indexPath = [NSIndexPath indexPathForRow:self.messageData.count - 1 inSection:0];
    [self.tableView scrollToRowAtIndexPath:indexPath atScrollPosition:(UITableViewScrollPositionBottom) animated:YES];
}

- (void)dealloc {
    
    [[EMClient sharedClient].chatManager removeDelegate:self];
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    
    return self.messageData.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    XYChatViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"chatCell"];
    
    cell.message = self.messageData[indexPath.row];
    
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    XYChatViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"chatCell"];
    
    cell.message = self.messageData[indexPath.row];
    
    return 150;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}

#pragma mark - EMChatManagerDelegate

- (void)didReceiveMessages:(NSArray *)aMessages {
    
    for (EMMessage *message in aMessages) {
        [self.messageData addObject:message];
    }
    [self.tableView reloadData];
    [self scrollBottom];
}

/** 懒加载 */
- (NSMutableArray *)messageData {
    
    if (!_messageData) {
        _messageData = [NSMutableArray array];
    }
    return _messageData;
}
@end
