//
//  XYChatViewCell.m
//  EaseMobCustomUI_Demo
//
//  Created by HoldCourt on 16/7/6.
//  Copyright © 2016年 HoldCourt. All rights reserved.
//

#import "XYChatViewCell.h"
#import "NSDateUtilities.h"
#import "EMCDDeviceManager.h"
#import "UIButton+WebCache.h"
@interface XYChatViewCell ()
/** 头像 */
@property (nonatomic,strong) XYButton *iconBt;
/** 时间 */
@property (nonatomic,strong) UILabel *timeLb;;
/** 消息 */
@property (nonatomic,strong) XYButton *msgBt;
/** 记录重复时间 */
@property (nonatomic,copy) NSString *latestTimeStr;
/** 文本尺寸 */
@property (nonatomic,assign) CGSize size;

@end
@implementation XYChatViewCell
- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    
    if (self = [super initWithStyle:style reuseIdentifier:reuseIdentifier]) {
        /** 初始化 */
        [self setupViews];
    }
    return self;
}

- (void)setupViews {
    
    /** 时间 */
    UILabel *timeLb = [[UILabel alloc] init];
    timeLb.textAlignment = NSTextAlignmentCenter;
    [self.contentView addSubview:timeLb];
    
    /** 头像 */
    XYButton *headBt = [XYButton createButton];
    [self.contentView addSubview:headBt];
    
    /** 消息 */
    XYButton *msgBt = [XYButton createButton];
    [msgBt addTarget:self action:@selector(msgClick:) forControlEvents:(UIControlEventTouchUpInside)];
    [self.contentView addSubview:msgBt];
    
    self.timeLb = timeLb;
    self.iconBt = headBt;
    self.msgBt = msgBt;
    [self.iconBt setBackgroundImage:[UIImage imageNamed:@"chatListCellHead"] forState:(UIControlStateNormal)];
    self.msgBt.titleLabel.textAlignment = NSTextAlignmentLeft;
    self.msgBt.contentEdgeInsets = UIEdgeInsetsMake(20, 20, 20, 20);
    self.msgBt.titleLabel.numberOfLines = 0;
    self.msgBt.titleLabel.font = [UIFont systemFontOfSize:15.0f];
}

/** 消息点击事件 */
- (void)msgClick:(XYButton *)button {
    
    if ([self.message.body isKindOfClass:[EMVoiceMessageBody class]]) {
        
        [self playVoice];
    } else if ([self.message.body isKindOfClass:[EMImageMessageBody class]]) {
        /** 显示大图片 */
        if (self.delegate && [self.delegate respondsToSelector:@selector(chatCellWithMessage:)]) {
            [self.delegate chatCellWithMessage:self.message];
        }
    }
}

/** 播放语音 */
- (void)playVoice {
    
    /** 播放语音 */
    EMVoiceMessageBody *body = (EMVoiceMessageBody *)self.message.body;
    /** 获取本地路径 */
    NSString *path = body.localPath;
    NSFileManager *fileManager = [NSFileManager defaultManager];
    /** 判断path路径是否存在 */
    if (![fileManager fileExistsAtPath:path]) {
        /** 从服务器获取地址 */
        path = body.remotePath;
    }
    [[EMCDDeviceManager sharedInstance] asyncPlayingWithPath:path completion:^(NSError *error) {
        if (!error) {
            NSLog(@"播放成功");
        }
    }];
}

- (void)layoutSubviews {
    
    [super layoutSubviews];
    self.timeLb.frame = CGRectMake(0, 0, kScreenWidth, 30);
}

- (void)setMessage:(EMMessage *)message {
    
    _message = message;

    self.timeLb.text = [self conversationTime:message.timestamp];
    
    if ([message.body isKindOfClass:[EMTextMessageBody class]]) {
        /** 文本类型 */
        EMTextMessageBody *txtBody = (EMTextMessageBody *)message.body;
        [self.msgBt setTitle:txtBody.text forState:(UIControlStateNormal)];
        [self.msgBt setImage:[UIImage new] forState:(UIControlStateNormal)];
        [self.msgBt setTitleColor:[UIColor blackColor] forState:(UIControlStateNormal)];
        NSLog(@"txtBody.text --- %@ %@",txtBody.text,message.messageId);
        CGSize size = [txtBody.text boundingRectWithSize:CGSizeMake(kScreenWidth / 2, MAXFLOAT) options:NSStringDrawingUsesLineFragmentOrigin attributes:@{NSFontAttributeName : [UIFont systemFontOfSize:15.0f]} context:nil].size;
        CGSize realSize = CGSizeMake(size.width + 40, size.height + 40);
        // 聊天按钮的size
        self.msgBt.size = realSize;
        
    } else if ([message.body isKindOfClass:[EMVoiceMessageBody class]]) {
        /** 语音类型 */
        EMVoiceMessageBody *voiceBody = (EMVoiceMessageBody *)message.body;
        [self.msgBt setImage:[UIImage imageNamed:@"chat_receiver_audio_playing_full"] forState:(UIControlStateNormal)];
        [self.msgBt setTitle:[NSString stringWithFormat:@"%zd",voiceBody.duration] forState:(UIControlStateNormal)];
        NSLog(@"voiceBody.duration --- %zd %@",voiceBody.duration,message.messageId);
        self.msgBt.size = CGSizeMake(kWeChatAllSubviewHeight + 40, kWeChatAllSubviewHeight + 40);
        [self.msgBt setTitleColor:[UIColor blackColor] forState:(UIControlStateNormal)];
        self.msgBt.titleEdgeInsets = UIEdgeInsetsMake(0, 10, 0, 0);
        self.msgBt.imageEdgeInsets = UIEdgeInsetsMake(0, 0, 0, 10);
    } else if ([message.body isKindOfClass:[EMImageMessageBody class]]) {
        self.msgBt.size = CGSizeMake(kWeChatAllSubviewHeight * 2 + 40, kWeChatAllSubviewHeight * 2 + 40);
        EMImageMessageBody *body = (EMImageMessageBody *)message.body;
        NSString *path = body.localPath;
        NSLog(@"path  %@",path);
        NSURL *imageUrl = nil;
        if ([[NSFileManager defaultManager] fileExistsAtPath:path]) {
            imageUrl = [NSURL fileURLWithPath:path];
        } else {
            imageUrl = [NSURL URLWithString:body.remotePath];
        }
        HCLog(@"imageUrl--%@",imageUrl);
        [self.msgBt sd_setImageWithURL:imageUrl forState:(UIControlStateNormal)];
    }
    
//    NSLog(@"txtBody.text---%@",txtBody.text);
    if ([message.from isEqualToString:[EMClient sharedClient].currentUsername]) {
        /** 自己发送的消息 */
        
        self.iconBt.frame = CGRectMake(kScreenWidth - kChatCellHeight - 10, 40, kChatCellHeight, kChatCellHeight);
        self.msgBt.left = kScreenWidth - self.msgBt.width - self.iconBt.width - 10 * 2;
        
        [self.msgBt setBackgroundImage:[self resizingImageWithName:@"SenderTextNodeBkg"] forState:(UIControlStateNormal)];
        [self.msgBt setBackgroundImage:[self resizingImageWithName:@"SenderTextNodeBkgHL"] forState:(UIControlStateHighlighted)];
    } else {
        /** 好友发来的消息 */
        self.iconBt.frame = CGRectMake(10, 40, kChatCellHeight, kChatCellHeight);
        self.msgBt.left = self.iconBt.right + 10;
        
        [self.msgBt setBackgroundImage:[self resizingImageWithName:@"ReceiverTextNodeBkg"] forState:(UIControlStateNormal)];
        [self.msgBt setBackgroundImage:[self resizingImageWithName:@"ReceiverTextNodeBkgHL"] forState:(UIControlStateHighlighted)];
    }
    
    self.msgBt.top = self.iconBt.top;
}

/** 时间的转换 */
- (NSString *)conversationTime:(long long)time
{
    // 今天 11:20
    // 昨天 23:23
    // 前天以前 11:11
    // 1. 创建一个日历对象
    NSCalendar *calendar = [NSCalendar currentCalendar];
    // 2. 获取当前时间
    NSDate *currentDate = [NSDate date];
    // 3. 获取当前时间的年月日
    NSDateComponents *components = [calendar components:NSCalendarUnitYear | NSCalendarUnitMonth | NSCalendarUnitDay fromDate:currentDate];
    NSInteger currentYear = components.year;
    NSInteger currentMonth = components.month;
    NSInteger currentDay = components.day;
    // 4. 获取发送时间
    NSDate *sendDate = [NSDate dateWithTimeIntervalSince1970:time/1000];
    // 5. 获取发送时间的年月日
    NSDateComponents *sendComponents = [calendar components:NSCalendarUnitYear | NSCalendarUnitMonth | NSCalendarUnitDay fromDate:sendDate];
    NSInteger sendYear = sendComponents.year;
    NSInteger sendMonth =  sendComponents.month;
    NSInteger sendDay = sendComponents.day;
    
    NSDateFormatter *fmt = [[NSDateFormatter alloc]init];
    // 6. 当前时间与发送时间的比较
    if (currentYear == sendYear &&
        currentMonth == sendMonth &&
        currentDay == sendDay) {// 今天
        fmt.dateFormat = @"今天 HH:mm";
    }else if(currentYear == sendYear &&
             currentMonth == sendMonth &&
             currentDay == sendDay + 1){
        fmt.dateFormat = @"昨天 HH:mm";
    }else{
        fmt.dateFormat = @"昨天以前 HH:mm";
    }
    
    NSString *timeStr = [fmt stringFromDate:sendDate];
    return  timeStr;
}

/** 图片拉伸 */
- (UIImage *)resizingImageWithName:(NSString *)name
{
    UIImage *normalImg = [UIImage imageNamed:name];
    
    CGFloat w = normalImg.size.width * 0.5f;
    CGFloat h = normalImg.size.height * 0.5f;
    
    return [normalImg resizableImageWithCapInsets:UIEdgeInsetsMake(h, w, h, w)];
}

- (CGFloat)cellHeight {
    
    return self.msgBt.bottom + kWeChatPadding;
}

+ (CGFloat)cellHeightForRowWithMessage:(EMMessage *)message {
    
    if (message.body.type == EMMessageBodyTypeText) {
        EMTextMessageBody *body = (EMTextMessageBody *)message.body;
        CGSize size = [body.text boundingRectWithSize:CGSizeMake(kScreenWidth / 2, MAXFLOAT) options:NSStringDrawingUsesLineFragmentOrigin attributes:@{NSFontAttributeName : [UIFont systemFontOfSize:15.0f]} context:nil].size;
        CGSize realSize = CGSizeMake(size.width + 40, size.height + 40);
        return 30 + 10 + realSize.height + 10;
    }
    return 100;
}

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
