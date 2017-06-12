//
//  Line.h
//  DJIUIDemo
//
//  Created by 吴剑斌 on 2017/5/15.
//  Copyright © 2017年 xmazd. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
@interface Line : NSObject

@property (assign, nonatomic) CGPoint beginPoint;
@property (assign, nonatomic) CGPoint endPoint;
@property (assign, nonatomic) CGFloat length;
@property (assign, nonatomic) BOOL isBegin;

@end
