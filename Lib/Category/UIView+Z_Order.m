//
//  UIView+Z_Order.m
//  azdFly
//
//  Created by 吴剑斌 on 2017/5/3.
//  Copyright © 2017年 xmazd. All rights reserved.
//

#import "UIView+Z_Order.h"

@implementation UIView (Z_Order)

- (int)getSubviewIndex{
    return (int)[self.superview.subviews indexOfObject:self];
}

- (void)bringToFront{
    [self.superview bringSubviewToFront:self];
}

- (void)sendToBack{
    [self.superview sendSubviewToBack:self];
}

- (void)bringOneLevelUp{
    int currentIndex = [self getSubviewIndex];
    [self.superview exchangeSubviewAtIndex:currentIndex withSubviewAtIndex:currentIndex + 1];
}

- (void)sendOneLevelDown{
    int currentIndex = [self getSubviewIndex];
    [self.superview exchangeSubviewAtIndex:currentIndex withSubviewAtIndex:currentIndex - 1];
}

- (BOOL)isInFront{
    return [self.superview.subviews lastObject] == self;
}

- (BOOL)isAtBack{
    return [self.superview.subviews objectAtIndex:0] == self;
}

- (void)swapDepthsWithView:(UIView *)swapView{
    [self.superview exchangeSubviewAtIndex:[self getSubviewIndex] withSubviewAtIndex:[swapView getSubviewIndex]];
}
@end
