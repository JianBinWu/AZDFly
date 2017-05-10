//
//  DJIPlaybackMultiSelectViewController.m
//  BridgeAppDemo
//
//  Created by 吴剑斌 on 2017/4/14.
//  Copyright © 2017年 xmazd. All rights reserved.
//

#import "DJIPlaybackMultiSelectViewController.h"

@interface DJIPlaybackMultiSelectViewController ()

@property (strong, nonatomic) UISwipeGestureRecognizer *swipeLeftGesture;
@property (strong, nonatomic) UISwipeGestureRecognizer *swipeRightGesture;
@property (strong, nonatomic) UISwipeGestureRecognizer *swipeUpGesture;
@property (strong, nonatomic) UISwipeGestureRecognizer *swipeDownGesture;
@property (weak, nonatomic) IBOutlet UIButton *multiPreBtn;
@property (weak, nonatomic) IBOutlet UIButton *selectBtn;
@property (weak, nonatomic) IBOutlet UIButton *allSelectBtn;
@property (weak, nonatomic) IBOutlet UIButton *deleteBtn;
@property (weak, nonatomic) IBOutlet UIButton *downloadBtn;
@property (weak, nonatomic) IBOutlet UIView *bottomPlayView;
@property (weak, nonatomic) IBOutlet UIView *bottomView;

@end

@implementation DJIPlaybackMultiSelectViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.swipeLeftGesture = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(swipeLeftGestureAction:)];
    self.swipeLeftGesture.direction = UISwipeGestureRecognizerDirectionLeft;
    self.swipeRightGesture = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(swipeRightGestureAction:)];
    self.swipeRightGesture.direction = UISwipeGestureRecognizerDirectionRight;
    self.swipeUpGesture = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(swipeUpGestureAction:)];
    self.swipeUpGesture.direction = UISwipeGestureRecognizerDirectionUp;
    self.swipeDownGesture = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(swipeDownGestureAction:)];
    self.swipeDownGesture.direction = UISwipeGestureRecognizerDirectionDown;
    
    [self.view addGestureRecognizer:self.swipeLeftGesture];
    [self.view addGestureRecognizer:self.swipeRightGesture];
    [self.view addGestureRecognizer:self.swipeUpGesture];
    [self.view addGestureRecognizer:self.swipeDownGesture];
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark UIGestureAction Methods
- (void)swipeLeftGestureAction:(UISwipeGestureRecognizer *)gesture
{
    if (self.swipeGestureAction) {
        self.swipeGestureAction(UISwipeGestureRecognizerDirectionLeft);
    }
}

- (void)swipeRightGestureAction:(UISwipeGestureRecognizer *)gesture
{
    if (self.swipeGestureAction) {
        self.swipeGestureAction(UISwipeGestureRecognizerDirectionRight);
    }
}

- (void)swipeUpGestureAction:(UISwipeGestureRecognizer *)gesture
{
    if (self.swipeGestureAction) {
        self.swipeGestureAction(UISwipeGestureRecognizerDirectionUp);
    }
}

- (void)swipeDownGestureAction:(UISwipeGestureRecognizer *)gesture
{
    if (self.swipeGestureAction) {
        self.swipeGestureAction(UISwipeGestureRecognizerDirectionDown);
    }
}

#pragma mark UIButton Action Methods
- (IBAction)selectFirstItemBtnAction:(id)sender {
    if (self.selectItemBtnAction) {
        self.selectItemBtnAction(0);
    }
}

- (IBAction)selectSecondItemBtnAction:(id)sender {
    if (self.selectItemBtnAction) {
        self.selectItemBtnAction(1);
    }
}

- (IBAction)selectThirdItemBtnAction:(id)sender {
    if (self.selectItemBtnAction) {
        self.selectItemBtnAction(2);
    }
}

- (IBAction)selectFourthItemBtnAction:(id)sender {
    if (self.selectItemBtnAction) {
        self.selectItemBtnAction(3);
    }
}

- (IBAction)selectFifthItemBtnAction:(id)sender {
    if (self.selectItemBtnAction) {
        self.selectItemBtnAction(4);
    }
}

- (IBAction)selectSixthItemBtnAction:(id)sender {
    if (self.selectItemBtnAction) {
        self.selectItemBtnAction(5);
    }
}

- (IBAction)selectSeventhItemBtnAction:(id)sender {
    if (self.selectItemBtnAction) {
        self.selectItemBtnAction(6);
    }
}

- (IBAction)selectEighthItemBtnAction:(id)sender {
    if (self.selectItemBtnAction) {
        self.selectItemBtnAction(7);
    }
}

- (IBAction)backBtnAction:(id)sender {
    self.backBtnAction();
}

- (IBAction)multiPreBtnAction:(id)sender {
    self.multiPreBtnAction();
}

- (IBAction)selectBtnAction:(id)sender {
    self.selectBtnAction();
}

- (IBAction)allSelectBtnAction:(id)sender {
    self.allSelectBtnAction();
}

- (IBAction)deleteBtnAction:(id)sender {
    self.deleteBtnAction();
}

- (IBAction)downloadBtnAction:(id)sender {
    self.downloadBtnAction();
}
- (IBAction)stopBtnAction:(id)sender {
    self.stopBtnAction();
    
}

- (void)updateUIWithPlaybackState:(DJICameraPlaybackState *)playbackState andPlayVideoBtn:(UIButton *)playVideoBtn{
        if (playbackState.playbackMode == DJICameraPlaybackModeSingleFilePreview) {
            self.bottomView.hidden = NO;
            self.bottomPlayView.hidden = YES;
            self.multiPreBtn.hidden = NO;
            self.selectBtn.hidden = YES;
            self.allSelectBtn.hidden = YES;
            self.deleteBtn.hidden = NO;
            self.downloadBtn.hidden = NO;
            
            if (playbackState.fileType == DJICameraPlaybackFileTypeJPEG || playbackState.fileType == DJICameraPlaybackFileTypeRAWDNG) { //Photo Type
                
                if (!playVideoBtn.hidden) {
                    [playVideoBtn setHidden:YES];
                }
            }else if (playbackState.fileType == DJICameraPlaybackFileTypeVIDEO) //Video Type
            {
                if (playVideoBtn.hidden) {
                    [playVideoBtn setHidden:NO];
                }
            }
        }else if(playbackState.playbackMode == DJICameraPlaybackModeSingleVideoPlaybackStart){
            self.bottomView.hidden = YES;
            self.bottomPlayView.hidden = NO;
            playVideoBtn.hidden = YES;
        }else if (playbackState.playbackMode == DJICameraPlaybackModeMultipleFilesPreview){
            self.bottomView.hidden = NO;
            self.bottomPlayView.hidden = YES;
            self.multiPreBtn.hidden = YES;
            self.selectBtn.hidden = NO;
            [self.selectBtn setTitle:@"选择" forState:UIControlStateNormal];
            self.allSelectBtn.hidden = YES;
            self.deleteBtn.hidden = YES;
            self.downloadBtn.hidden = YES;
            playVideoBtn.hidden = YES;
        }else if(playbackState.playbackMode == DJICameraPlaybackModeMultipleFilesEdit){
            self.bottomView.hidden = NO;
            self.bottomPlayView.hidden = YES;
            self.multiPreBtn.hidden = YES;
            self.selectBtn.hidden = NO;
            [self.selectBtn setTitle:@"取消" forState:UIControlStateNormal];
            self.allSelectBtn.hidden = NO;
            self.deleteBtn.hidden = NO;
            self.downloadBtn.hidden = NO;
            playVideoBtn.hidden = YES;
        }
    
}

- (void)changeSelectedState:(BOOL)isSelected{
    self.selectBtn.selected = isSelected;
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
