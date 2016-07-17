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
#import "XYAnyView.h"
#import "MWPhotoBrowser.h"
@interface XYChatViewController () <UITableViewDelegate,UITableViewDataSource,EMChatManagerDelegate,XYToolViewDelegate,UIImagePickerControllerDelegate,UINavigationControllerDelegate,XYChatViewCellShowImageDelegate,MWPhotoBrowserDelegate>
@property (nonatomic,strong) UITableView *tableView;
@property (nonatomic,strong) XYToolView *toolView;
@property (nonatomic,strong) XYAnyView *anyView;
@property (nonatomic,strong) UITextView *textView;
/** 消息数组 */
@property (nonatomic,strong) NSMutableArray *messageData;
/** 保存图片的message */
@property (nonatomic,strong) EMMessage *photoMessage;
@end

@implementation XYChatViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    self.title = self.conversationID;
    
    /** 注册消息代理 */
    [[EMClient sharedClient].chatManager addDelegate:self delegateQueue:nil];
    
    self.view.backgroundColor = [UIColor grayColor];
    
    UITableView *myView = [[UITableView alloc] init];
    myView.contentInset = UIEdgeInsetsMake(64, 0, 0, 0);
    myView.frame = CGRectMake(0, 0, kScreenWidth, kScreenHeight - 44);
    self.tableView = myView;
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    self.tableView.separatorStyle = UITableViewCellEditingStyleNone;
    [self.view addSubview:myView];
    
    [self.tableView registerClass:[XYChatViewCell class] forCellReuseIdentifier:@"chatCell"];
    
    XYToolView *toolView = [[XYToolView alloc] initWithFrame:CGRectMake(0, myView.bottom, kScreenWidth, 44)];
    toolView.delegate = self;
    [self.view addSubview:toolView];
    self.toolView = toolView;
    [self setupInputViewBlock];
    
    /** 加载数据 */
    [self loadData];
    
    /** 监听键盘 */
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillShown:) name:UIKeyboardWillShowNotification object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillHiden:) name:UIKeyboardWillHideNotification object:nil];
    
    
    /** 创建更多功能 */
    XYAnyView *anyView = [[XYAnyView alloc] initWithImageBlock:^{
        HCLog(@"点击了发送图片按钮");
        UIImagePickerController *picker = [[UIImagePickerController alloc] init];
        picker.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
        picker.delegate = self;
        
        /** 解决弹出photolibrary还显示anyView的bug */
        [self scrollViewWillBeginDragging:self.tableView];
        
        [self presentViewController:picker animated:YES completion:nil];
    } voiceBlock:^{
        HCLog(@"点击了发送语音按钮");
    } videoBlock:^{
        HCLog(@"点击了发送视频按钮");
    }];
    anyView.frame = CGRectMake(0, kScreenHeight, kScreenWidth, ((kScreenWidth - 4 * kWeChatPadding) / 3) + 2 * kWeChatPadding);
    
    [[UIApplication sharedApplication].keyWindow addSubview:anyView];
    self.anyView = anyView;
    
     [self scrollBottom];
}

- (void)viewWillDisappear:(BOOL)animated {
    
    [super viewWillDisappear:animated];
    self.tableView.top = 0;
    self.anyView.top = kScreenHeight;
}

/** 初始化inputView的block */
- (void)setupInputViewBlock {
    
    __weak typeof(self) weakSelf = self;
    
    self.toolView.sendTextBlock = ^(UITextView *textView,XYToolViewEditTextViewType type) {
        
        /** [textView.text substringToIndex:textView.text.length - 1]目的是点击发送的时候是\n相当于添加了一行 */
        if (type == XYToolViewEditTextViewTypeSend) {
            EMTextMessageBody *body = [[EMTextMessageBody alloc] initWithText:[textView.text substringToIndex:textView.text.length - 1]];
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
        } else {
            
            weakSelf.textView = textView;
        }
    };
    
    self.toolView.moreBlock = ^() {
        
        if (weakSelf.textView) {
            [weakSelf.textView resignFirstResponder];
        }
        [UIView animateWithDuration:0.25f animations:^{
            weakSelf.tableView.top = - (((kScreenWidth - 4 * kWeChatPadding) / 3) + 2 * kWeChatPadding);
            weakSelf.toolView.top = weakSelf.tableView.bottom;
            weakSelf.anyView.top = kScreenHeight - (((kScreenWidth - 4 * kWeChatPadding) / 3) + 2 * kWeChatPadding);
        }];
    };
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

- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView {
    
    [self.view endEditing:YES];
    [UIView animateWithDuration:0.25 animations:^{
        self.anyView.top = kScreenHeight;
        if (self.tableView.top < 0) {
            self.tableView.top = 0;
            self.toolView.top = self.tableView.bottom;
        }
    }];
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
    
    /** 取消选中cell显示灰色 */
    cell.selectedBackgroundView = [UIView new];
    
    cell.delegate = self;
    
    cell.message = self.messageData[indexPath.row];
    
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    XYChatViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"chatCell"];
    
    cell.message = self.messageData[indexPath.row];
    
    return cell.cellHeight;
}

#pragma mark - UIImagePickerControllerDelegate
- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary<NSString *,id> *)info {
    
    /** 隐藏picker */
    [picker dismissViewControllerAnimated:YES completion:nil];
    /** 取出图片 */
    UIImage *image = info[UIImagePickerControllerOriginalImage];
    /** 发送图片 */
    [self sendImage:image];
}

- (void)sendImage:(UIImage *)image {
    
    /** image转换为二进制流 */
    NSData *data = UIImagePNGRepresentation(image);
    
    EMImageMessageBody *body = [[EMImageMessageBody alloc] initWithData:data displayName:@"image.png"];
    NSString *from = [[EMClient sharedClient] currentUsername];
    
    //生成Message
    EMMessage *message = [[EMMessage alloc] initWithConversationID:self.conversationID from:from to:self.conversationID body:body ext:nil];
    message.chatType = EMChatTypeChat;// 设置为单聊消息
    
    [[EMClient sharedClient].chatManager asyncSendMessage:message progress:^(int progress) {
        HCLog(@"photo --- progress --- %zd",progress);
    } completion:^(EMMessage *message, EMError *error) {
        if (!error) {
            HCLog(@"图片发送成功");
            [self.messageData addObject:message];
            [self scrollBottom];
        }
    }];
}

#pragma mark - EMChatManagerDelegate

- (void)didReceiveMessages:(NSArray *)aMessages {
    
   
    for (EMMessage *message in aMessages) {
        
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
            NSTimeInterval time = [NSDate timeIntervalSinceReferenceDate];
            [[EMCDDeviceManager sharedInstance] asyncStartRecordingWithFileName:[NSString stringWithFormat:@"%zd%zd",fileNum,time] completion:^(NSError *error) {
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

#pragma mark - XYChatViewCellShowImageDelegate
- (void)chatCellWithMessage:(EMMessage *)message {
    
    self.photoMessage = message;
    MWPhotoBrowser *broweser = [[MWPhotoBrowser alloc] initWithDelegate:self];
    [self.navigationController pushViewController:broweser animated:YES];
}


#pragma mark - MWPhotoBrowserDelegate
- (NSUInteger)numberOfPhotosInPhotoBrowser:(MWPhotoBrowser *)photoBrowser {
    
    return 1;
}

- (id <MWPhoto>)photoBrowser:(MWPhotoBrowser *)photoBrowser photoAtIndex:(NSUInteger)index {
    
    EMImageMessageBody *body = (EMImageMessageBody *)self.photoMessage.body;
    NSString *path = body.localPath;
    MWPhoto *photo = nil;
    if ([[NSFileManager defaultManager] fileExistsAtPath:path]) {
        /** 本地图片 */
        photo = [MWPhoto photoWithImage:[UIImage imageWithContentsOfFile:path]];
    } else {
        /** 网络图片 */
        path = body.remotePath;
        photo = [MWPhoto photoWithURL:[NSURL URLWithString:path]];
    }
    return photo;
}

/** 懒加载 */
- (NSMutableArray *)messageData {
    
    if (!_messageData) {
        _messageData = [NSMutableArray array];
    }
    return _messageData;
}
@end
