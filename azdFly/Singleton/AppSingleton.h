//
//  AppSingleton.h
//  azdFly
//
//  Created by 吴剑斌 on 2017/5/5.
//  Copyright © 2017年 xmazd. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface AppSingleton : NSObject

@property (assign, nonatomic) CGFloat widthRatio;
@property (assign, nonatomic) CGFloat heightRatio;

+ (instancetype)sharedInstance;

@end