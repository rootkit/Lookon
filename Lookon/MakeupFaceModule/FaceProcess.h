//
//  FaceProcess.h
//  Lookon
//
//  Created by My Star on 8/17/17.
//  Copyright © 2017 My Star. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "FaceImage.h"
#define Process  FaceProcess.sharedInstance
@interface FaceProcess : NSObject
+ (FaceProcess *)sharedInstance;
- (void)remeshEyes:(FaceImage**)face;
- (void)autoBirghtness:(FaceImage**)src;
- (void)mixSeamlessCloneSrc:(FaceImage*)src addDestination:(FaceImage**)dst;
- (FaceImage*)beautyMixBound:(int)depth addFace:(FaceImage*)face addBack:(FaceImage*)back;
- (void)blurMixBound:(int)depth addFace:(FaceImage*)face addBack:(FaceImage**)back;
- (void)ovelayImageOnFace:(FaceImage**)face;
- (void)faceInFace:(FaceImage*)smallFace addDestination:(FaceImage**)largeFace Rect:(cv::Rect)rect;
- (UIImage*)Jpg2Png:(UIImage*)image;
- (void)eyePupilReplace:(FaceImage**)face;
-(void)curvesColorChange:(FaceImage**)face StartCurvePoint:(cv::Point) px1 EndCurvePoint:(cv::Point) px2;
@end
