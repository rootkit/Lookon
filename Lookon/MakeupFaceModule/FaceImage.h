//
//  FaceImage.h
//  Lookon
//
//  Created by My Star on 8/14/17.
//  Copyright © 2017 My Star. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Utils.h"
#define IndicesNumber 49
@interface FaceImage : NSObject{
    

}
-(void)destroy;
-(std::vector<cv::Point>)getFeaturePointsWithStartIndex:(int)i endPoint:(int)j;
-(void)keepFromFaceFeatures:(FaceImage*)face Start:(int)ii End:(int)jj;
-(cv::Mat)checkFacialFeaturePoint;
-(cv::Mat)checkTriangleMesh:(int)type;
-(FaceImage*)clone;
-(cv::Rect)resizeByFaceBound:(float)rate;
-(void)changeForehead:(float)fact;
-(cv::Mat)getBlurBackGroundImage;
-(UIImage*)getOverlayImage;
-(UIImage *)getUIImage;
-(void)setImagesWithName:(NSString*)imagename;
@property (nonatomic)  std::vector<cv::Point> facelandmark;
@property cv::Mat src_image;
@property float scale;
@property int meshCount;
@property short* faceMeshIndices;
@property NSString* imageName;
@end

