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
#import "ImageViewController.h"


//To use DJI Bridge app, change `ENTER_DEBUG_MODE` to 1 and add bridge app IP address in `debugIP` string.
#define ENTER_DEBUG_MODE 1

typedef NS_ENUM(NSInteger, CurrentMainWindow) {
    CurrentMainWindowCamera,
    CurrentMainWindowMap
};

@interface RootViewController ()<DJISDKManagerDelegate,DJICameraDelegate,DJIBaseProductDelegate,DJIVideoFeedListener,DJIPlaybackDelegate,DJIPlaybackDelegate,DJIFlightControllerDelegate,DJIGSButtonControllerDelegate,DJIWaypointConfigViewControllerDelegate,MAMapViewDelegate,UIImagePickerControllerDelegate,UINavigationControllerDelegate>

@property (weak, nonatomic) IBOutlet UIView *fpvPreviewView;       //a view that as a fpvPreview
@property (weak, nonatomic) IBOutlet UIView *mapContainerView;     //a view that contain mapview
@property (weak, nonatomic) IBOutlet DULExposureSettingsMenu *exposureSettingMenu;   //exporsureSettingMenu in DJI UI SDK
@property (weak, nonatomic) IBOutlet DULCameraSettingsMenu *cameraSettingsMenu;      //cameraSettingsMenu in DJI UI SDK
@property (weak, nonatomic) IBOutlet UIView *cameraSettingContainer;      //a view that contain cameraSettingMenu
@property (weak, nonatomic) IBOutlet UIView *exposureSettingContainer;    //a view that contain exposureSettingMenu
@property (weak, nonatomic) IBOutlet DULCameraConfigInfoWidget *cameraInfoWidget;        //cameraConfigInfoWidget in DJI UI SDK
@property (weak, nonatomic) IBOutlet DULCameraConfigStorageWidget *cameraStorageWidget;  //cameraConfigStorageWidget in DJI UI SDK
@property (weak, nonatomic) IBOutlet DULPreFlightStatusWidget *preFlightStatusWidget;
@property (weak, nonatomic) IBOutlet UIView *statusBarView;        //a view that contains status widget in DJI UI SDK
@property (weak, nonatomic) IBOutlet UIView *leftSideBarView;      //a view contain auto take off and auto landing
@property (weak, nonatomic) IBOutlet UIView *bottomBarView;        //a view contain dashboard
@property (weak, nonatomic) IBOutlet UIView *rightSideBarView;     //a view contain camera setting,switch,captureWidget,exporsure setting,playback
@property (weak, nonatomic) IBOutlet UIButton *smallWindowBtn;     //btn for switching fpvPreview and mapView
@property (weak, nonatomic) IBOutlet UIButton *playVideoBtn;       //btn for playing video in playback state
@property (weak, nonatomic) IBOutlet DULCaptureWidget *captureWidget;



@property (weak, nonatomic) IBOutlet NSLayoutConstraint *fpvPreviewViewHeightConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *fpvPreviewViewWidthConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *mapViewContainerHeightConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *mapViewContainerWidthConstraint;


@property (assign, nonatomic) CurrentMainWindow currentMainWindow;   //mark currentMainWindow: CurrentMainWindowCamera or CurrentMainWindowMap
@property (strong, nonatomic) NSMutableData *downloadedImageData;    //store downloadedImageData
@property (strong, nonatomic) NSMutableArray *downloadedImageArray;  //store images which are already downloaded
@property (strong, nonatomic) NSMutableArray *downloadedImageLocationArray;  //store images' location
@property (assign, nonatomic) CGSize currentSmallWinSize;          //store small window's size
@property (assign, nonatomic) CGFloat originalMapLogoCenterX;
@property (strong, nonatomic) DJICameraPlaybackState *cameraPlaybackState;
@property (strong, nonatomic) DJICameraSystemState *cameraSystemState;
@property (assign, nonatomic) int selectedFileCount;
@property (strong, nonatomic) NSError *downloadImageError;    //image error when download
@property (strong, nonatomic) NSString *targetFileName;       //file name when download
@property (assign, nonatomic) DJIDownloadFileType fileType;   //fileType when download
@property (assign, nonatomic) long totalFileSize;
@property (assign, nonatomic) long currentDownloadSize;
@property (assign, nonatomic) int downloadedFileCount;
@property (strong, nonatomic) NSTimer *updateImageDownloadTimer;  //timer for update state when download image

@property (strong, nonatomic) DULPreflightChecklistController *checklistController;
@property (strong, nonatomic) DJIPlaybackMultiSelectViewController *playbackMultiSelectVC;
@property (strong, nonatomic) UIAlertController *downloadAlertController;   //alert controller show download state

//map property
@property (strong, nonatomic) MAMapView *mapView;
@property (strong, nonatomic) DJIMapController *mapController;
@property (strong, nonatomic) UITapGestureRecognizer *tapGesture;
@property (assign, nonatomic) BOOL isEditingPoints;
@property (assign, nonatomic) CLLocationCoordinate2D userLocation;
@property (assign, nonatomic) CLLocation *droneLocation;
@property (assign, nonatomic) double droneAltitude;                          //drone's altitude relative to take off location
@property (strong, nonatomic) CLLocation *droneLocationWhenShooting;              //drone's location when shooting picture
@property (strong, nonatomic) NSMutableDictionary *locationDic;              //store image's name with altitude
@property (strong, nonatomic) DJIGSButtonController *gsButtonVC;             //a controller contain buttons for way point
@property (strong, nonatomic) DJIWaypointConfigViewController *waypointConfigVC;  //a waypoint config controller
@property (strong, nonatomic) DJIMutableWaypointMission *waypointMission;
@property (strong, nonatomic) MAAnnotationView *userLocationAnnotationView;       //annotationView for userLocation

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

/**
 update gsButtonVC waypointConfigVC smallWindows' constraints
 */
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
    
    //layout waypointConfigVC
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

/**
 init data for download image,current main window,checklist,map
 */
- (void)initData{
    //init data for download image
    self.downloadedImageData = [NSMutableData data];
    self.downloadedImageArray = [NSMutableArray array];
    self.downloadedImageLocationArray = [NSMutableArray array];
    self.locationDic = [self locationDicFromArchiver];
    
    //init current main window camera
    self.currentMainWindow = CurrentMainWindowCamera;
    
    //init a checklist controller
    self.checklistController = [DULPreflightChecklistController preflightChecklistController];
    
    //init map data
    self.userLocation = kCLLocationCoordinate2DInvalid;
    self.mapController = [[DJIMapController alloc] init];
    
}

/**
 init event handler for cameraSettingMenu,exposureSettingMenu,tap gesture for preflight status widget,captureWidget
 */
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
    
    //record drone's altitude when shooting
    self.captureWidget.action = ^{
        if(self.captureWidget.mode == DJICameraModeShootPhoto){
            self.droneLocationWhenShooting = [[CLLocation alloc] initWithCoordinate:self.droneLocation.coordinate altitude:self.droneAltitude horizontalAccuracy:self.droneLocation.horizontalAccuracy verticalAccuracy:self.droneLocation.verticalAccuracy timestamp:self.droneLocation.timestamp];
        }
    };
    
    //init a tap gesture for preflight status widget
    UITapGestureRecognizer *tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(preFlightStatusWidgetTapAction:)];
    [self.preFlightStatusWidget addGestureRecognizer:tapGesture];
}


/**
 init playback VC
 */
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

/**
 init mapview and UI
 */
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


/**
 connect to product
 */
- (void)connectToProduct{
    if (ENTER_DEBUG_MODE) {
        NSString *debugIP = @"10.0.1.179";
        DMLog(@"Connecting to Product using debug IP address:%@",debugIP);
        [DJISDKManager enableBridgeModeWithBridgeAppIP:debugIP];
    }else{
        DMLog(@"Connecting to product...");
        [DJISDKManager startConnectionToProduct];
    }
}


/**
 fetch camera

 @return DJICamera
 */
- (DJICamera *)fetchCamera{
    if (![DJISDKManager product]) {
        return nil;
    }
    
    if ([[DJISDKManager product] isKindOfClass:[DJIAircraft class]]) {
        return ((DJIAircraft *)[DJISDKManager product]).camera;
    }
    
    return nil;
    
}

/**
 fetch flight controller

 @return DJIFlightController
 */
- (DJIFlightController *)fetchFlightController{
    if (![DJISDKManager product]) {
        return nil;
    }
    
    if ([[DJISDKManager product] isKindOfClass:[DJIAircraft class]]) {
        return ((DJIAircraft *)[DJISDKManager product]).flightController;
    }
    
    return nil;
}


/**
 switch interface between playback and camera

 @param isPlayback BOOL
 */
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

/**
 get mission operator

 @return DJIWaypointMissionOperator
 */
- (DJIWaypointMissionOperator *)missionOperator{
    return [DJISDKManager missionControl].waypointMissionOperator;
}

#pragma mark - method for download image

/**
 download file from sd card
 */
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
        target.targetFileName = [self processFileName:fileName];
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
                CLLocation *location = [target.locationDic objectForKey:target.targetFileName];
                if (location) {
                    [target.downloadedImageLocationArray addObject:location];
                }else{
                    [target.downloadedImageLocationArray addObject:[NSNull null]];
                }
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


/**
 save downloaded image in album
 */
- (void)saveDownloadImage{
    if (self.downloadedImageArray && self.downloadedImageArray.count > 0) {
        UIImage *image = [self.downloadedImageArray lastObject];
        CLLocation *location = [self.downloadedImageLocationArray lastObject];
        [self saveImageToCameraRoll:image location:location];
    }else{
        [self.downloadAlertController dismissViewControllerAnimated:YES completion:nil];
    }
}


/**
 save image with location

 @param image UIImage
 @param location CLLocation
 */
- (void)saveImageToCameraRoll:(UIImage *)image location:(CLLocation *)location{
    
    [[PHPhotoLibrary sharedPhotoLibrary] performChanges:^{
        PHAssetChangeRequest *newAssetRequest = [PHAssetChangeRequest creationRequestForAssetFromImage:image];
        if (location) {
            newAssetRequest.location = location;
        }
    } completionHandler:^(BOOL success, NSError * _Nullable error) {
        if (error != NULL) {
            [self.downloadAlertController dismissViewControllerAnimated:YES completion:nil];
            WLAlertController *alertController = [WLAlertController alertWithTitle:@"存储图片失败" message:error.description];
            [self presentViewController:alertController animated:YES completion:nil];
        }else{
            [self.downloadedImageArray removeLastObject];
            [self.downloadedImageLocationArray removeLastObject];
            if (self.downloadedImageArray) {
                [self saveDownloadImage];
                
                if (self.downloadedImageArray.count == 0) {
                    WLAlertController *alertController = [WLAlertController alertWithTitle:@"照片已存储到相册" message:@""];
                    [self presentViewController:alertController animated:YES completion:nil];
                }
            }
        }
    }];
    
}


/**
 start timer when download image begin
 */
- (void)startUpdateTimer{
    if (self.updateImageDownloadTimer == nil) {
        self.updateImageDownloadTimer = [NSTimer scheduledTimerWithTimeInterval:0.5 target:self selector:@selector(updateDownloadProgress:) userInfo:nil repeats:YES];
    }
}

/**
 update download progress

 @param updatedTimer NSTimer
 */
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

/**
 stop timer when download image end
 */
- (void)stopTimer{
    if (self.updateImageDownloadTimer != nil) {
        [self.updateImageDownloadTimer invalidate];
        self.updateImageDownloadTimer = nil;
    }
}


/**
 process file name to match the key in locationDic

 @param fileName NSString
 @return NSString
 */
- (NSString *)processFileName:(NSString *)fileName{
    NSString *processedFileName = [[fileName componentsSeparatedByString:@"\\"] lastObject];
    NSArray *processedFileNameArr = [processedFileName componentsSeparatedByString:@"."];
    NSString *fileSuffix = [processedFileNameArr lastObject];
    processedFileName = processedFileNameArr[0];
    processedFileName = [NSString stringWithFormat:@"%@.%@",processedFileName,[fileSuffix lowercaseString]];
    return processedFileName;
    
}


/**
 reset downloadData when download begin
 */
- (void)resetDownloadData{
    self.downloadImageError = nil;
    self.totalFileSize = 0;
    self.currentDownloadSize = 0;
    self.downloadedFileCount = 0;
    
    [self.downloadedImageData setData:[NSData dataWithBytes:NULL length:0]];
    [self.downloadedImageArray removeAllObjects];
    [self.downloadedImageLocationArray removeAllObjects];
}


/**
 get locationDic from archiver

 @return NSMutableDictionary
 */
- (NSMutableDictionary *)locationDicFromArchiver{
    NSString *doc = kPathDocument;
    NSString *path = [doc stringByAppendingPathComponent:locationDicPath];
    NSData *data = [NSData dataWithContentsOfFile:path];
    NSKeyedUnarchiver *unarchiver = [[NSKeyedUnarchiver alloc] initForReadingWithData:data];
    NSMutableDictionary *locationDic = [unarchiver decodeObjectForKey:droneLocationDicKey];
    if (!locationDic) {
        locationDic = [NSMutableDictionary dictionaryWithCapacity:10];
    }
    return locationDic;
    
}


/**
 archive locationDic

 @param locationDic NSMutableDictionary
 */
- (void)archiveLocationDic:(NSMutableDictionary *)locationDic{
    //store archivered binary
    NSMutableData *data = [NSMutableData dataWithCapacity:1];
    //alloc init archiver
    NSKeyedArchiver *archiver = [[NSKeyedArchiver alloc] initForWritingWithMutableData:data];
    //archive
    [archiver encodeObject:locationDic forKey:droneLocationDicKey];
    [archiver finishEncoding];
    
    NSString *doc = kPathDocument;
    NSString *path = [doc stringByAppendingPathComponent:locationDicPath];
    [data writeToFile:path atomically:YES];
    
}

#pragma mark - event handler

/**
 btn action for present album VC

 @param sender UIButton
 */
- (IBAction)settingBtnAction:(id)sender {
    //call system album
    UIImagePickerController *pickerController = [[UIImagePickerController alloc] init];
    pickerController.sourceType = UIImagePickerControllerSourceTypeSavedPhotosAlbum;
    pickerController.delegate = self;
    [self presentViewController:pickerController animated:YES completion:nil];
}


/**
 focus map with droneLocation
 */
- (void)focusMap{
    if (CLLocationCoordinate2DIsValid(self.droneLocation.coordinate)) {
        MACoordinateRegion region = {0};
        region.center = self.droneLocation.coordinate;
        region.span.latitudeDelta = 0.001;
        region.span.longitudeDelta = 0.001;
        
        [self.mapView setRegion:region animated:YES];
    }
}


/**
 add way points

 @param tapGesture UITapGestureRecognizer
 */
- (void)addWaypoints:(UITapGestureRecognizer *)tapGesture{
    CGPoint point = [tapGesture locationInView:self.mapView];
    
    if (tapGesture.state == UIGestureRecognizerStateEnded) {
        if (self.isEditingPoints) {
            [self.mapController addPoint:point withMapView:self.mapView];
        }
    }
}


/**
 play the video when in playbakc mode

 @param sender UIButton
 */
- (IBAction)playBtnAction:(id)sender {
    __weak DJICamera *camera = [self fetchCamera];
    
    if (self.cameraPlaybackState.fileType == DJICameraPlaybackFileTypeVIDEO) {
        [camera.playbackManager playVideo];
    }
}

/**
 switch current main window

 @param sender button
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


/**
 switch in playback mode

 @param sender UIButton
 */
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

 @param gestureRecognizer tapGestureRecognizer
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
    self.droneLocation = state.aircraftLocation;
    self.droneAltitude = state.altitude;
    [self.mapController updateAircraftLocation:self.droneLocation.coordinate withMapView:self.mapView];
    double radianYaw = RADIAN(state.attitude.yaw);
    [self.mapController updateAircraftHeading:radianYaw];
}

#pragma mark - UIImagePickerControllerDelegate
- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(nonnull NSDictionary<NSString *,id> *)info{
    UIImage *resultImage = [info objectForKey:@"UIImagePickerControllerOriginalImage"];
    
    NSURL *assetURL = [info objectForKey:UIImagePickerControllerReferenceURL];
    PHAsset *asset = [[PHAsset fetchAssetsWithALAssetURLs:@[assetURL] options:nil] lastObject];
    
    ImageViewController *imageVC = [[ImageViewController alloc] initWithNibName:@"ImageViewController" bundle:[NSBundle mainBundle]];
    [imageVC initImage:resultImage];
    imageVC.asset = asset;

    [picker pushViewController:imageVC animated:YES];
}

#pragma mark - DJICameraDelegate
- (void)camera:(DJICamera *_Nonnull)camera didGenerateNewMediaFile:(DJIMediaFile *_Nonnull)newMedia{
    if (newMedia.mediaType == DJIMediaTypeJPEG || newMedia.mediaType == DJIMediaTypeRAWDNG) {
        
        [self.locationDic setObject:self.droneLocationWhenShooting forKey:newMedia.fileName];
        [self archiveLocationDic:self.locationDic];
        
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
