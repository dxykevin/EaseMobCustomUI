//
//  XYChatViewCell.h
//  EaseMobCustomUI_Demo
//
//  Created by HoldCourt on 16/7/6.
//  Copyright © 2016年 HoldCourt. All rights reserved.
//

#import <UIKit/UIKit.h>


@protocol XYChatViewCellShowImageDelegate <NSObject>

/** 显示大图片 */
- (void)chatCellWithMessage:(EMMessage *)message;

@end
@interface XYChatViewCell : UITableViewCell
/** 对应的message */
@property (nonatomic,strong) EMMessage *message;
/** cell高度 */
@property (nonatomic,assign) CGFloat cellHeight;
@property (nonatomic,weak) id<XYChatViewCellShowImageDelegate> delegate;

/** 根据消息返回cell的高度 */
+ (CGFloat)cellHeightForRowWithMessage:(EMMessage *)message;
@end
