//
//  ViewController.m
//  Lookon
//
//  Created by My Star on 8/14/17.
//  Copyright © 2017 My Star. All rights reserved.
//
#import <opencv2/opencv.hpp>
#import "CameraViewController.h"
#import "Utils.h"

#import "LookonManager.h"
#import "FaceProcess.h"
#import "BeautyCamera.h"
#import "WaitProgress.h"

//#import "FaceCamera.h"

@interface CameraViewController ()<UINavigationControllerDelegate>{
   // myCamera* videoCamera;
    cv::Mat capture_image;
    BeautyCamera *camera;
    WaitProgress *wait;
    BOOL video_camera_use;
    BOOL isCapture;

    int current_index;
    BOOL waitCancel;
       dispatch_queue_t _serialMetadataQueue;

    BOOL startThead;
}
@property (weak, nonatomic) IBOutlet UIButton *flash_onBtn;

@property (weak, nonatomic) IBOutlet UIView *camera_view;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *camera_width;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *camera_height;
@property (weak, nonatomic) IBOutlet UIView *crop_view;
@property (weak, nonatomic) IBOutlet UIImageView *test_imageview;

@end
@implementation CameraViewController

- (void)viewDidLoad {
    video_camera_use=YES;
    [_test_imageview setHidden:YES];
  
   

    current_index=0;
   
    
//
     // Do any additional setup after loading the view, typically from a nib.
}

-(void)viewDidAppear:(BOOL)animated{
    
    wait=[[WaitProgress alloc] initWithView:self.crop_view];
//    [wait start];
    if(video_camera_use==YES){
        [self changeCameraView];
        [_camera_view setNeedsLayout];
        [_camera_view layoutIfNeeded];
      

    if(!camera){
        
        camera=[[BeautyCamera alloc] initWithCameraSession:_camera_view cameraPosition:AVCaptureDevicePositionFront];
       
    }
        

  // [wait stop];
    [camera startCamera];
    }else{
        
        [_test_imageview setHidden:NO];
        
        NSString *stringFileName=[NSString stringWithFormat:@"test_%d",current_index+1];
        
        _test_imageview.image=[UIImage imageNamed:stringFileName];
    }
    [self.flash_onBtn setHidden:![camera IsFlash]];
   // [wait stop];
}
-(void)changeCameraView{
    
    float RealWidth=_crop_view.frame.size.width;
    float RealHeight=RealWidth*4/3;
    if(_crop_view.frame.size.height>RealHeight){

        RealHeight=_crop_view.frame.size.height;
        RealWidth=RealHeight*3/4;
        
    }
    _camera_width.constant=RealWidth;
    _camera_height.constant=RealHeight;

}
- (void)setStatusBarBackgroundColor:(UIColor *)color {
    
//    [[UIApplication sharedApplication] setStatusBarHidden:false];
//    UIView *statusBar=[[UIApplication sharedApplication] valueForKey:@"statusBar"];
//    statusBar.backgroundColor = [UIColor clearColor];
//    
//    [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleBlackTranslucent];
}

- (void)viewWillDisappear:(BOOL)animated{
    [camera stopCamera];
}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


- (IBAction)captureImage:(id)sender {
   

    
}
- (IBAction)captureDown:(id)sender {
    
  
 //
    if(video_camera_use){

        [camera takePhotoWithCompletion:^(NSData *capturedImage) {
            
            [camera stopCamera];
     
            NSData* imageData = UIImagePNGRepresentation([UIImage imageWithData:capturedImage]);
            //                   // UIImageOrientationRight,
            //
            
            AppManager.preview_image.release();
            cv::Mat mat=[Utils cvMatFromUIImage:[UIImage imageWithData:imageData]];
            cv::resize(mat, mat, cv::Size(960,1280));
            AppManager.preview_image=mat;
            

                
             // [self presentViewController:AppManager.preview_viewer animated:YES completion:nil];
           // [self.navigationController pushViewController:preViewer animated:NO];
            
        }];
        

    }else{
        

        AppManager.preview_image.release();
        cv::Mat mat=[Utils cvMatFromUIImage:_test_imageview.image];
        cv::resize(mat, mat, cv::Size(960,1280));
        AppManager.preview_image=mat;

            
       // [self presentViewController:AppManager.preview_viewer animated:YES completion:nil];
      // [self.navigationController pushViewController:preViewer animated:NO];
    }
    
    
}
- (IBAction)rotateCamera:(id)sender {
    
    if(video_camera_use && [camera getCurrentCamera]){
    [camera rotateCamera];
     [self.flash_onBtn  setHidden:![camera IsFlash]];
    }else{
        current_index++;
        current_index=current_index%7;
        NSString *stringFileName=[NSString stringWithFormat:@"test_%d",current_index+1];
        
        _test_imageview.image=[UIImage imageNamed:stringFileName];
    }
}
- (IBAction)flashEnable:(id)sender {
 
   [self.flash_onBtn setSelected:!self.flash_onBtn.isSelected];
    camera.flashEnable=self.flash_onBtn.isSelected;
 
}
- (IBAction)closeCamera:(id)sender {
    [self.navigationController popToRootViewControllerAnimated:true];

}


@end
