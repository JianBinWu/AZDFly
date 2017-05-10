//
//  WLAlertController.h
//  azdFly
//
//  Created by 吴剑斌 on 2017/5/2.
//  Copyright © 2017年 xmazd. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface WLAlertController : UIAlertController

+ (instancetype)alertWithTitle:(NSString *)title message:(NSString *)message;

+ (instancetype)alertWithTitle:(NSString *)title message:(NSString *)message actionBlock:(void(^)(UIAlertAction *action))actionBlock;

@end
