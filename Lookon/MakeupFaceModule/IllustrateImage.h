//
//  IllustrateImage.h
//  Lookon
//
//  Created by My Star on 9/1/17.
//  Copyright © 2017 My Star. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "FaceImage.h"
@interface IllustrateImage : FaceImage
@property cv::Scalar lipColor;
@property cv::Scalar eyeshadowColor;
@property cv::Scalar eyelineColor;
@property cv::Mat result;
-(IllustrateImage*)clone;
-(IllustrateImage*)overSet:(FaceImage*)face;
-(void)savefacialfeature:(UIViewController*)viewController;
-(BOOL)loadFacialFeature;
@end
