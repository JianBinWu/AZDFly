//
//  RootViewController.m
//  azdFly
//
//  Created by 吴剑斌 on 2017/5/2.
//  Copyright © 2017年 xmazd. All rights reserved.
//

#import "RootViewController.h"
#import <DJISDK/DJISDK.h>

//To use DJI Bridge app, change `ENTER_DEBUG_MODE` to 1 and add bridge app IP address in `debugIP` string.
#define ENTER_DEBUG_MODE 1

@interface RootViewController ()<DJISDKManagerDelegate>

@end

@implementation RootViewController

#pragma mark - controller life cycle
- (void)viewDidLoad {
    [super viewDidLoad];
    
    //注册app
    [DJISDKManager registerAppWithDelegate:self];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)connectToProduct{
    if (ENTER_DEBUG_MODE) {
        NSString *debugIP = @"10.0.1.91";
        DMLog(@"Connecting to Product using debug IP address:%@",debugIP);
        [DJISDKManager enableBridgeModeWithBridgeAppIP:debugIP];
    }else{
        DMLog(@"Connecting to product...");
        [DJISDKManager startConnectionToProduct];
    }
}

#pragma mark - DJISDKManagerDelegate
- (void)appRegisteredWithError:(NSError *_Nullable)error{
    if (error == nil) {
        DMLog(@"Registration Succeeded");
        [self connectToProduct];
    }else{
        WLAlertController *alertController = [WLAlertController alertWithTitle:@"注册失败" message:error.description];
        [self presentViewController:alertController animated:YES completion:nil];
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
