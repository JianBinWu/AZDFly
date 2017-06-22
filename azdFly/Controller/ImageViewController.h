//
//  ImageViewController.h
//  DJIUIDemo
//
//  Created by 吴剑斌 on 2017/5/12.
//  Copyright © 2017年 xmazd. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ImageViewController : UIViewController

@property (strong, nonatomic) PHAsset *asset;

- (void)initImage:(UIImage *)image;
    
@end
