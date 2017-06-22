//
//  AppSingleton.h
//  azdFly
//
//  Created by 吴剑斌 on 2017/5/5.
//  Copyright © 2017年 xmazd. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface AppSingleton : NSObject

@property (assign, nonatomic) CGFloat widthRatio;     //current screen's width / iphone6's screen's width
@property (assign, nonatomic) CGFloat heightRatio;    //current screen's height / iphone6's screen's height

+ (instancetype)sharedInstance;

@end
