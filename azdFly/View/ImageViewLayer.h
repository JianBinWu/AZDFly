//
//  ImageViewLayer.h
//  DJIUIDemo
//
//  Created by 吴剑斌 on 2017/5/12.
//  Copyright © 2017年 xmazd. All rights reserved.
//

#import <QuartzCore/QuartzCore.h>
#import <UIKit/UIKit.h>

@interface ImageViewLayer : CALayer

@property (strong, nonatomic) NSMutableArray *lineArr;
@property (assign, nonatomic) CGFloat shootedHeight;

@end
