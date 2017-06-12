//
//  Line.m
//  DJIUIDemo
//
//  Created by 吴剑斌 on 2017/5/15.
//  Copyright © 2017年 xmazd. All rights reserved.
//

#import "Line.h"

@implementation Line

- (void)setBeginPoint:(CGPoint)beginPoint{
    _beginPoint = beginPoint;
    _isBegin = YES;
}

- (void)setEndPoint:(CGPoint)endPoint{
    _endPoint = endPoint;
    _isBegin = NO;
    
    CGFloat real_xLength = ABS(_endPoint.x - _beginPoint.x);
    CGFloat real_yLength = ABS(_endPoint.y - _beginPoint.y);
    
    //reflect x y length in iphone6 size
    CGFloat xLength = real_xLength * 667.0 / KScreen_Width;
    CGFloat yLength = real_yLength * 375.0 / KScreen_Height;
    _length = Pythagorean(xLength,yLength) * 120 / 350;
    
}

@end
