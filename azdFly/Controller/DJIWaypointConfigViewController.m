//
//  DJIWaypointConfigViewController.m
//  GSDemo
//
//  Created by 吴剑斌 on 2017/4/26.
//  Copyright © 2017年 xmazd. All rights reserved.
//

#import "DJIWaypointConfigViewController.h"

@interface DJIWaypointConfigViewController ()

@end

@implementation DJIWaypointConfigViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self initUI];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)initUI{
    self.altitudeTextField.text = @"100";
    self.autoFlightSpeedTextField.text = @"8";
    self.maxFlightSpeedTextField.text = @"10";
    [self.actionSegmentedControl setSelectedSegmentIndex:1];
    [self.headingSegmentedControl setSelectedSegmentIndex:0];
}

- (IBAction)cancelBtnAction:(id)sender {
    if ([_delegate respondsToSelector:@selector(cancelBtnActionInDJIWaypointConfigViewController:)]) {
        [_delegate cancelBtnActionInDJIWaypointConfigViewController:self];
    }
}

- (IBAction)finishBtnAction:(id)sender {
    if ([_delegate respondsToSelector:@selector(finishBtnActionInDJIWaypointConfigViewController:)]) {
        [_delegate finishBtnActionInDJIWaypointConfigViewController:self];
    }
}



/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
