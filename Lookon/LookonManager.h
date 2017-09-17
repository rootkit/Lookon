//
//  LookonManager.h
//  Lookon
//
//  Created by My Star on 8/15/17.
//  Copyright © 2017 My Star. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "IllustrateImage.h"
#define AppManager  LookonManager.sharedInstance
@interface LookonManager : NSObject{
    
}
+ (LookonManager *)sharedInstance;
- (id)init;
- (BOOL)isReady;
- (BOOL)faceDectection:(FaceImage**)face;
- (void)appendIllustrate:(NSString*)imagePath;
- (void)sendFacialData:(int)index addViewController:(UIViewController*)viewController;
- (void)processIllustrate:(int)index;
- (void)loadAsset;
@property  FaceImage *userFace;
@property  cv::Mat_<double> shape2D;
@property  cv::Mat_<int> visibilities;
@property   cv::Mat preview_image;
@property  int current_index;
@property  BOOL startFlag;
@property  NSMutableArray *thumbnailSamples;
@property  NSMutableArray *illustratesDetectArrays;
@property  UIViewController* camera_viewer;
@property  UIViewController* main_viewer;
@property  UIViewController* preview_viewer;
@end
