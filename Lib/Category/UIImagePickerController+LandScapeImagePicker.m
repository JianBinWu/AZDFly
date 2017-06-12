//
//  UIImagePickerController+LandScapeImagePicker.m
//  DJIUIDemo
//
//  Created by 吴剑斌 on 2017/6/12.
//  Copyright © 2017年 xmazd. All rights reserved.
//

#import "UIImagePickerController+LandScapeImagePicker.h"

@implementation UIImagePickerController (LandScapeImagePicker)

- (BOOL)shouldAutorotate{
    return YES;
}

- (UIInterfaceOrientationMask)supportedInterfaceOrientations{
    return UIInterfaceOrientationMaskLandscape;
}

@end
