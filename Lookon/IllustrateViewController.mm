//
//  IllustrateViewController.m
//  Lookon
//
//  Created by My Star on 8/14/17.
//  Copyright © 2017 My Star. All rights reserved.
//

#import "IllustrateViewController.h"
#import "AffineTransform.h"
#import "LookonManager.h"
#import "FaceProcess.h"
#import "MakeupProcess.h"
#import "WaitProgress.h"
#import "CameraViewController.h"
#import "PreviewController.h"
@interface IllustrateViewController ()<UICollectionViewDelegate,UICollectionViewDataSource,UIGestureRecognizerDelegate>{

    NSMutableArray *overlayResultList;
    UITapGestureRecognizer *doubleTap;
    UITapGestureRecognizer *singletapCloseZoom;
    NSMutableArray *illustratesDetectArrays;
    __weak IBOutlet UIImageView *previewImage;
    __weak IBOutlet UIImageView *Zoonimage;
    __weak IBOutlet UIView *zoomLayout;
      WaitProgress *wait;
    CGPoint lastPoint;
    float lastScale;
    BOOL process_image;
    int current_index;
    dispatch_queue_t _serialloadQueue;
    CameraViewController* cameraViewer;
    IllustrateImage *currentImage;
    
}
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *camera_width;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *camera_height;
@end

@implementation IllustrateViewController

- (void)viewDidLoad {
    
    [super viewDidLoad];
      //[wait start:self.view];
    

    [previewImage setUserInteractionEnabled: YES];
    
    doubleTap = [[UITapGestureRecognizer alloc] initWithTarget: self action: @selector(clickDoulbleTapImageView)];
    
    doubleTap.numberOfTapsRequired =1;
    
    [previewImage addGestureRecognizer: doubleTap];
    
    singletapCloseZoom = [[UITapGestureRecognizer alloc] initWithTarget: self action: @selector(clickSigleTapZoomView)];
    
    singletapCloseZoom.numberOfTapsRequired =1;
    
    [Zoonimage addGestureRecognizer: singletapCloseZoom];
    
    _serialloadQueue = dispatch_queue_create( "com.nga.GLFace.serialLoadQueue", DISPATCH_QUEUE_SERIAL );
    [zoomLayout setHidden:YES];
    process_image=YES;
//    UIPinchGestureRecognizer *pinchGesture = [[UIPinchGestureRecognizer alloc] initWithTarget:self action:@selector(handlePinch:)];
//    [Zoonimage addGestureRecognizer:pinchGesture];
    
    [self addMovementGesturesToView:Zoonimage];
     current_index=0;


  


    // Do any additional setup after loading the view.
}
- (void)addMovementGesturesToView:(UIView *)view {
    view.userInteractionEnabled = YES;  // Enable user interaction
    
    UIPanGestureRecognizer *panGesture = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(handlePanGesture:)];
    panGesture.delegate = self;
    panGesture.cancelsTouchesInView = NO;
    [view addGestureRecognizer:panGesture];
    
    UIPinchGestureRecognizer *pinchGesture = [[UIPinchGestureRecognizer alloc] initWithTarget:self action:@selector(handlePinchGesture:)];
    pinchGesture.delegate = self;
    pinchGesture.cancelsTouchesInView = NO;
    [view addGestureRecognizer:pinchGesture];
    
    
//    UIRotationGestureRecognizer *rotateGesture = [[UIRotationGestureRecognizer alloc] initWithTarget:self action:@selector(handleRotateGesture:)];
//    rotateGesture.delegate = self;
//    rotateGesture.cancelsTouchesInView = NO;
//    [view addGestureRecognizer:rotateGesture];
    
}


-(void)viewDidAppear:(BOOL)animated{
    
    AppManager.main_viewer=self;
    
    [self changeCameraView];
    wait=[[WaitProgress alloc] initWithView:previewImage];
    process_image=YES;
    previewImage.layer.masksToBounds = NO;
    previewImage.layer.cornerRadius = 8; // if you like rounded corners
    previewImage.layer.shadowOffset = CGSizeMake(4, 5);
    previewImage.layer.shadowRadius = 5;
    previewImage.layer.shadowOpacity = 0.5;
 
      [_galleryView reloadData];
    if (!AppManager.userFace.src_image.empty())
      [self selectIllustratePage:AppManager.current_index];
    else{
[self.navigationController pushViewController:AppManager.camera_viewer animated:NO];
       
    }
 //   current_index=0;

    
}
-(void)changeCameraView{
    
    float RealWidth=self.view.frame.size.width;
    float RealHeight=RealWidth*4/3;
    if(self.view.frame.size.height>RealHeight){
        
        RealHeight=self.view.frame.size.height;
        RealWidth=RealHeight*3/4;
        
    }
    _camera_width.constant=RealWidth;
    _camera_height.constant=RealHeight;
    
}

-(void) calculateFaceOverlay{
    
}
-(void)selectIllustratePage:(int)index{
        
        [wait start];
        
        dispatch_async(_serialloadQueue, ^{
            
            
            IllustrateImage* demo = (IllustrateImage *)[AppManager.illustratesDetectArrays objectAtIndex:index];
            
            if(demo.result.empty()){
                [AppManager processIllustrate:index];
            }
            dispatch_async(dispatch_get_main_queue(), ^{
                previewImage.image=nil;
                
                
                previewImage.image =[Utils UIImageFromCVMat:demo.result];
            });

         //   current_index=index;
          [wait stop];
            
            process_image=YES;
            
            
        });


}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - UICollectionView Methods

-(NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section{
    return AppManager.thumbnailSamples.count;
}
- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath{
    static NSString *identifier = @"selected_cell";
    
    UICollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:identifier forIndexPath:indexPath];
    
    UIImageView *img1 = (UIImageView *)[cell viewWithTag:100];
    img1.layer.masksToBounds = NO;
    img1.layer.cornerRadius = 4; // if you like rounded corners
    img1.layer.shadowOffset = CGSizeMake(3, 3);
    img1.layer.shadowRadius = 3;
    img1.layer.shadowOpacity = 0.5;

    img1.image=AppManager.thumbnailSamples[indexPath.row];
    return cell;
}
- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath{
   
   [self selectIllustratePage:(int)indexPath.row];//[overlayResultList objectAtIndex:(int)indexPath.row];
   // [self selectIllustratePage:;
}
/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/
- (void)clickDoulbleTapImageView{
    [zoomLayout setHidden:NO];
    Zoonimage.image=previewImage.image;

}
-(void)clickSigleTapZoomView{
    [zoomLayout setHidden:YES];
}
- (IBAction)CameraView_Open:(id)sender {
    
    for (int i=0;i<[AppManager.illustratesDetectArrays count];i++){
    
    IllustrateImage* demo = (IllustrateImage *)[AppManager.illustratesDetectArrays objectAtIndex:i];
    
    demo.result.release();
       cv::Mat m;
        demo.result=m;
    }

   // [self presentViewController:AppManager.camera_viewer animated:YES completion:nil];
    [self.navigationController pushViewController:AppManager.camera_viewer animated:YES];
   // [self dismissViewControllerAnimated:YES completion:nil];
}
- (IBAction)gotoPreState:(id)sender {
    [zoomLayout setHidden:YES];
}
- (IBAction)uploadPicture:(id)sender {
   // [AppManager sendFacialData:current_index addViewController:self];
    
              UIImageWriteToSavedPhotosAlbum(previewImage.image,
                                               self, // send the message to 'self' when calling the callback
                                               nil,
                                               NULL); //
   // [currentImage savefacialfeature:self];
}

//- (void)handlePinch:(UIPinchGestureRecognizer *)gesture {
//    
//    if (gesture.state == UIGestureRecognizerStateBegan) {
//        lastScale = 1.0;
//        lastPoint = [gesture locationInView:Zoonimage];
//    }
//    
//    // Scale
//    CGFloat scale = 1.0 - (lastScale - gesture.scale);
//    
//       [Zoonimage.layer setAffineTransform:
//     CGAffineTransformScale([Zoonimage.layer affineTransform],
//                            scale,
//                            scale)];
//    lastScale = gesture.scale;
//    
//    // Translate
//    CGPoint point = [gesture locationInView:Zoonimage];
//    [Zoonimage.layer setAffineTransform:
//     CGAffineTransformTranslate([Zoonimage.layer affineTransform],
//                                point.x - lastPoint.x,
//                                point.y - lastPoint.y)];
//    lastPoint = [gesture locationInView:Zoonimage];
//    
//   
//}

- (void)handlePanGesture:(UIPanGestureRecognizer *)panGesture {
    CGPoint translation = [panGesture translationInView:self.view];
    
//    if (UIGestureRecognizerStateBegan == panGesture.state ||UIGestureRecognizerStateChanged == panGesture.state) {
//        panGesture.view.center = CGPointMake(panGesture.view.center.x + translation.x,
//                                             panGesture.view.center.y + translation.y);
//        // Reset translation, so we can get translation delta's (i.e. change in translation)
//        
//      //  int dx=Zoonimage.frame.origin.x;
//        
//        [panGesture setTranslation:CGPointZero inView:self.view];
//       
//        
//
//    // Don't need any logic for ended/failed/canceled states
    
    
   // CGPoint translation = [panRecognizer translationInView:self.view];
    
     if (UIGestureRecognizerStateBegan == panGesture.state ||UIGestureRecognizerStateChanged == panGesture.state) {
    CGPoint imageViewPosition = Zoonimage.center;
    imageViewPosition.x += translation.x;
    imageViewPosition.y += translation.y;
    
    CGFloat checkOriginX = Zoonimage.frame.origin.x + translation.x; // imageView's origin's x position after translation, if translation is applied
    CGFloat checkOriginY = Zoonimage.frame.origin.y + translation.y; // imageView's origin's y position after translation, if translation is applied
    
  //  CGRect rectToCheckBounds = CGRectMake(checkOriginX, checkOriginY, Zoonimage.frame.size.width, Zoonimage.frame.size.height); // frame of imageView if translation is applied
         if(checkOriginX>0)return;
         if(checkOriginY>0)return;
         if(checkOriginX+Zoonimage.frame.size.width<self.view.frame.size.width)return;
         if(checkOriginY+Zoonimage.frame.size.height<self.view.frame.size.height)return;
  //  if (!CGRectContainsRect(self.view.frame, rectToCheckBounds)){
        Zoonimage.center = imageViewPosition;
        [panGesture setTranslation:CGPointZero inView:self.view];
  //  }
  }
}

- (void)handlePinchGesture:(UIPinchGestureRecognizer *)pinchGesture {
    
    if (UIGestureRecognizerStateBegan == pinchGesture.state ||
        UIGestureRecognizerStateChanged == pinchGesture.state) {
        
        // Use the x or y scale, they should be the same for typical zooming (non-skewing)
        float currentScale = [[pinchGesture.view.layer valueForKeyPath:@"transform.scale.x"] floatValue];
        
        // Variables to adjust the max/min values of zoom
        float minScale = 1.0;
        float maxScale = 4.0;
        float zoomSpeed = .5;
        
        float deltaScale = pinchGesture.scale;
        
        // You need to translate the zoom to 0 (origin) so that you
        // can multiply a speed factor and then translate back to "zoomSpace" around 1
        deltaScale = ((deltaScale - 1) * zoomSpeed) + 1;
        
        // Limit to min/max size (i.e maxScale = 2, current scale = 2, 2/2 = 1.0)
        //  A deltaScale is ~0.99 for decreasing or ~1.01 for increasing
        //  A deltaScale of 1.0 will maintain the zoom size
        deltaScale = MIN(deltaScale, maxScale / currentScale);
        deltaScale = MAX(deltaScale, minScale / currentScale);
        
        CGAffineTransform zoomTransform = CGAffineTransformScale(pinchGesture.view.transform, deltaScale, deltaScale);
       
         pinchGesture.view.transform = zoomTransform;
        
        CGFloat checkOriginX = Zoonimage.frame.origin.x ; // imageView's origin's x position after translation, if translation is applied
        CGFloat checkOriginY = Zoonimage.frame.origin.y ; // imageView's origin's y position after translation, if

        if(checkOriginX>0)zoomTransform=CGAffineTransformTranslate(zoomTransform,-checkOriginX,0);
        if(checkOriginY>0)zoomTransform=CGAffineTransformTranslate(zoomTransform,0,-checkOriginY);
        
        
        if(checkOriginX+Zoonimage.frame.size.width<self.view.frame.size.width)zoomTransform=CGAffineTransformTranslate(zoomTransform,self.view.frame.size.width-(checkOriginX+Zoonimage.frame.size.width),0);
        if(checkOriginY+Zoonimage.frame.size.height<self.view.frame.size.height)zoomTransform=CGAffineTransformTranslate(zoomTransform,0,self.view.frame.size.height-(checkOriginY+Zoonimage.frame.size.height));
         pinchGesture.view.transform = zoomTransform;
        // Reset to 1 for scale delta's
        //  Note: not 0, or we won't see a size: 0 * width = 0
        pinchGesture.scale = 1;
    }
}

//- (void)handleRotateGesture:(UIRotationGestureRecognizer *)rotateGesture {
//    if (UIGestureRecognizerStateBegan == rotateGesture.state ||
//        UIGestureRecognizerStateChanged == rotateGesture.state) {
//        rotateGesture.view.transform = CGAffineTransformRotate(rotateGesture.view.transform, rotateGesture.rotation);
//        rotateGesture.rotation = 0;
//    }
//}

- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldRecognizeSimultaneouslyWithGestureRecognizer:(UIGestureRecognizer *)otherGestureRecognizer {
    return YES; // Works for most use cases of pinch + zoom + pan
}

@end
