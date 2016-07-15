//
//  XYChatViewCell.h
//  EaseMobCustomUI_Demo
//
//  Created by HoldCourt on 16/7/6.
//  Copyright © 2016年 HoldCourt. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface XYChatViewCell : UITableViewCell
/** 对应的message */
@property (nonatomic,strong) EMMessage *message;
/** cell高度 */
@property (nonatomic,assign) CGFloat cellHeight;
@end
