//
//  ImageViewController.m
//  DJIUIDemo
//
//  Created by 吴剑斌 on 2017/5/12.
//  Copyright © 2017年 xmazd. All rights reserved.
//

#import "ImageViewController.h"
#import "ImageViewLayer.h"
#import "Line.h"

@interface ImageViewController ()<UINavigationControllerDelegate>
    
@property (weak, nonatomic) IBOutlet UIImageView *imageView;
@property (strong, nonatomic) UIImage *image;
@property (strong, nonatomic) ImageViewLayer *layer;

@end

@implementation ImageViewController

#pragma mark - controller life cycle
- (void)viewDidLoad {
    [super viewDidLoad];
    self.imageView.image = self.image;
    
    self.layer = [ImageViewLayer layer];
    [self initShootedHeight:self.asset.location.altitude];

    self.layer.frame = CGRectMake(0, 0, KScreen_Width, KScreen_Height);
    [self.view.layer addSublayer:self.layer];
    
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapAction:)];
    [self.view addGestureRecognizer:tap];
    
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    [self.navigationController setNavigationBarHidden:YES animated:YES];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    
    [self.navigationController setNavigationBarHidden:NO animated:YES];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - init
- (void)initImage:(UIImage *)image{
    self.image = image;
    
}

- (void)initShootedHeight:(CGFloat)altitude{
    self.layer.shootedHeight = altitude * 100;
}

#pragma mark - event handler
- (IBAction)revocationBtnAction:(id)sender {
    if (self.layer.lineArr.count > 0) {
        [self.layer.lineArr removeLastObject];
        [self.layer setNeedsDisplay];
    }
    
}

- (IBAction)backBtnAction:(id)sender {
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)tapAction:(UITapGestureRecognizer *)gesture{
    CGPoint point = [gesture locationInView:self.view];
    Line *line = [self.layer.lineArr lastObject];
    if (line == nil || line.isBegin == NO) {
        Line *newLine = [Line new];
        newLine.beginPoint = point;
        [self.layer.lineArr addObject:newLine];
    }else{
        line.endPoint = point;
    }
    [self.layer setNeedsDisplay];
    
}

- (IBAction)changeAltitude:(id)sender {
    //init alertController with textfield to input shooted height
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"请输入拍摄照片时的相机高度" message:@"单位：米"
                                                                      preferredStyle:UIAlertControllerStyleAlert];
    [alertController addTextFieldWithConfigurationHandler:^(UITextField * _Nonnull textField) {
        textField.keyboardType = UIKeyboardTypeDecimalPad;
    }];
    UIAlertAction *alertAction = [UIAlertAction actionWithTitle:@"完成" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        UITextField *textField = alertController.textFields[0];
        CGFloat shootedHeight = [textField.text doubleValue];
        CLLocation *location = self.asset.location;
        [[PHPhotoLibrary sharedPhotoLibrary] performChanges:^{
            PHAssetChangeRequest *assetChangeRequest = [PHAssetChangeRequest changeRequestForAsset:self.asset];
            assetChangeRequest.location = [[CLLocation alloc] initWithCoordinate:location.coordinate altitude:shootedHeight horizontalAccuracy:location.horizontalAccuracy verticalAccuracy:location.verticalAccuracy timestamp:location.timestamp];
        } completionHandler:^(BOOL success, NSError * _Nullable error) {
            if (!error) {
                self.layer.shootedHeight = shootedHeight * 100;
                WLAlertController *alertController = [WLAlertController alertWithTitle:@"修改高度成功" message:nil];
                [self presentViewController:alertController animated:YES completion:nil];
            }else{
                WLAlertController *alertController = [WLAlertController alertWithTitle:@"修改高度失败" message:error.description];
                [self presentViewController:alertController animated:YES completion:nil];
            }
        }];
        
    }];
    [alertController addAction:alertAction];
    [self presentViewController:alertController animated:YES completion:nil];
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
