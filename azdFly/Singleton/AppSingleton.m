//
//  AppSingleton.m
//  azdFly
//
//  Created by 吴剑斌 on 2017/5/5.
//  Copyright © 2017年 xmazd. All rights reserved.
//

#import "AppSingleton.h"

@implementation AppSingleton
static AppSingleton *instance = nil;
+ (instancetype)sharedInstance
{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        instance = [[[self class] alloc] init];
        instance.widthRatio = KScreen_Width / 667;
        instance.heightRatio = KScreen_Height / 375;
    });
    return instance;
}

+ (instancetype)allocWithZone:(struct _NSZone *)zone
{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        instance = [super allocWithZone:zone];
    });
    return instance;
}
@end
