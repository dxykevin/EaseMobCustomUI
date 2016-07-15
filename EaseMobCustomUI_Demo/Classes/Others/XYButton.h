//
//  XYButton.h
//  EaseMobCustomUI_Demo
//
//  Created by HoldCourt on 16/7/6.
//  Copyright © 2016年 HoldCourt. All rights reserved.
//

#import <UIKit/UIKit.h>
@class XYButton;
typedef void(^XYButtonClickedBlock) (XYButton *);
@interface XYButton : UIButton
/** block */
@property (nonatomic,copy) XYButtonClickedBlock block;
/** 创建自定义button */
+ (XYButton *)createButton;
@end
