//
//  UIView+Z_Order.h
//  azdFly
//
//  Created by 吴剑斌 on 2017/5/3.
//  Copyright © 2017年 xmazd. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIView (Z_Order)

- (int)getSubviewIndex;

- (void)bringToFront;
- (void)sendToBack;

- (void)bringOneLevelUp;
- (void)sendOneLevelDown;

- (BOOL)isInFront;
- (BOOL)isAtBack;

- (void)swapDepthsWithView:(UIView *)swapView;

@end
