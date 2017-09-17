//
//  PreviewController.m
//  Lookon
//
//  Created by My Star on 9/14/17.
//  Copyright © 2017 My Star. All rights reserved.
//

#import "PreviewController.h"
#import "LookonManager.h"
#import "FaceProcess.h"
#import "WaitProgress.h"
#import "Utils.h"
@interface PreviewController (){
        WaitProgress *wait;
        dispatch_queue_t _serialloadQueue;
}
@property (weak, nonatomic) IBOutlet UIImageView *preview_image;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *camera_width;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *camera_height;
@property (weak, nonatomic) IBOutlet UIView *crop_view;
@end

@implementation PreviewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
  _serialloadQueue = dispatch_queue_create( "com.nga.GLFace.serialLoadQueue", DISPATCH_QUEUE_SERIAL );


    // Do any additional setup after loading the view.
}
-(void)viewDidAppear:(BOOL)animated{
    [self changeCameraView];
    wait=[[WaitProgress alloc] initWithView:self.crop_view];
    dispatch_async(dispatch_get_main_queue(), ^{
        UIImage*image=[Utils UIImageFromCVMat:AppManager.preview_image];
        self.preview_image.image=image;
    });
    
}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
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

-(void)processImage{
 
    FaceImage *face=AppManager.userFace;
    
    face.src_image.release();
    face.src_image=AppManager.preview_image;
    
    BOOL res= [AppManager faceDectection:&face];
    
    if(res==YES){
        
        [face changeForehead:0.0];
        [AppManager processIllustrate:AppManager.current_index];
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
- (IBAction)Use_Photo:(id)sender {
  [wait start];
  dispatch_async(_serialloadQueue, ^{
   [self processImage];
   
  // [self presentViewController:AppManager.main_viewer animated:YES completion:nil];
         dispatch_async(dispatch_get_main_queue(), ^{
              [wait stop];
      [self.navigationController popToRootViewControllerAnimated:true];
         });
  //     [self dismissViewControllerAnimated:NO completion:nil];
    //  [AppManager.camera_viewer  dismissViewControllerAnimated:NO completion:nil];
//      [self.navigationController pushViewController:AppManager.main_viewer animated:NO];

  });
    
}
- (IBAction)dismiss_Photo:(id)sender {
  //
}

@end
