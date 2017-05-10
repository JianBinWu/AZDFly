//
//  DJIWaypointConfigViewController.h
//  GSDemo
//
//  Created by 吴剑斌 on 2017/4/26.
//  Copyright © 2017年 xmazd. All rights reserved.
//

#import <UIKit/UIKit.h>

@class DJIWaypointConfigViewController;
@protocol DJIWaypointConfigViewControllerDelegate <NSObject>

- (void)cancelBtnActionInDJIWaypointConfigViewController:(DJIWaypointConfigViewController *)waypointConfigVC;
- (void)finishBtnActionInDJIWaypointConfigViewController:(DJIWaypointConfigViewController *)waypointConfigVC;

@end

@interface DJIWaypointConfigViewController : UIViewController
@property (weak, nonatomic) IBOutlet UITextField *altitudeTextField;
@property (weak, nonatomic) IBOutlet UITextField *autoFlightSpeedTextField;
@property (weak, nonatomic) IBOutlet UITextField *maxFlightSpeedTextField;
@property (weak, nonatomic) IBOutlet UISegmentedControl *actionSegmentedControl;
@property (weak, nonatomic) IBOutlet UISegmentedControl *headingSegmentedControl;
@property (weak, nonatomic) id <DJIWaypointConfigViewControllerDelegate> delegate;


@end
