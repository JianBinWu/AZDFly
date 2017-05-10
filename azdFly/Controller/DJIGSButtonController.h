//
//  DJIGSButtonController.h
//  GSDemo
//
//  Created by 吴剑斌 on 2017/4/26.
//  Copyright © 2017年 xmazd. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef NS_ENUM(NSUInteger, DJIGSViewMode) {
    DJIGSViewMode_ViewMode,
    DJIGSViewMode_EditMode,
};

@class DJIGSButtonController;
@protocol DJIGSButtonControllerDelegate <NSObject>

- (void)stopBtnActionInGSButtonVC:(DJIGSButtonController *)GSBtnVC;
- (void)clearBtnActionInGSButtonVC:(DJIGSButtonController *)GSBtnVC;
- (void)focusMapBtnActionInGSButtonVC:(DJIGSButtonController *)GSBtnVC;
- (void)startBtnActionInGSButtonVC:(DJIGSButtonController *)GSBtnVC;
- (void)addBtn:(UIButton *)button withActionInGSButtonVC:(DJIGSButtonController *)GSBtnVC;
- (void)configBtnActionInGSButtonVC:(DJIGSButtonController *)GSBtnVC;
- (void)switchToMode:(DJIGSViewMode)mode inGSButtonVC:(DJIGSButtonController *)GSBtnVC;

@end

@interface DJIGSButtonController : UIViewController

@property (weak, nonatomic) IBOutlet UIButton *backBtn;
@property (weak, nonatomic) IBOutlet UIButton *addBtn;
@property (weak, nonatomic) IBOutlet UIButton *focusMapBtn;
@property (weak, nonatomic) IBOutlet UIButton *clearBtn;
@property (weak, nonatomic) IBOutlet UIButton *configBtn;
@property (weak, nonatomic) IBOutlet UIButton *startBtn;
@property (weak, nonatomic) IBOutlet UIButton *stopBtn;
@property (weak, nonatomic) IBOutlet UIButton *editBtn;
@property (assign, nonatomic) DJIGSViewMode mode;
@property (weak, nonatomic) id <DJIGSButtonControllerDelegate> delegate;



@end
