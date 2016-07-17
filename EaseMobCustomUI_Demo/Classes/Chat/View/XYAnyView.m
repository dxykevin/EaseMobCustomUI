//
//  XYAnyView.m
//  EaseMobCustomUI_Demo
//
//  Created by HoldCourt on 16/7/17.
//  Copyright © 2016年 HoldCourt. All rights reserved.
//

#import "XYAnyView.h"

#define kXYAnyViewSubViewHW ((kScreenWidth - 4 * kWeChatPadding) / 3)
@interface XYAnyView ()
/** 图片按钮 */
@property (nonatomic,strong) XYButton *imgBt;
/** 语音按钮 */
@property (nonatomic,strong) XYButton *voiceBt;
/** 视频按钮 */
@property (nonatomic,strong) XYButton *videoBt;
@end
@implementation XYAnyView

- (instancetype)initWithImageBlock:(void(^)())imageBlock voiceBlock:(void(^)())voiceBlock videoBlock:(void(^)())videoBlock {
    
    if (self = [super init]) {
        
        /** 添加子控件 */
        [self setupSubViews];
        
        /** 事件处理 */
        self.imgBt.block = ^(XYButton *bt) {
            
            if (imageBlock) {
                imageBlock();
            }
        };
        self.voiceBt.block = ^(XYButton *bt) {
            
            if (voiceBlock) {
                voiceBlock();
            }
        };
        self.videoBt.block = ^(XYButton *bt) {
            
            if (videoBlock) {
                videoBlock();
            }
        };
    }
    return self;
}

- (void)setupSubViews {
    
    self.backgroundColor = [UIColor grayColor];
    
    XYButton *imgBt = [XYButton createButton];
    imgBt.frame = CGRectMake(kWeChatPadding, kWeChatPadding, kXYAnyViewSubViewHW, kXYAnyViewSubViewHW);
    imgBt.backgroundColor = [UIColor redColor];
    [imgBt setTitle:@"图片" forState:(UIControlStateNormal)];
    [self addSubview:imgBt];
    
    XYButton *voiceBt = [XYButton createButton];
    voiceBt.frame = CGRectMake(kWeChatPadding + imgBt.right, kWeChatPadding, kXYAnyViewSubViewHW, kXYAnyViewSubViewHW);
    voiceBt.backgroundColor = [UIColor orangeColor];
    [voiceBt setTitle:@"语音" forState:(UIControlStateNormal)];
    [self addSubview:voiceBt];
    
    XYButton *videoBt = [XYButton createButton];
    videoBt.frame = CGRectMake(kWeChatPadding + voiceBt.right, kWeChatPadding, kXYAnyViewSubViewHW, kXYAnyViewSubViewHW);
    videoBt.backgroundColor = [UIColor purpleColor];
    [videoBt setTitle:@"视频" forState:(UIControlStateNormal)];
    [self addSubview:videoBt];
    
    self.imgBt = imgBt;
    self.voiceBt = voiceBt;
    self.videoBt = videoBt;
}
@end
