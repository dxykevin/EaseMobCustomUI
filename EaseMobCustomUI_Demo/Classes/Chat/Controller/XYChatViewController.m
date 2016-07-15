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
#import "EMCDDeviceManager.h"
@interface XYChatViewController () <UITableViewDelegate,UITableViewDataSource,EMChatManagerDelegate,XYToolViewDelegate>
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
    toolView.delegate = self;
    [self.view addSubview:toolView];
    self.toolView = toolView;
    [self setupInputViewBlock];
    
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

/** 初始化inputView的block */
- (void)setupInputViewBlock {
    
    __weak typeof(self) weakSelf = self;
    
    self.toolView.sendTextBlock = ^(UITextView *textView,XYToolViewEditTextViewType type) {
        
        if (type == XYToolViewEditTextViewTypeSend) {
            EMTextMessageBody *body = [[EMTextMessageBody alloc] initWithText:textView.text];
            EMMessage *message = [[EMMessage alloc] initWithConversationID:weakSelf.conversationID from:[[EMClient sharedClient] currentUsername] to:weakSelf.conversationID body:body ext:nil];
            [[EMClient sharedClient].chatManager asyncSendMessage:message progress:nil completion:^(EMMessage *message, EMError *error) {
                if (!error) {
                    NSLog(@"消息发送成功");
                    textView.text = @"";
                    [weakSelf.messageData addObject:message];
                    [weakSelf.tableView reloadData];
                    [weakSelf scrollBottom];
                } else {
                    NSLog(@"消息发送失败");
                }
                }];
        }
    };
    //    toolView.moreBlock = ^() {
    //        NSLog(@"%s",__func__);
    //        EMTextMessageBody *body = [[EMTextMessageBody alloc] initWithText:@"积极急急急急急急急急急急急急急急急急急急急急急急急急急急急急急急就是的覅偶见否"];
    //        EMMessage *message = [[EMMessage alloc] initWithConversationID:@"hc11" from:@"havego" to:@"hc11" body:body ext:nil];
    //        [[EMClient sharedClient].chatManager asyncSendMessage:message progress:nil completion:nil];
    //    };
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
    [self.tableView reloadData];
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
    
    return cell.cellHeight;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}

#pragma mark - EMChatManagerDelegate

- (void)didReceiveMessages:(NSArray *)aMessages {
    
   
    for (EMMessage *message in aMessages) {
        NSLog(@"%zd",message.timestamp);
        [self.messageData addObject:message];
    }
    [self.tableView reloadData];
    [self scrollBottom];
}

#pragma mark - XYToolViewDelegate
- (void)toolViewWithType:(XYToolViewVoiceType)type button:(XYButton *)button {
    
    switch (type) {
        case XYToolViewVoiceTypeStart: {
            NSLog(@"开始录音");
            int fileNum = arc4random() / 1000;
            [[EMCDDeviceManager sharedInstance] asyncStartRecordingWithFileName:[NSString stringWithFormat:@"%zd",fileNum] completion:^(NSError *error) {
                if (!error) {
                    NSLog(@"录音成功");
                }
            }];
        }
            break;
        case XYToolViewVoiceTypeStop: {
            
            NSLog(@"停止录音");
            [[EMCDDeviceManager sharedInstance] asyncStopRecordingWithCompletion:^(NSString *recordPath, NSInteger aDuration, NSError *error) {
                
                if (!error) {
                    NSLog(@"recordPath -- %@ aDuration --- %zd",recordPath,aDuration);
                    /** 发送语音消息 */
                    [self sendVoiceMessageWithFilePath:recordPath voiceDuration:aDuration];
                }
            }];
        }
            break;
        case XYToolViewVoiceTypeCancel: {
            
            NSLog(@"取消录音");
            [[EMCDDeviceManager sharedInstance] cancelCurrentRecording];
        }
            break;
        default:
            break;
    }
}

- (void)sendVoiceMessageWithFilePath:(NSString *)filePath voiceDuration:(NSInteger)voiceDuration {
    
    EMVoiceMessageBody *body = [[EMVoiceMessageBody alloc] initWithLocalPath:filePath displayName:@"audio"];
    body.duration = (int)voiceDuration;
    
    // 生成message
    EMMessage *message = [[EMMessage alloc] initWithConversationID:self.conversationID from:[[EMClient sharedClient] currentUsername] to:self.conversationID body:body ext:nil];
    message.chatType = EMChatTypeChat;
    
    [[EMClient sharedClient].chatManager asyncSendMessage:message progress:^(int progress) {
        
        NSLog(@"发送语音进度progress --- %zd",progress);
    } completion:^(EMMessage *message, EMError *error) {
        
        if (!error) {
            NSLog(@"发送语音消息成功");
            
            [self.messageData addObject:message];
            [self scrollBottom];
        }
    }];
}

/** 懒加载 */
- (NSMutableArray *)messageData {
    
    if (!_messageData) {
        _messageData = [NSMutableArray array];
    }
    return _messageData;
}
@end
