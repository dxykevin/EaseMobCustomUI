//
//  XYChatViewCell.m
//  EaseMobCustomUI_Demo
//
//  Created by HoldCourt on 16/7/6.
//  Copyright © 2016年 HoldCourt. All rights reserved.
//

#import "XYChatViewCell.h"

@interface XYChatViewCell ()
/** 头像 */
@property (nonatomic,strong) XYButton *iconBt;
/** 时间 */
@property (nonatomic,strong) UILabel *timeLb;;
/** 消息 */
@property (nonatomic,strong) XYButton *msgBt;
/** 消息的高度 */
@property (nonatomic,assign) CGFloat msgHeight;
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
    [self.contentView addSubview:msgBt];
    
    self.timeLb = timeLb;
    self.iconBt = headBt;
    self.msgBt = msgBt;
    self.msgBt.titleLabel.textAlignment = NSTextAlignmentLeft;
    self.msgBt.contentEdgeInsets = UIEdgeInsetsMake(15, 20, 25, 20);
    self.msgBt.titleLabel.numberOfLines = 0;
    self.msgBt.titleLabel.font = [UIFont systemFontOfSize:15.0f];
}

- (void)layoutSubviews {
    
    [super layoutSubviews];
    self.timeLb.frame = CGRectMake(0, 0, kScreenWidth, 30);
}

- (void)setMessage:(EMMessage *)message {
    
    _message = message;
    self.timeLb.text = [NSString stringWithFormat:@"%zd",message.timestamp];
    EMTextMessageBody *txtBody = (EMTextMessageBody *)message.body;
    
    [self.msgBt setTitle:txtBody.text forState:(UIControlStateNormal)];
    [self.msgBt setTitleColor:[UIColor blackColor] forState:(UIControlStateNormal)];
    [self.iconBt setBackgroundImage:[UIImage imageNamed:@"chatListCellHead"] forState:(UIControlStateNormal)];
    
    CGSize size = [txtBody.text boundingRectWithSize:CGSizeMake(kScreenWidth / 2, MAXFLOAT) options:NSStringDrawingUsesLineFragmentOrigin attributes:@{NSFontAttributeName : [UIFont systemFontOfSize:15.0f]} context:nil].size;
    CGSize realSize = CGSizeMake(size.width + 40, size.height + 40);
    self.msgHeight = realSize.height;
    self.msgBt.size = realSize;
    NSLog(@"txtBody.text---%@",txtBody.text);
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
//    NSLog(@"%@")
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
    
    NSLog(@"%lf %lf",self.msgBt.bottom,_cellHeight);
    return self.msgBt.bottom + 10;
}


/** for (EMMessage *message in aMessages) {
 [self.messageData addObject:message];
 EMMessageBody *msgBody = message.body;
 switch (msgBody.type) {
 case EMMessageBodyTypeText:
 {
 // 收到的文字消息
 EMTextMessageBody *textBody = (EMTextMessageBody *)msgBody;
 NSString *txt = textBody.text;
 NSLog(@"收到的文字是 txt -- %@",txt);
 }
 break;
 case EMMessageBodyTypeImage:
 {
 // 得到一个图片消息body
 EMImageMessageBody *body = ((EMImageMessageBody *)msgBody);
 NSLog(@"大图remote路径 -- %@"   ,body.remotePath);
 NSLog(@"大图local路径 -- %@"    ,body.localPath); // // 需要使用sdk提供的下载方法后才会存在
 NSLog(@"大图的secret -- %@"    ,body.secretKey);
 NSLog(@"大图的W -- %f ,大图的H -- %f",body.size.width,body.size.height);
 NSLog(@"大图的下载状态 -- %u",body.downloadStatus);
 
 
 // 缩略图sdk会自动下载
 NSLog(@"小图remote路径 -- %@"   ,body.thumbnailRemotePath);
 NSLog(@"小图local路径 -- %@"    ,body.thumbnailLocalPath);
 NSLog(@"小图的secret -- %@"    ,body.thumbnailSecretKey);
 NSLog(@"小图的W -- %f ,大图的H -- %f",body.thumbnailSize.width,body.thumbnailSize.height);
 NSLog(@"小图的下载状态 -- %u",body.thumbnailDownloadStatus);
 }
 break;
 case EMMessageBodyTypeLocation:
 {
 EMLocationMessageBody *body = (EMLocationMessageBody *)msgBody;
 NSLog(@"纬度-- %f",body.latitude);
 NSLog(@"经度-- %f",body.longitude);
 NSLog(@"地址-- %@",body.address);
 }
 break;
 case EMMessageBodyTypeVoice:
 {
 // 音频sdk会自动下载
 EMVoiceMessageBody *body = (EMVoiceMessageBody *)msgBody;
 NSLog(@"音频remote路径 -- %@"      ,body.remotePath);
 NSLog(@"音频local路径 -- %@"       ,body.localPath); // 需要使用sdk提供的下载方法后才会存在（音频会自动调用）
 NSLog(@"音频的secret -- %@"        ,body.secretKey);
 NSLog(@"音频文件大小 -- %lld"       ,body.fileLength);
 NSLog(@"音频文件的下载状态 -- %u"   ,body.downloadStatus);
 NSLog(@"音频的时间长度 -- %d"      ,body.duration);
 }
 break;
 case EMMessageBodyTypeVideo:
 {
 EMVideoMessageBody *body = (EMVideoMessageBody *)msgBody;
 
 NSLog(@"视频remote路径 -- %@"      ,body.remotePath);
 NSLog(@"视频local路径 -- %@"       ,body.localPath); // 需要使用sdk提供的下载方法后才会存在
 NSLog(@"视频的secret -- %@"        ,body.secretKey);
 NSLog(@"视频文件大小 -- %lld"       ,body.fileLength);
 NSLog(@"视频文件的下载状态 -- %u"   ,body.downloadStatus);
 NSLog(@"视频的时间长度 -- %d"      ,body.duration);
 NSLog(@"视频的W -- %f ,视频的H -- %f", body.thumbnailSize.width, body.thumbnailSize.height);
 
 // 缩略图sdk会自动下载
 NSLog(@"缩略图的remote路径 -- %@"     ,body.thumbnailRemotePath);
 NSLog(@"缩略图的local路径 -- %@"      ,body.thumbnailLocalPath);
 NSLog(@"缩略图的secret -- %@"        ,body.thumbnailSecretKey);
 NSLog(@"缩略图的下载状态 -- %u"      ,body.thumbnailDownloadStatus);
 }
 break;
 case EMMessageBodyTypeFile:
 {
 EMFileMessageBody *body = (EMFileMessageBody *)msgBody;
 NSLog(@"文件remote路径 -- %@"      ,body.remotePath);
 NSLog(@"文件local路径 -- %@"       ,body.localPath); // 需要使用sdk提供的下载方法后才会存在
 NSLog(@"文件的secret -- %@"        ,body.secretKey);
 NSLog(@"文件文件大小 -- %lld"       ,body.fileLength);
 NSLog(@"文件文件的下载状态 -- %u"   ,body.downloadStatus);
 }
 break;
 
 default:
 break;
 }
 } */
- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
