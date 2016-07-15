//
//  EaseLocalDefine.h
//  EaseMobCustomUI_Demo
//
//  Created by HoldCourt on 16/7/15.
//  Copyright © 2016年 HoldCourt. All rights reserved.
//

#ifndef EaseLocalDefine_h
#define EaseLocalDefine_h

#define NSEaseLocalizedString(key, comment) [[NSBundle bundleWithURL:[[NSBundle mainBundle] URLForResource:@"EaseUIResource" withExtension:@"bundle"]] localizedStringForKey:(key) value:@"" table:nil]

#endif /* EaseLocalDefine_h */
