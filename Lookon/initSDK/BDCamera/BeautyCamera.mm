//
//  BeautyCamera.m
//  Lookon
//
//  Created by My Star on 8/24/17.
//  Copyright © 2017 My Star. All rights reserved.
//

#import "BeautyCamera.h"
#import <GPUImage/GPUImage.h>
#import "GPUImageBeautifyFilter.h"

@interface BeautyCamera ()<AVCaptureMetadataOutputObjectsDelegate>{
    dispatch_queue_t _serialMetadataQueue;
    dispatch_queue_t _serialTrackerQueue;
    NSMutableArray* arrayRect;
    CMSampleBufferRef m_sampleBuffer;
    NSLock *lock;
    AVCaptureDevicePosition currentPos;
    
    BOOL faceTack;
    GPUImageBeautifyFilter *beautifyFilter;
}

@property (nonatomic, strong) GPUImageStillCamera *videoCamera;
@property (nonatomic, strong) GPUImageView *filterView;

@end
@implementation BeautyCamera
@synthesize flashEnable;
-(id)initWithCameraSession:(UIView*)view  cameraPosition:(AVCaptureDevicePosition)cameraPosition{
    
    self.videoCamera = [[GPUImageStillCamera alloc] initWithSessionPreset:AVCaptureSessionPresetPhoto cameraPosition:cameraPosition];
 
    currentPos=cameraPosition;
    self.videoCamera.outputImageOrientation = UIInterfaceOrientationPortrait;
    self.videoCamera.horizontallyMirrorFrontFacingCamera = YES;
    self.filterView = [[GPUImageView alloc] initWithFrame:view.frame];
    self.filterView.center = view.center;
    [view addSubview:self.filterView];
    [self.videoCamera addTarget:self.filterView];    
   
    [self.videoCamera removeAllTargets];
    beautifyFilter = [[GPUImageBeautifyFilter alloc] init];
    [self.videoCamera addTarget:beautifyFilter];
    [beautifyFilter addTarget:self.filterView];
    
    _serialMetadataQueue = dispatch_queue_create( "com.nga.GLFace.serialMetadataQueue", DISPATCH_QUEUE_SERIAL );
    _serialTrackerQueue = dispatch_queue_create( "com.nga.GLFace.serialTrackerQueue", DISPATCH_QUEUE_SERIAL );
    AVCaptureMetadataOutput *metadataOutput = [AVCaptureMetadataOutput new];
    [metadataOutput setMetadataObjectsDelegate:self queue:_serialMetadataQueue];
    if ( [self.videoCamera.captureSession canAddOutput:metadataOutput] )
    {
        [self.videoCamera.captureSession addOutput:metadataOutput];
        metadataOutput.metadataObjectTypes = @[AVMetadataObjectTypeFace];
    }
    lock=[[NSLock alloc ] init];
    faceTack=YES;
    return [super init];
}

- (void)startCamera{
    [self.videoCamera startCameraCapture];
}
-(void)pauseCamera{
    [self.videoCamera pauseCameraCapture];
}
- (void)stopCamera{
    [self.videoCamera stopCameraCapture];
}
- (void)takePhotoWithCompletion:(void (^)(NSData *))completion{
    if(flashEnable==YES){
    [self flashTurnoffon:YES];
    [NSTimer scheduledTimerWithTimeInterval:0.5
                                     target:self
                                   selector:@selector(delayCamera:)
                                   userInfo:nil
                                    repeats:NO];
     }
    
    [self.videoCamera  capturePhotoAsJPEGProcessedUpToFilter:beautifyFilter withCompletionHandler:^(NSData *processedJPEG, NSError *error){
        dispatch_async(dispatch_get_main_queue(), ^(void) {
            completion(processedJPEG);
        });

    }];
   
}
-(void)delayCamera:(NSTimer *)timer{
    [self flashTurnoffon:NO];
    
}
-(void)rotateCamera{
    [self.videoCamera rotateCamera];
    if(currentPos==AVCaptureDevicePositionBack){
        currentPos=AVCaptureDevicePositionFront;
    }else{
        currentPos=AVCaptureDevicePositionBack;
    }
}
-(void)flashTurnoffon:(BOOL) flg{
    
    
    if( currentPos==AVCaptureDevicePositionBack){
        
        AVCaptureDevice *flashLight = [AVCaptureDevice defaultDeviceWithMediaType:AVMediaTypeVideo];
        
        if ([flashLight isTorchAvailable] && [flashLight isTorchModeSupported:AVCaptureTorchModeOn])
        {
            
            BOOL success = [flashLight lockForConfiguration:nil];
            
            if (success)
            {
                if ([flashLight isTorchActive] && flg==NO)
                {
                    
                    [flashLight setTorchMode:AVCaptureTorchModeOff];
                }
                else if( flg==YES)
                {
                    
                    [flashLight setTorchMode:AVCaptureTorchModeOn];
                }
                [flashLight unlockForConfiguration];
            }
        }
    }
}
- (BOOL )IsFlash
{
    NSArray *devices = [AVCaptureDevice devicesWithMediaType:AVMediaTypeVideo];
    
    AVCaptureDevice *device = nil;
    
    for ( AVCaptureDevice *dev in devices )
    {
        if ( [dev position] == currentPos )
        {
            device = dev;
            break;
        }
    }
    return device.isFlashAvailable;
}
-(AVCaptureDevice*) getCurrentCamera{
    NSArray *devices = [AVCaptureDevice devicesWithMediaType:AVMediaTypeVideo];
    
    AVCaptureDevice *device = nil;
    
    for ( AVCaptureDevice *dev in devices )
    {
        if ( [dev position] == currentPos )
        {
            device = dev;
            break;
        }
    }
    return device;
}
 @end
