//
//  XYToolView.m
//  EaseMobCustomUI_Demo
//
//  Created by HoldCourt on 16/7/6.
//  Copyright © 2016年 HoldCourt. All rights reserved.
//

#import "XYToolView.h"

@interface XYToolView () <UITextViewDelegate>
/** 语音按钮 */
@property (nonatomic, strong) XYButton *my_voiceBtn;

/** 文本输入框 */
@property (nonatomic, weak) UITextView *my_inputView;

/** 录音按钮 */
@property (nonatomic, weak) XYButton *my_sendVoiceBtn;

/** 更多按钮 */
@property (nonatomic, weak) XYButton *my_moreBtn;
@end

@implementation XYToolView

- (instancetype)initWithFrame:(CGRect)frame
{
    if (self = [super initWithFrame:frame]) {
        
//        self.backgroundColor = [UIColor redColor];
        
        // 添加子控件
        // 1. 语音按钮
        XYButton *voiceBtn = [XYButton createButton];
        [voiceBtn setImage:[UIImage imageNamed:@"ToolViewInputVoice"] forState:UIControlStateNormal];
        [voiceBtn setImage:[UIImage imageNamed:@"ToolViewInputVoiceHL"] forState:UIControlStateHighlighted];
        [self addSubview:voiceBtn];
        // 2. 文本输入框
        UITextView *inputView = [[UITextView alloc]init];
        inputView.backgroundColor = [UIColor whiteColor];
        inputView.font = [UIFont systemFontOfSize:15.0f];
        inputView.returnKeyType = UIReturnKeySend;
        inputView.delegate = self;
        [self addSubview:inputView];
        
        // 3. 录音按钮
        XYButton *sendVoiceBtn = [XYButton createButton];
        [sendVoiceBtn setTitle:@"按住录音" forState:UIControlStateNormal];
        [sendVoiceBtn setTitle:@"松开发送" forState:UIControlStateHighlighted];
        /** 开始录音 */
        [sendVoiceBtn addTarget:self action:@selector(startVoice:) forControlEvents:UIControlEventTouchDown];
        /** 结束录音 */
        [sendVoiceBtn addTarget:self action:@selector(stopVoice:) forControlEvents:UIControlEventTouchUpInside];
        /** 取消录音 */
        [sendVoiceBtn addTarget:self action:@selector(cancelVoice:) forControlEvents:UIControlEventTouchUpOutside];
        [self addSubview:sendVoiceBtn];
        sendVoiceBtn.hidden = YES;
        
        // 4. 更多按钮
        XYButton *moreBtn = [XYButton createButton];
        [moreBtn setImage:[UIImage imageNamed:@"ToolViewEmotion"] forState:UIControlStateNormal];
        [moreBtn setImage:[UIImage imageNamed:@"ToolViewEmotionHL"] forState:UIControlStateHighlighted];
        moreBtn.block = ^(XYButton *btn){
            if (self.moreBlock) {
                self.moreBlock();
            }
        };
        [self addSubview:moreBtn];
        
        // 赋值
        self.my_voiceBtn = voiceBtn;
        self.my_inputView = inputView;
        self.my_sendVoiceBtn = sendVoiceBtn;
        self.my_moreBtn = moreBtn;
        
        // 事件处理
        voiceBtn.block = ^(XYButton *btn){
            inputView.hidden = sendVoiceBtn.hidden;
            sendVoiceBtn.hidden = !inputView.hidden;
        };
    }
    return self;
}

// 按钮的点击事件
- (void)startVoice:(XYButton *)btn
{
    if (self.delegate && [self.delegate respondsToSelector:@selector(toolViewWithType:button:)]) {
        [self.delegate toolViewWithType:XYToolViewVoiceTypeStart button:btn];
    }
}

// 停止语音
- (void)stopVoice:(XYButton *)btn
{
    if (self.delegate && [self.delegate respondsToSelector:@selector(toolViewWithType:button:)]) {
        [self.delegate toolViewWithType:XYToolViewVoiceTypeStop button:btn];
    }
}

- (void)cancelVoice:(XYButton *)btn
{
    if (self.delegate && [self.delegate respondsToSelector:@selector(toolViewWithType:button:)]) {
        [self.delegate toolViewWithType:XYToolViewVoiceTypeCancel button:btn];
    }
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    self.my_voiceBtn.frame = CGRectMake(kWeChatPadding, kWeChatPadding/2 , self.height - kWeChatPadding , self.height - kWeChatPadding);
    
    self.my_inputView.frame = CGRectMake(self.my_voiceBtn.right + kWeChatPadding, self.my_voiceBtn.top, kWeChatScreenWidth - self.my_inputView.left*2, self.my_voiceBtn.height);
    
    self.my_sendVoiceBtn.frame = self.my_inputView.frame;
    
    self.my_moreBtn.frame = CGRectMake(self.my_inputView.right + kWeChatPadding, self.my_voiceBtn.top, self.my_voiceBtn.width, self.my_voiceBtn.height);
}


#pragma mark - UITextViewDelegate
- (void)textViewDidChange:(UITextView *)textView
{
    if (textView.text.length == 0) return;
    
    // 点击了完成按钮
    if ([textView.text hasSuffix:@"\n"]) {
        if (_sendTextBlock) {
            _sendTextBlock(textView,XYToolViewEditTextViewTypeSend);
        }
        [textView resignFirstResponder];
    }
}

- (BOOL)textViewShouldBeginEditing:(UITextView *)textView
{
    if (_sendTextBlock) {
        self.sendTextBlock(textView,XYToolViewEditTextViewTypeBegin);
    }
    return YES;
}
@end
