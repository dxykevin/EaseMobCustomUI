//
//  XYButton.m
//  EaseMobCustomUI_Demo
//
//  Created by HoldCourt on 16/7/6.
//  Copyright © 2016年 HoldCourt. All rights reserved.
//

#import "XYButton.h"

@implementation XYButton

- (instancetype)initWithFrame:(CGRect)frame {
    
    if (self = [super initWithFrame:frame]) {
        [self addTarget:self action:@selector(click:) forControlEvents:(UIControlEventTouchUpInside)];
    }
    return self;
}

- (void)click:(XYButton *)button {
    
    if (self.block) {
        self.block(button);
    }
}

+ (XYButton *)createButton {
    
    return [XYButton buttonWithType:(UIButtonTypeCustom)];
}
@end
