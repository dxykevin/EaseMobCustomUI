//
//  XYToolView.h
//  EaseMobCustomUI_Demo
//
//  Created by HoldCourt on 16/7/6.
//  Copyright © 2016年 HoldCourt. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "XYButton.h"
typedef enum {
    
    XYToolViewVoiceTypeStart,
    XYToolViewVoiceTypeStop,
    XYToolViewVoiceTypeCancel
} XYToolViewVoiceType;

typedef enum {
    
    XYToolViewEditTextViewTypeSend,
    XYToolViewEditTextViewTypeBegin
} XYToolViewEditTextViewType;

/** 发送消息的回调 */
typedef void(^XYToolViewSendTextBlock) (UITextView *,XYToolViewEditTextViewType);
/** 发送语音的回调 */
typedef void(^XYToolViewVoiceBlock) (XYButton *,XYToolViewVoiceType);
/** 点击更多按钮的回调 */
typedef void(^XYToolViewMoreBtBlock) ();
@protocol XYToolViewDelegate <NSObject>

- (void)toolViewWithType:(XYToolViewVoiceType)type button:(XYButton *)button;

@end
@interface XYToolView : UIView
/** 发送消息回调 */
@property (nonatomic,copy) XYToolViewSendTextBlock sendTextBlock;
/** 发送语音回调 */
@property (nonatomic,copy) XYToolViewVoiceBlock sendVoiceBlock;
/** 点击更多回调 */
@property (nonatomic,copy) XYToolViewMoreBtBlock moreBlock;
/** 代理 */
@property (nonatomic,assign) id<XYToolViewDelegate> delegate;
@end
