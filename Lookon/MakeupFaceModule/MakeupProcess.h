//
//  MakeupProcess.h
//  Lookon
//
//  Created by My Star on 8/23/17.
//  Copyright © 2017 My Star. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "FaceImage.h"
#define Makeup  MakeupProcess.sharedInstance
@interface MakeupProcess : NSObject
+ (MakeupProcess *)sharedInstance;
- (void)lipSticker:(FaceImage**)face addColor:(cv::Scalar)color;
- (FaceImage*)drawEyeBrows:(FaceImage*)face;
- (void) eyeShadow:(FaceImage**)face addColor:(cv::Scalar)color;
- (void) eyeLine:(FaceImage**)face addColor:(cv::Scalar)color;
- (void)changeEyeSize:(FaceImage**)face  Scale:(float)scale;
- (void)overdrawEyes:(FaceImage**)face  src:(FaceImage*)initface opacity:(float)opacity;
@end
