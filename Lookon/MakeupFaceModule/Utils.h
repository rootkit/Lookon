//
//  Utils.h
//  Lookon
//
//  Created by My Star on 8/14/17.
//  Copyright © 2017 My Star. All rights reserved.
//
#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#include <iostream>
#include <fstream>
#include <sstream>

// OpenCV includes
#include <opencv2/videoio/videoio.hpp>  // Video write
#include <opencv2/videoio/videoio_c.h>  // Video write
#include <opencv2/imgproc.hpp>
#include <opencv2/photo.hpp>
#include <opencv2/highgui/highgui.hpp>



#define Utils  Util.sharedInstance
@interface Util : NSObject
+ (Util *)sharedInstance;
- (cv::Mat)cvMatFromUIImage:(UIImage *)image;
- (cv::Mat)cvMatGrayFromUIImage:(UIImage *)image;
- (UIImage *)UIImageFromCVMat:(cv::Mat)cvMat;
cv::Mat affineTriangle(cv::Point2f srcTri[3],cv::Point2f dstTri[3], cv::Mat &dstImage,cv::Mat srcImage);
cv::Mat mixSrcBackMask(cv::Mat src,cv::Mat mask,cv::Mat back);
cv::Mat seamlessPts(cv::Mat src ,cv::Mat dst, std::vector<cv::Point>pts);
cv::Rect resizeRect(cv::Rect rect,float rate);
- (void)cropMatchWithUIImage:(UIImageView**)view from:(cv::Mat)src;
@end
