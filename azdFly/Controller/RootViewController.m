//
//  RootViewController.m
//  azdFly
//
//  Created by 吴剑斌 on 2017/5/2.
//  Copyright © 2017年 xmazd. All rights reserved.
//

#import "RootViewController.h"
#import <VideoPreviewer/VideoPreviewer.h>
#import <DJIUILibrary/DJIUILibrary.h>
#import "DJIPlaybackMultiSelectViewController.h"
#import "DJIMapController.h"
#import "DJIGSButtonController.h"
#import "DJIWaypointConfigViewController.h"


//To use DJI Bridge app, change `ENTER_DEBUG_MODE` to 1 and add bridge app IP address in `debugIP` string.
#define ENTER_DEBUG_MODE 0

typedef NS_ENUM(NSInteger, CurrentMainWindow) {
    CurrentMainWindowCamera,
    CurrentMainWindowMap
};

@interface RootViewController ()<DJISDKManagerDelegate,DJICameraDelegate,DJIBaseProductDelegate,DJIVideoFeedListener,DJIPlaybackDelegate,DJIPlaybackDelegate,DJIFlightControllerDelegate,DJIGSButtonControllerDelegate,DJIWaypointConfigViewControllerDelegate,MAMapViewDelegate>

@property (weak, nonatomic) IBOutlet UIView *fpvPreviewView;
@property (weak, nonatomic) IBOutlet UIView *mapContainerView;
@property (weak, nonatomic) IBOutlet DULExposureSettingsMenu *exposureSettingMenu;
@property (weak, nonatomic) IBOutlet DULCameraSettingsMenu *cameraSettingsMenu;
@property (weak, nonatomic) IBOutlet UIView *cameraSettingContainer;
@property (weak, nonatomic) IBOutlet UIView *exposureSettingContainer;
@property (weak, nonatomic) IBOutlet DULCameraConfigInfoWidget *cameraInfoWidget;
@property (weak, nonatomic) IBOutlet DULCameraConfigStorageWidget *cameraStorageWidget;
@property (weak, nonatomic) IBOutlet DULPreFlightStatusWidget *preFlightStatusWidget;
@property (weak, nonatomic) IBOutlet UIView *statusBarView;
@property (weak, nonatomic) IBOutlet UIView *leftSideBarView;
@property (weak, nonatomic) IBOutlet UIView *bottomBarView;
@property (weak, nonatomic) IBOutlet UIView *rightSideBarView;
@property (weak, nonatomic) IBOutlet UIButton *smallWindowBtn;
@property (weak, nonatomic) IBOutlet UIButton *playVideoBtn;



@property (weak, nonatomic) IBOutlet NSLayoutConstraint *fpvPreviewViewHeightConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *fpvPreviewViewWidthConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *mapViewContainerHeightConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *mapViewContainerWidthConstraint;


@property (assign, nonatomic) CurrentMainWindow currentMainWindow;
@property (strong, nonatomic) NSMutableData *downloadedImageData;
@property (strong, nonatomic) NSMutableArray *downloadedImageArray;
@property (assign, nonatomic) CGSize currentSmallWinSize;
@property (assign, nonatomic) CGFloat originalMapLogoCenterX;
@property (strong, nonatomic) DJICameraPlaybackState *cameraPlaybackState;
@property (strong, nonatomic) DJICameraSystemState *cameraSystemState;
@property (assign, nonatomic) int selectedFileCount;
@property (strong, nonatomic) NSError *downloadImageError;
@property (strong, nonatomic) NSString *targetFileName;
@property (assign, nonatomic) DJIDownloadFileType fileType;
@property (assign, nonatomic) long totalFileSize;
@property (assign, nonatomic) long currentDownloadSize;
@property (assign, nonatomic) int downloadedFileCount;
@property (strong, nonatomic) NSTimer *updateImageDownloadTimer;

@property (strong, nonatomic) DULPreflightChecklistController *checklistController;
@property (strong, nonatomic) DJIPlaybackMultiSelectViewController *playbackMultiSelectVC;
@property (strong, nonatomic) UIAlertController *downloadAlertController;

//map property
@property (strong, nonatomic) MAMapView *mapView;
@property (strong, nonatomic) DJIMapController *mapController;
@property (strong, nonatomic) UITapGestureRecognizer *tapGesture;
@property (assign, nonatomic) BOOL isEditingPoints;
@property (assign, nonatomic) CLLocationCoordinate2D userLocation;
@property (assign, nonatomic) CLLocationCoordinate2D droneLocation;
@property (strong, nonatomic) DJIGSButtonController *gsButtonVC;
@property (strong, nonatomic) DJIWaypointConfigViewController *waypointConfigVC;
@property (strong, nonatomic) DJIMutableWaypointMission *waypointMission;
@property (strong, nonatomic) MAAnnotationView *userLocationAnnotationView;

@end

@implementation RootViewController

#pragma mark - controller life cycle

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self initData];
    [self initEventHandler];
    [self initPlaybackMultiSelectVC];
    [self initMapViewAndUI];
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

- (UIInterfaceOrientationMask)supportedInterfaceOrientations{
    return UIInterfaceOrientationMaskLandscape;
}

- (void)updateViewConstraints{
    //layout gsButtonVC
    NSUInteger gsButtonVCWidth = 100;
    NSUInteger gsButtonVCHeight = 254;
    [self.gsButtonVC.view makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.statusBarView.bottom);
        make.right.equalTo(self.view.right);
        make.width.equalTo(@(gsButtonVCWidth));
        make.height.equalTo(@(gsButtonVCHeight));
    }];
    
    //layout waypointConfigVCWidth
    NSUInteger waypointConfigVCWidth = 400;
    NSUInteger waypointConfigVCHeight = 293;
    [self.waypointConfigVC.view makeConstraints:^(MASConstraintMaker *make) {
        make.center.equalTo(self.view);
        make.size.mas_equalTo(CGSizeMake(waypointConfigVCWidth, waypointConfigVCHeight));
        
    }];
    
    //init current small window size
    CGFloat widthRatio = (CGFloat)160 / 667;
    CGFloat heightRatio = (CGFloat)100 / 375;
    self.currentSmallWinSize = CGSizeMake(KScreen_Width * widthRatio, KScreen_Height * heightRatio);
    
    [super updateViewConstraints];
}

#pragma mark - Custom Methods
- (DJIFlightController *)fetchFlightController{
    if (![DJISDKManager product]) {
        return nil;
    }
    
    if ([[DJISDKManager product] isKindOfClass:[DJIAircraft class]]) {
        return ((DJIAircraft *)[DJISDKManager product]).flightController;
    }
    
    return nil;
}

- (DJIWaypointMissionOperator *)missionOperator{
    return [DJISDKManager missionControl].waypointMissionOperator;
}

- (void)saveDownloadImage{
    if (self.downloadedImageArray && self.downloadedImageArray.count > 0) {
        UIImage *image = [self.downloadedImageArray lastObject];
        UIImageWriteToSavedPhotosAlbum(image, self, @selector(image:didFinishSavingWithError:contextInfo:), nil);
    }else{
        [self.downloadAlertController dismissViewControllerAnimated:YES completion:nil];
    }
}

- (void)image:(UIImage *)image didFinishSavingWithError:(NSError *)error contextInfo:(void *)contextInfo{
    if (error != NULL) {
        [self.downloadAlertController dismissViewControllerAnimated:YES completion:nil];
        WLAlertController *alertController = [WLAlertController alertWithTitle:@"存储图片失败" message:error.description];
        [self presentViewController:alertController animated:YES completion:nil];
    }else{
        [self.downloadedImageArray removeLastObject];
        if (self.downloadedImageArray) {
            [self saveDownloadImage];
            
            if (self.downloadedImageArray.count == 0) {
                WLAlertController *alertController = [WLAlertController alertWithTitle:@"照片已存储到相册" message:@""];
                [self presentViewController:alertController animated:YES completion:nil];
            }
        }
    }
}

- (void)startUpdateTimer{
    if (self.updateImageDownloadTimer == nil) {
        self.updateImageDownloadTimer = [NSTimer scheduledTimerWithTimeInterval:0.5 target:self selector:@selector(updateDownloadProgress:) userInfo:nil repeats:YES];
    }
}

- (void)stopTimer{
    if (self.updateImageDownloadTimer != nil) {
        [self.updateImageDownloadTimer invalidate];
        self.updateImageDownloadTimer = nil;
    }
}

- (void)downloadFiles{
    [self resetDownloadData];
    
    if (self.cameraPlaybackState.playbackMode == DJICameraPlaybackModeSingleFilePreview) {
        self.selectedFileCount = 1;
    }
    WeakRef(target);
    __weak DJICamera *camera = [self fetchCamera];
    self.downloadAlertController = [UIAlertController alertControllerWithTitle:@"Waiting for download" message:@"" preferredStyle:UIAlertControllerStyleAlert];
    [self presentViewController:target.downloadAlertController animated:YES completion:nil];
    [camera.playbackManager downloadSelectedFilesWithPreparation:^(NSString * _Nullable fileName, DJIDownloadFileType fileType, NSUInteger fileSize, BOOL * _Nonnull skip) {
        WeakRef(target);
        [target startUpdateTimer];
        target.totalFileSize = (long)fileSize;
        target.targetFileName = fileName;
        target.fileType = fileType;
        NSString *title = [NSString stringWithFormat:@"下载(%d/%d)",target.downloadedFileCount + 1, target.selectedFileCount];
        NSString *message = [NSString stringWithFormat:@"文件名:%@, 文件大小:%0.1fKB, 已下载:0.0KB",fileName,target.totalFileSize / 1024.0];
        target.downloadAlertController.title = title;
        target.downloadAlertController.message = message;
        
    } process:^(NSData * _Nullable data, NSError * _Nullable error) {
        WeakReturn(target);
        if (data) {
            [target.downloadedImageData appendData:data];
            target.currentDownloadSize += data.length;
        }
        target.downloadImageError = error;
    } fileCompletion:^{
        WeakReturn(target);
        target.downloadedFileCount++;
        if (target.fileType == DJIDownloadFileTypePhoto || target.fileType == DJIDownloadFileTypeRAWDNG) {
            UIImage *downloadImage = [[UIImage alloc] initWithData:target.downloadedImageData];
            if (downloadImage) {
                [target.downloadedImageArray addObject:downloadImage];
            }
        }
        
        [target.downloadedImageData setData:[NSData dataWithBytes:NULL length:0]];
        target.currentDownloadSize = 0.0f;
        
        NSString *title = [NSString stringWithFormat:@"下载(%d/%d)",target.downloadedFileCount, target.selectedFileCount];
        target.downloadAlertController.title = title;
        target.downloadAlertController.message = @"已完成";
        
        if (target.downloadedFileCount == target.selectedFileCount) {
            [target stopTimer];
            [target.playbackMultiSelectVC changeSelectedState:NO];
            target.downloadAlertController.title = @"存储照片到相册中...";
            target.downloadAlertController.message = @"";
            [target saveDownloadImage];
        }
        
    } overallCompletion:^(NSError * _Nullable error) {
        DMLog(@"DownloadFile Error %@",error.description);
    }];
    
}

- (void)resetDownloadData{
    self.downloadImageError = nil;
    self.totalFileSize = 0;
    self.currentDownloadSize = 0;
    self.downloadedFileCount = 0;
    
    [self.downloadedImageData setData:[NSData dataWithBytes:NULL length:0]];
    [self.downloadedImageArray removeAllObjects];
}

- (void)connectToProduct{
    if (ENTER_DEBUG_MODE) {
        NSString *debugIP = @"10.0.1.177";
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
    
    //init a checklist controller
    self.checklistController = [DULPreflightChecklistController preflightChecklistController];
    
    //init map data
    self.userLocation = kCLLocationCoordinate2DInvalid;
    self.droneLocation = kCLLocationCoordinate2DInvalid;
    
    self.mapController = [[DJIMapController alloc] init];
}

- (void)initEventHandler{
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
    
    //init a tap gesture for preflight status widget
    UITapGestureRecognizer *tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(preFlightStatusWidgetTapAction:)];
    [self.preFlightStatusWidget addGestureRecognizer:tapGesture];
}

- (void)initPlaybackMultiSelectVC{
    self.playbackMultiSelectVC = [[DJIPlaybackMultiSelectViewController alloc] initWithNibName:@"DJIPlaybackMultiSelectViewController" bundle:[NSBundle mainBundle]];
    
    [self.playbackMultiSelectVC.view setFrame:self.view.frame];
    [self.view insertSubview:self.playbackMultiSelectVC.view aboveSubview:self.fpvPreviewView];
    
    WeakRef(target);
    //photo select block
    [self.playbackMultiSelectVC setSelectItemBtnAction:^(int index){
        WeakReturn(target);
        __weak DJICamera *camera = [target fetchCamera];
        if (self.cameraPlaybackState.playbackMode == DJICameraPlaybackModeMultipleFilesPreview) {
            [camera.playbackManager enterSinglePreviewModeWithIndex:index];
        }else if(target.cameraPlaybackState.playbackMode == DJICameraPlaybackModeMultipleFilesEdit){
            [camera.playbackManager toggleFileSelectionAtIndex:index];
        }
    }];
    
    //gesture block
    [self.playbackMultiSelectVC setSwipeGestureAction:^(UISwipeGestureRecognizerDirection direction){
        WeakReturn(target);
        __weak DJICamera *camera = [target fetchCamera];
        if (target.cameraPlaybackState.playbackMode == DJICameraPlaybackModeSingleFilePreview) {
            if (direction == UISwipeGestureRecognizerDirectionLeft) {
                [camera.playbackManager goToNextSinglePreviewPage];
            }else if (direction == UISwipeGestureRecognizerDirectionRight){
                [camera.playbackManager goToPreviousSinglePreviewPage];
            }
        }else if (target.cameraPlaybackState.playbackMode == DJICameraPlaybackModeMultipleFilesPreview){
            if (direction == UISwipeGestureRecognizerDirectionUp) {
                [camera.playbackManager goToNextMultiplePreviewPage];
            }else if (direction == UISwipeGestureRecognizerDirectionDown){
                [camera.playbackManager goToPreviousMultiplePreviewPage];
            }
        }
    }];
    
    //back btn block
    [self.playbackMultiSelectVC setBackBtnAction:^{
        WeakReturn(target);
        __weak DJICamera *camera = [target fetchCamera];
        [camera setMode:DJICameraModeShootPhoto withCompletion:^(NSError * _Nullable error) {
            WeakReturn(target);
            if (!target.playVideoBtn.hidden) {
                [target.playVideoBtn setHidden:YES];
            }
            if (error) {
                DMLog(@"%@", error.description);
            }
        }];
        
    }];
    
    //stop btn block
    [self.playbackMultiSelectVC setStopBtnAction:^{
        WeakReturn(target);
        __weak DJICamera *camera = [target fetchCamera];
        if (self.cameraPlaybackState.fileType == DJICameraPlaybackFileTypeVIDEO) {
            if (self.cameraPlaybackState.videoPlayProgress > 0) {
                [camera.playbackManager stopVideo];
            }
        }
    }];
    
    //multi preview block
    [self.playbackMultiSelectVC setMultiPreBtnAction:^{
        WeakReturn(target);
        __weak DJICamera *camera = [target fetchCamera];
        [camera.playbackManager enterMultiplePreviewMode];
    }];
    
    //select btn block
    [self.playbackMultiSelectVC setSelectBtnAction:^{
        WeakReturn(target);
        __weak DJICamera *camera = [target fetchCamera];
        if (self.cameraPlaybackState.playbackMode == DJICameraPlaybackModeMultipleFilesEdit) {
            [camera.playbackManager exitMultipleEditMode];
        }else{
            [camera.playbackManager enterMultipleEditMode];
        }
    }];
    
    //select all btn block
    [self.playbackMultiSelectVC setAllSelectBtnAction:^{
        WeakReturn(target);
        __weak DJICamera *camera = [target fetchCamera];
        if (target.cameraPlaybackState.isAllFilesInPageSelected) {
            [camera.playbackManager unselectAllFilesInPage];
        }else{
            [camera.playbackManager selectAllFilesInPage];
        }
    }];
    
    //delete btn block
    [self.playbackMultiSelectVC setDeleteBtnAction:^{
        WeakReturn(target);
        __weak DJICamera *camera = [target fetchCamera];
        target.selectedFileCount = target.cameraPlaybackState.selectedFileCount;
        if (self.cameraPlaybackState.playbackMode == DJICameraPlaybackModeMultipleFilesEdit) {
            if (self.selectedFileCount == 0) {
                WLAlertController *alertController = [WLAlertController alertWithTitle:@"请选择要删除的文件" message:nil];
                [target presentViewController:alertController animated:YES completion:nil];
            }else{
                WLAlertController *alertController = [WLAlertController alertWithTitle:@"是否删除选中文件" message:nil
                                                                           actionBlock:^(UIAlertAction *action) {
                                                                               [camera.playbackManager deleteAllSelectedFiles];
                                                                               [target.playbackMultiSelectVC changeSelectedState:NO];
                                                                           }];
                [target presentViewController:alertController animated:YES completion:nil];
            }
        }else if (self.cameraPlaybackState.playbackMode == DJICameraPlaybackModeSingleFilePreview){
            WLAlertController *alertController = [WLAlertController alertWithTitle:@"删除当前文件吗" message:@"" actionBlock:^(UIAlertAction *action) {
                [camera.playbackManager deleteCurrentPreviewFile];
            }];
            [target presentViewController:alertController animated:YES completion:nil];
        }
    }];
    
    //download btn block
    [self.playbackMultiSelectVC setDownloadBtnAction:^{
        WeakReturn(target);
        target.selectedFileCount = target.cameraPlaybackState.selectedFileCount;
        if (self.cameraPlaybackState.playbackMode == DJICameraPlaybackModeMultipleFilesEdit) {
            if (self.selectedFileCount == 0) {
                WLAlertController *alertController = [WLAlertController alertWithTitle:@"请选择要下载的文件" message:@""];
                [target presentViewController:alertController animated:YES completion:nil];
            }else{
                WLAlertController *alertController = [WLAlertController alertWithTitle:@"是否下载选中的文件" message:@"" actionBlock:^(UIAlertAction *action) {
                    [target downloadFiles];
                }];
                [target presentViewController:alertController animated:YES completion:nil];
            }
        }else if(self.cameraPlaybackState.playbackMode == DJICameraPlaybackModeSingleFilePreview){
            WLAlertController *alertController = [WLAlertController alertWithTitle:@"下载当前文件" message:@"" actionBlock:^(UIAlertAction *action) {
                [target downloadFiles];
            }];
            [target presentViewController:alertController animated:YES completion:nil];
        }
    }];
    
    self.playbackMultiSelectVC.view.hidden = YES;
}


- (void)initMapViewAndUI{
    
    [AMapServices sharedServices].enableHTTPS = YES;
    
    self.mapView = [[MAMapView alloc] initWithFrame:self.mapContainerView.bounds];
    self.mapView.delegate = self;
    self.mapView.showsScale = NO;
    self.mapView.showsCompass = NO;
    [self.mapContainerView addSubview:self.mapView];
    
    self.tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(addWaypoints:)];
    [self.mapView addGestureRecognizer:self.tapGesture];
    
    //show location
    self.mapView.showsUserLocation = YES;
    self.mapView.userTrackingMode = MAUserTrackingModeFollow;
    
    
    
    //change map logo center
    self.originalMapLogoCenterX = self.mapView.logoCenter.x;
//    self.mapView.logoCenter = CGPointMake(self.mapView.bounds.size.width - self.originalMapLogoCenterX, self.mapView.logoCenter.y);
    
    self.gsButtonVC = [[DJIGSButtonController alloc] initWithNibName:@"DJIGSButtonController" bundle:[NSBundle mainBundle]];
    self.gsButtonVC.view.alpha = 0;
    self.gsButtonVC.delegate = self;
    [self.view addSubview:self.gsButtonVC.view];
    
    self.waypointConfigVC = [[DJIWaypointConfigViewController alloc] initWithNibName:@"DJIWaypointConfigViewController" bundle:[NSBundle mainBundle]];
    self.waypointConfigVC.view.alpha = 0;
    
    self.waypointConfigVC.delegate = self;
    [self.view addSubview:self.waypointConfigVC.view];

}

- (void)switchPlaybackAndCamera:(BOOL)isPlayback{
    if (self.currentMainWindow == CurrentMainWindowCamera) {
        self.statusBarView.hidden = isPlayback;
        self.leftSideBarView.hidden = isPlayback;
        self.bottomBarView.hidden = isPlayback;
        self.rightSideBarView.hidden = isPlayback;
        self.cameraStorageWidget.hidden = isPlayback;
        self.cameraInfoWidget.hidden = isPlayback;
        self.mapContainerView.hidden = isPlayback;
        self.smallWindowBtn.hidden = isPlayback;
        self.playbackMultiSelectVC.view.hidden = !isPlayback;
    }
    
}

#pragma mark - event handler
- (IBAction)settingBtnAction:(id)sender {
    DMLog(@"%f,%f",self.gsButtonVC.view.frame.size.width,self.gsButtonVC.view.frame.size.height);
}

- (void)focusMap{
    if (CLLocationCoordinate2DIsValid(self.droneLocation)) {
        MACoordinateRegion region = {0};
        region.center = self.droneLocation;
        region.span.latitudeDelta = 0.001;
        region.span.longitudeDelta = 0.001;
        
        [self.mapView setRegion:region animated:YES];
    }
}

- (void)addWaypoints:(UITapGestureRecognizer *)tapGesture{
    CGPoint point = [tapGesture locationInView:self.mapView];
    
    if (tapGesture.state == UIGestureRecognizerStateEnded) {
        if (self.isEditingPoints) {
            [self.mapController addPoint:point withMapView:self.mapView];
        }
    }
}

- (void)updateDownloadProgress:(NSTimer *)updatedTimer{
    if (self.downloadImageError) {
        [self stopTimer];
        [self.playbackMultiSelectVC changeSelectedState:NO];
        [self.downloadAlertController dismissViewControllerAnimated:YES completion:nil];
        WLAlertController *alertController = [WLAlertController alertWithTitle:@"下载错误" message:self.downloadImageError.description];
        [self presentViewController:alertController animated:YES completion:nil];
    }else{
        NSString *title = [NSString stringWithFormat:@"下载 (%d/%d)", self.downloadedFileCount + 1, self.selectedFileCount];
        NSString *message = [NSString stringWithFormat:@"文件名:%@, 文件大小:%0.1fKB, 已下载:%0.1fKB", self.targetFileName, self.totalFileSize / 1024.0, self.currentDownloadSize / 1024.0];
        self.downloadAlertController.title = title;
        self.downloadAlertController.message = message;
    }
}

- (IBAction)playBtnAction:(id)sender {
    __weak DJICamera *camera = [self fetchCamera];
    
    if (self.cameraPlaybackState.fileType == DJICameraPlaybackFileTypeVIDEO) {
        [camera.playbackManager playVideo];
    }
}

/**
 switch current main window

 @param sender <#sender description#>
 */
- (IBAction)smallWindowBtnAction:(UIButton *)sender {
    sender.enabled = NO;
    DMLog(@"tap small window");
    if (self.currentMainWindow == CurrentMainWindowCamera) {
        self.currentMainWindow = CurrentMainWindowMap;
        self.rightSideBarView.hidden = YES;
        self.cameraInfoWidget.hidden = YES;
        self.cameraStorageWidget.hidden = YES;
        self.cameraSettingContainer.hidden = YES;
        self.exposureSettingContainer.hidden = YES;
        [UIView animateWithDuration:0.5 animations:^{
            self.mapViewContainerWidthConstraint.constant = KScreen_Width;
            self.mapViewContainerHeightConstraint.constant = KScreen_Height;
            self.gsButtonVC.view.alpha = 1.0;
            [self.view layoutIfNeeded];
        } completion:^(BOOL finished) {
            self.fpvPreviewViewWidthConstraint.constant = self.currentSmallWinSize.width;
            self.fpvPreviewViewHeightConstraint.constant = self.currentSmallWinSize.height;
            [self.fpvPreviewView swapDepthsWithView:self.mapContainerView];
            
            sender.enabled = YES;
        }];
    }else{
        
        [UIView animateWithDuration:0.5 animations:^{
            self.fpvPreviewViewWidthConstraint.constant = KScreen_Width;
            self.fpvPreviewViewHeightConstraint.constant = KScreen_Height;
            self.gsButtonVC.view.alpha = 0.0;
            self.waypointConfigVC.view.alpha = 0.0;
            [self.view layoutIfNeeded];
        } completion:^(BOOL finished) {
            self.mapViewContainerWidthConstraint.constant = self.currentSmallWinSize.width;
            self.mapViewContainerHeightConstraint.constant = self.currentSmallWinSize.height;
            [self.fpvPreviewView swapDepthsWithView:self.mapContainerView];
            self.currentMainWindow = CurrentMainWindowCamera;
            
            self.rightSideBarView.hidden = NO;
            self.cameraInfoWidget.hidden = NO;
            self.cameraStorageWidget.hidden = NO;
            
            sender.enabled = YES;
        }];
    }
}

- (IBAction)playbackBtnAction:(id)sender {
    DJICamera *camera = [self fetchCamera];
    [camera setMode:DJICameraModePlayback withCompletion:^(NSError * _Nullable error) {
        if (error) {
            WLAlertController *alertController = [WLAlertController alertWithTitle:@"查看回放失败" message:error.description];
            [self presentViewController:alertController animated:YES completion:nil];
            return;
        }
        self.cameraSettingContainer.hidden = YES;
        self.exposureSettingContainer.hidden = YES;
    }];
}

/**
 show check list

 @param gestureRecognizer <#sender description#>
 */
- (void)preFlightStatusWidgetTapAction:(UITapGestureRecognizer *)gestureRecognizer {
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
        
        DJIFlightController *flightController = [self fetchFlightController];
        if (flightController) {
            flightController.delegate = self;
        }
        
        [self focusMap];
    }else{
        DMLog(@"disconnected");
    }
}

- (void)productDisconnected{
    [self.mapController cleanAircraftWithMapView:self.mapView];
}

#pragma mark - DJIVideoFeedListenerDelegate
- (void)videoFeed:(DJIVideoFeed *)videoFeed didUpdateVideoData:(NSData *)videoData{
    [[VideoPreviewer instance] push:(uint8_t *)videoData.bytes length:(int)videoData.length];
}

#pragma mark - DJICameraDelegate
- (void)camera:(DJICamera *)camera didUpdateSystemState:(DJICameraSystemState *)systemState{
    self.cameraSystemState = systemState;
    BOOL isPlayback = (systemState.mode == DJICameraModePlayback || systemState.mode == DJICameraModeMediaDownload);
    [self switchPlaybackAndCamera:isPlayback];

}

#pragma mark - DJIPlaybackDelegate
- (void)playbackManager:(DJIPlaybackManager *_Nonnull)playbackManager didUpdatePlaybackState:(DJICameraPlaybackState *_Nonnull)playbackState{
    self.cameraPlaybackState = playbackState;
    [self updateUIWithPlaybackState:playbackState];
    
}

- (void)updateUIWithPlaybackState:(DJICameraPlaybackState *)playbackState{
    [self.playbackMultiSelectVC updateUIWithPlaybackState:playbackState andPlayVideoBtn:self.playVideoBtn];
}

#pragma mark - DJIGSButtonControllerDelegate
- (void)stopBtnActionInGSButtonVC:(DJIGSButtonController *)GSBtnVC{
    [[self missionOperator] stopMissionWithCompletion:^(NSError * _Nullable error) {
        WLAlertController *alertController;
        if (error) {
            alertController = [WLAlertController alertWithTitle:@"停止任务失败" message:error.description];
        }else{
            alertController = [WLAlertController alertWithTitle:@"" message:@"任务停止"];
        }
        [self presentViewController:alertController animated:YES completion:nil];
    }];
}

- (void)clearBtnActionInGSButtonVC:(DJIGSButtonController *)GSBtnVC{
    [self.mapController cleanAllPointsWithMapView:self.mapView];
}

- (void)focusMapBtnActionInGSButtonVC:(DJIGSButtonController *)GSBtnVC{
    [self focusMap];
}

- (void)startBtnActionInGSButtonVC:(DJIGSButtonController *)GSBtnVC{
    [[self missionOperator] startMissionWithCompletion:^(NSError * _Nullable error) {
        WLAlertController *alertController;
        if (error) {
            alertController = [WLAlertController alertWithTitle:@"开始任务失败" message:error.description];
        }else{
            alertController = [WLAlertController alertWithTitle:@"" message:@"任务开始"];
        }
        [self presentViewController:alertController animated:YES completion:nil];
    }];
}

- (void)addBtn:(UIButton *)button withActionInGSButtonVC:(DJIGSButtonController *)GSBtnVC{
    if (self.isEditingPoints) {
        self.isEditingPoints = NO;
        [button setTitle:@"增加" forState:UIControlStateNormal];
    }else{
        self.isEditingPoints = YES;
        [button setTitle:@"结束" forState:UIControlStateNormal];
    }
}

- (void)configBtnActionInGSButtonVC:(DJIGSButtonController *)GSBtnVC{
    WeakRef(weakSelf);
    
    NSArray *wayPoints = self.mapController.wayPoints;
    if (wayPoints == nil || wayPoints.count < 2) {
        WLAlertController *alertController = [WLAlertController alertWithTitle:@"没有足够的航点来执行任务" message:@""];
        [self presentViewController:alertController animated:YES completion:nil];
        return;
    }
    [UIView animateWithDuration:0.25 animations:^{
        WeakReturn(weakSelf);
        weakSelf.waypointConfigVC.view.alpha = 1.0;
    }];
    
    if (self.waypointMission) {
        [self.waypointMission removeAllWaypoints];
    }else{
        self.waypointMission = [[DJIMutableWaypointMission alloc] init];
    }
    
    for (int i = 0; i < wayPoints.count; i++) {
        CLLocation *location = [wayPoints objectAtIndex:i];
        if (CLLocationCoordinate2DIsValid(location.coordinate)) {
            DJIWaypoint *waypoint = [[DJIWaypoint alloc] initWithCoordinate:location.coordinate];
            [self.waypointMission addWaypoint:waypoint];
        }
    }
    
}

- (void)switchToMode:(DJIGSViewMode)mode inGSButtonVC:(DJIGSButtonController *)GSBtnVC{
    if (mode == DJIGSViewMode_EditMode) {
        [self focusMap];
    }
}

#pragma mark - DJIWaypointConfigViewControllerDelegate
- (void)cancelBtnActionInDJIWaypointConfigViewController:(DJIWaypointConfigViewController *)waypointConfigVC{
    WeakRef(weakSelf);
    [UIView animateWithDuration:0.25 animations:^{
        WeakReturn(weakSelf);
        weakSelf.waypointConfigVC.view.alpha = 0;
    }];
}

- (void)finishBtnActionInDJIWaypointConfigViewController:(DJIWaypointConfigViewController *)waypointConfigVC{
    WeakRef(weakSelf);
    [UIView animateWithDuration:0.25 animations:^{
        WeakReturn(weakSelf);
        weakSelf.waypointConfigVC.view.alpha = 0;
    }];
    
    for (int i = 0; i < self.waypointMission.waypointCount; i++) {
        DJIWaypoint *waypoint = [self.waypointMission waypointAtIndex:i];
        waypoint.altitude = [self.waypointConfigVC.altitudeTextField.text floatValue];
    }
    
    self.waypointMission.maxFlightSpeed = [self.waypointConfigVC.maxFlightSpeedTextField.text floatValue];
    self.waypointMission.autoFlightSpeed = [self.waypointConfigVC.autoFlightSpeedTextField.text floatValue];
    self.waypointMission.headingMode = (DJIWaypointMissionHeadingMode)self.waypointConfigVC.headingSegmentedControl.selectedSegmentIndex;
    [[self missionOperator] loadMission:self.waypointMission];
    
    WeakRef(target);
    
    [[self missionOperator] addListenerToFinished:self withQueue:dispatch_get_main_queue() andBlock:^(NSError * _Nullable error) {
        WeakReturn(target);
        WLAlertController *alertController;
        if (error) {
            alertController = [WLAlertController alertWithTitle:@"任务执行失败" message:error.description];
        }else{
            alertController = [WLAlertController alertWithTitle:@"任务执行结束" message:nil];
        }
        [target presentViewController:alertController animated:YES completion:nil];
    }];
    
    [[self missionOperator] uploadMissionWithCompletion:^(NSError * _Nullable error) {
        WLAlertController *alertController;
        if (error) {
            NSString *uploadError = [NSString stringWithFormat:@"上传任务失败:%@",error.description];
            alertController = [WLAlertController alertWithTitle:@"" message:uploadError];
        }else{
            alertController = [WLAlertController alertWithTitle:@"" message:@"上传任务结束"];
        }
        [target presentViewController:alertController animated:YES completion:nil];
    }];
}

#pragma mark - MAMapViewDelegate
- (MAOverlayRenderer *)mapView:(MAMapView *)mapView rendererForOverlay:(id<MAOverlay>)overlay{
    /* 自定义定位精度对应的MACircleView. */
    if (overlay == mapView.userLocationAccuracyCircle)
    {
        MACircleRenderer *accuracyCircleRenderer = [[MACircleRenderer alloc] initWithCircle:overlay];
        
        accuracyCircleRenderer.lineWidth    = 2.f;
        accuracyCircleRenderer.strokeColor  = [UIColor lightGrayColor];
        accuracyCircleRenderer.fillColor    = [UIColor colorWithRed:1 green:0 blue:0 alpha:.3];
        
        return accuracyCircleRenderer;
    }
    
    return nil;
}

- (MAAnnotationView *)mapView:(MAMapView *)mapView viewForAnnotation:(id<MAAnnotation>)annotation{
    if ([annotation isKindOfClass:[MAUserLocation class]])
    {
        static NSString * const userLocationStyleReuseIndetifier = @"userLocationStyleReuseIndetifier";
        MAAnnotationView *annotationView = [mapView dequeueReusableAnnotationViewWithIdentifier:userLocationStyleReuseIndetifier];
        if (annotationView == nil)
        {
            annotationView = [[MAPinAnnotationView alloc] initWithAnnotation:annotation
                                                             reuseIdentifier:userLocationStyleReuseIndetifier];
        }
        annotationView.image = [UIImage imageNamed:@"userPosition"];
        self.userLocationAnnotationView = annotationView;
        self.mapController.userLocationAnnotation = annotationView.annotation;
        return annotationView;
    }else if ([annotation isKindOfClass:[MAPointAnnotation class]]) {
        MAPinAnnotationView *pinView = [[MAPinAnnotationView alloc] initWithAnnotation:annotation reuseIdentifier:@"Pin_Annotation"];
        return pinView;
    }else if([annotation isKindOfClass:[AircraftAnnotation class]]){
        AircraftAnnotationView *annoView = [[AircraftAnnotationView alloc] initWithAnnotation:annotation reuseIdentifier:@"Aircraft_Annotation"];
        ((AircraftAnnotation *)annotation).annotationView = annoView;
        return annoView;
    }
    return nil;
}

- (void)mapView:(MAMapView *)mapView didUpdateUserLocation:(MAUserLocation *)userLocation updatingLocation:(BOOL)updatingLocation{
    if (!updatingLocation && self.userLocationAnnotationView != nil) {
        [UIView animateWithDuration:0.1 animations:^{
            double degree = userLocation.heading.trueHeading - self.mapView.rotationDegree;
            self.userLocationAnnotationView.transform = CGAffineTransformMakeRotation(degree * M_PI / 180.f);
        }];
    }
}

#pragma mark - DJIFlightControllerDelegate
- (void)flightController:(DJIFlightController *)fc didUpdateState:(DJIFlightControllerState *)state{
    self.droneLocation = state.aircraftLocation.coordinate;
    
    [self.mapController updateAircraftLocation:self.droneLocation withMapView:self.mapView];
    double radianYaw = RADIAN(state.attitude.yaw);
    [self.mapController updateAircraftHeading:radianYaw];
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
