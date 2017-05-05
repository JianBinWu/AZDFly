//
//  RootViewController.m
//  azdFly
//
//  Created by 吴剑斌 on 2017/5/2.
//  Copyright © 2017年 xmazd. All rights reserved.
//

#import "RootViewController.h"
#import <DJISDK/DJISDK.h>
#import <VideoPreviewer/VideoPreviewer.h>
#import <MAMapKit/MAMapKit.h>
#import <DJIUILibrary/DJIUILibrary.h>

//To use DJI Bridge app, change `ENTER_DEBUG_MODE` to 1 and add bridge app IP address in `debugIP` string.
#define ENTER_DEBUG_MODE 1

typedef NS_ENUM(NSInteger, CurrentMainWindow) {
    CurrentMainWindowCamera,
    CurrentMainWindowMap
};

@interface RootViewController ()<DJISDKManagerDelegate,DJICameraDelegate,DJIBaseProductDelegate,DJIVideoFeedListener,DJIPlaybackDelegate>

@property (weak, nonatomic) IBOutlet UIView *fpvPreviewView;
@property (weak, nonatomic) IBOutlet UIView *mapContainerView;
@property (strong, nonatomic) MAMapView *mapView;

@property (weak, nonatomic) IBOutlet NSLayoutConstraint *fpvPreviewViewHeightConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *fpvPreviewViewWidthConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *mapViewContainerHeightConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *mapViewContainerWidthConstraint;


@property (assign, nonatomic) CurrentMainWindow currentMainWindow;
@property (strong, nonatomic) NSMutableData *downloadedImageData;
@property (strong, nonatomic) NSMutableArray *downloadedImageArray;
@property (assign, nonatomic) CGSize currentSmallWinSize;
@property (strong, nonatomic) DULPreflightChecklistController *checklistController;
@property (weak, nonatomic) IBOutlet DULExposureSettingsMenu *exposureSettingMenu;
@property (weak, nonatomic) IBOutlet DULCameraSettingsMenu *cameraSettingsMenu;
@property (weak, nonatomic) IBOutlet UIView *cameraSettingContainer;
@property (weak, nonatomic) IBOutlet UIView *exposureSettingContainer;
@property (weak, nonatomic) IBOutlet DULCameraConfigInfoWidget *cameroInfoWidget;
@property (weak, nonatomic) IBOutlet DULCameraConfigStorageWidget *cameroStorageWidget;
@property (weak, nonatomic) IBOutlet UIView *rightSideBarView;

@end

@implementation RootViewController

#pragma mark - controller life cycle
- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self initData];
    [self initMapView];
    [[VideoPreviewer instance] setView:self.fpvPreviewView];
    
    [DJISDKManager registerAppWithDelegate:self];
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - rewrite methods
- (BOOL)prefersStatusBarHidden{
    return YES;
}

#pragma mark - Custom Methods

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

- (DJICamera *)fetchCamera{
    if (![DJISDKManager product]) {
        return nil;
    }
    
    if ([[DJISDKManager product] isKindOfClass:[DJIAircraft class]]) {
        return ((DJIAircraft *)[DJISDKManager product]).camera;
    }
    
    return nil;
    
}

- (void)initData{
    self.downloadedImageData = [NSMutableData data];
    self.downloadedImageArray = [NSMutableArray array];
    
    //init current main window camera
    self.currentMainWindow = CurrentMainWindowCamera;
    
    //init current small window size
    CGFloat widthRatio = (CGFloat)160 / 667;
    CGFloat heightRatio = (CGFloat)100 / 375;
    self.currentSmallWinSize = CGSizeMake(KScreen_Width * widthRatio, KScreen_Height * heightRatio);
    
    //init a checklist controller
    self.checklistController = [DULPreflightChecklistController preflightChecklistController];
    
    //implement camera and exposure setting menu's action block
    self.cameraSettingsMenu.action = ^(){
        DMLog(@"tap camera setting menu");
        self.cameraSettingContainer.hidden = !self.cameraSettingContainer.hidden;
        self.exposureSettingContainer.hidden = YES;
    };
    self.exposureSettingMenu.action = ^{
        DMLog(@"tap exposure setting menu");
        self.exposureSettingContainer.hidden = !self.exposureSettingContainer.hidden;
        self.cameraSettingContainer.hidden = YES;
    };
    
    
}

- (void)initPlaybackMultiSelectVC{
    
}

- (void)initMapView{
    self.mapView = [[MAMapView alloc] initWithFrame:self.mapContainerView.bounds];
    self.mapView.showsScale = NO;
    self.mapView.showsCompass = NO;
    [self.mapContainerView addSubview:self.mapView];
}

#pragma mark - event handler

/**
 switch current main window

 @param sender <#sender description#>
 */
- (IBAction)smallWindowBtnAction:(UIButton *)sender {
    sender.enabled = NO;
    DMLog(@"tap small window");
    if (self.currentMainWindow == CurrentMainWindowCamera) {
        self.rightSideBarView.hidden = YES;
        self.cameroInfoWidget.hidden = YES;
        self.cameroStorageWidget.hidden = YES;
        self.cameraSettingContainer.hidden = YES;
        self.exposureSettingContainer.hidden = YES;
        [UIView animateWithDuration:0.5 animations:^{
            self.mapViewContainerWidthConstraint.constant = KScreen_Width;
            self.mapViewContainerHeightConstraint.constant = KScreen_Height;
            [self.view layoutIfNeeded];
        } completion:^(BOOL finished) {
            self.fpvPreviewViewWidthConstraint.constant = self.currentSmallWinSize.width;
            self.fpvPreviewViewHeightConstraint.constant = self.currentSmallWinSize.height;
            [self.fpvPreviewView swapDepthsWithView:self.mapContainerView];
            self.currentMainWindow = CurrentMainWindowMap;
            
            sender.enabled = YES;
        }];
    }else{
        
        [UIView animateWithDuration:0.5 animations:^{
            self.fpvPreviewViewWidthConstraint.constant = KScreen_Width;
            self.fpvPreviewViewHeightConstraint.constant = KScreen_Height;
            [self.view layoutIfNeeded];
        } completion:^(BOOL finished) {
            self.mapViewContainerWidthConstraint.constant = self.currentSmallWinSize.width;
            self.mapViewContainerHeightConstraint.constant = self.currentSmallWinSize.height;
            [self.fpvPreviewView swapDepthsWithView:self.mapContainerView];
            self.currentMainWindow = CurrentMainWindowCamera;
            
            self.rightSideBarView.hidden = NO;
            self.cameroInfoWidget.hidden = NO;
            self.cameroStorageWidget.hidden = NO;
            
            sender.enabled = YES;
        }];
    }
}


/**
 show check list

 @param sender <#sender description#>
 */
- (IBAction)statusBtnAction:(id)sender {
    [self presentViewController:self.checklistController animated:YES completion:nil];
}

#pragma mark - DJISDKManagerDelegate
- (void)appRegisteredWithError:(NSError *_Nullable)error{
    if (error == nil) {
        DMLog(@"Registration Succeeded");
        [self connectToProduct];
        [[DJISDKManager videoFeeder].primaryVideoFeed addListener:self withQueue:nil];
        [[VideoPreviewer instance] start];
    }else{
        WLAlertController *alertController = [WLAlertController alertWithTitle:@"注册失败" message:@"请检查网络是否连接"];
        [self presentViewController:alertController animated:YES completion:nil];
    }
}

#pragma mark - DJIBaseProductDelegate
- (void)productConnected:(DJIBaseProduct *)product{
    if (product) {
        [product setDelegate:self];
        DJICamera *camera = [self fetchCamera];
        if (camera != nil) {
            camera.delegate = self;
            camera.playbackManager.delegate = self;
        }
    }
}

#pragma mark - DJIVideoFeedListenerDelegate
- (void)videoFeed:(DJIVideoFeed *)videoFeed didUpdateVideoData:(NSData *)videoData{
    [[VideoPreviewer instance] push:(uint8_t *)videoData.bytes length:(int)videoData.length];
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
