//
//  DJIPlaybackMultiSelectViewController.h
//  BridgeAppDemo
//
//  Created by 吴剑斌 on 2017/4/14.
//  Copyright © 2017年 xmazd. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface DJIPlaybackMultiSelectViewController : UIViewController

@property (copy, nonatomic) void (^selectItemBtnAction)(int index);
@property (copy, nonatomic) void (^swipeGestureAction)(UISwipeGestureRecognizerDirection direction);

@property (copy, nonatomic) void (^backBtnAction)();
@property (copy, nonatomic) void (^stopBtnAction)();
@property (copy, nonatomic) void (^multiPreBtnAction)();
@property (copy, nonatomic) void (^selectBtnAction)();
@property (copy, nonatomic) void (^allSelectBtnAction)();
@property (copy, nonatomic) void (^deleteBtnAction)();
@property (copy, nonatomic) void (^downloadBtnAction)();

- (void)updateUIWithPlaybackState:(DJICameraPlaybackState *)playbackState andPlayVideoBtn:(UIButton *)playVideoBtn;
- (void)changeSelectedState:(BOOL)isSelected;

@end
