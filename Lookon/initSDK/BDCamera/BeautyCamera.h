//
//  BeautyCamera.h
//  Lookon
//
//  Created by My Star on 8/24/17.
//  Copyright © 2017 My Star. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <AVFoundation/AVFoundation.h>
#import <UIKit/UIKit.h>
#import "DlibWrapper.h"
@interface BeautyCamera : NSObject
- (void)startCamera;
- (void)stopCamera;
- (void)pauseCamera;
- (id)initWithCameraSession:(UIView*)view  cameraPosition:(AVCaptureDevicePosition)cameraPosition;
- (void)takePhotoWithCompletion:(void (^)(NSData *))completion;
- (void)rotateCamera;
- (BOOL )IsFlash;
- (AVCaptureDevice*) getCurrentCamera;
@property BOOL flashEnable;
@end
