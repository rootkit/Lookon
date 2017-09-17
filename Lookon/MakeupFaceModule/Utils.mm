//
//  Utils.m
//  Lookon
//
//  Created by My Star on 8/14/17.
//  Copyright © 2017 My Star. All rights reserved.
//

#import "Utils.h"
static Util *_sharedInstance;
@implementation Util
+ (Util *)sharedInstance
{
    
    if ( !_sharedInstance )
    {
        _sharedInstance = [Util new];
    }
    return _sharedInstance;
}
- (cv::Mat)cvMatFromUIImage:(UIImage *)image
{
    CGColorSpaceRef colorSpace = CGImageGetColorSpace(image.CGImage);
    CGFloat cols = image.size.width;
    CGFloat rows = image.size.height;
    
    cv::Mat cvMat(rows, cols, CV_8UC4); // 8 bits per component, 4 channels (color channels + alpha)
    
    CGContextRef contextRef = CGBitmapContextCreate(cvMat.data,                 // Pointer to  data
                                                    cols,                       // Width of bitmap
                                                    rows,                       // Height of bitmap
                                                    8,                          // Bits per component
                                                    cvMat.step[0],              // Bytes per row
                                                    colorSpace,                 // Colorspace
                                                    kCGImageAlphaNoneSkipLast |
                                                    kCGBitmapByteOrderDefault); // Bitmap info flags
    
    CGContextDrawImage(contextRef, CGRectMake(0, 0, cols, rows), image.CGImage);
    CGContextRelease(contextRef);
    
    return cvMat;
}

void UIImageToMat(const UIImage* image, cv::Mat& m,
                  bool alphaExist = false)
{
    CGColorSpaceRef colorSpace = CGImageGetColorSpace(image.
                                                      CGImage);
    CGFloat cols = image.size.width, rows = image.size.height;
    CGContextRef contextRef;
    CGBitmapInfo bitmapInfo = kCGImageAlphaPremultipliedLast;
    if (CGColorSpaceGetModel(colorSpace) == 0)
    {
        m.create(rows, cols, CV_8UC1);
        //8 bits per component, 1 channel
        bitmapInfo = kCGImageAlphaNone;
        if (!alphaExist)
            bitmapInfo = kCGImageAlphaNone;
        contextRef = CGBitmapContextCreate(m.data, m.cols, m.rows,
                                           8,
                                           m.step[0], colorSpace,
                                           bitmapInfo);
    }
    else
    {
        m.create(rows, cols, CV_8UC4); // 8 bits per component, 4
    
        if (!alphaExist)
            bitmapInfo = kCGImageAlphaNoneSkipLast |
            kCGBitmapByteOrderDefault;
        contextRef = CGBitmapContextCreate(m.data, m.cols, m.rows,
                                           8,
                                           m.step[0], colorSpace,
                                           bitmapInfo);
    }
    CGContextDrawImage(contextRef, CGRectMake(0, 0, cols, rows),
                       image.CGImage);
    CGContextRelease(contextRef);
}
- (void)cropMatchWithUIImage:(UIImageView**)view from:(cv::Mat)src{
     cv::Mat res;
    float rate=(*view).frame.size.height/(*view).frame.size.width;
    float RealWidth=src.cols;
    float RealHeight=src.cols*rate;
    if(src.rows>RealHeight){
  
        cv::Rect rect=cv::Rect(0,(src.rows-RealHeight)/2,(int)RealWidth,(int)RealHeight);
       
        res=src(rect);
    }else{
        RealHeight=src.rows;
        RealWidth=src.rows/rate;
        cv::Rect rect=cv::Rect((src.cols-RealWidth)/2,0,(int)RealWidth,(int)RealHeight);
        res=src(rect);
    }

    (*view).image=[self UIImageFromCVMat:res];
}
- (cv::Mat)cvMatGrayFromUIImage:(UIImage *)image
{
    CGColorSpaceRef colorSpace = CGImageGetColorSpace(image.CGImage);
    CGFloat cols = image.size.width;
    CGFloat rows = image.size.height;
    
    cv::Mat cvMat(rows, cols, CV_8UC1); // 8 bits per component, 1 channels
    
    CGContextRef contextRef = CGBitmapContextCreate(cvMat.data,                 // Pointer to data
                                                    cols,                       // Width of bitmap
                                                    rows,                       // Height of bitmap
                                                    8,                          // Bits per component
                                                    cvMat.step[0],              // Bytes per row
                                                    colorSpace,                 // Colorspace
                                                    kCGImageAlphaNoneSkipLast |
                                                    kCGBitmapByteOrderDefault); // Bitmap info flags
    
    CGContextDrawImage(contextRef, CGRectMake(0, 0, cols, rows), image.CGImage);
    CGContextRelease(contextRef);
    
    return cvMat;
}


-(UIImage *)UIImageFromCVMat:(cv::Mat)cvMat
{
    NSData *data = [NSData dataWithBytes:cvMat.data length:cvMat.elemSize()*cvMat.total()];
    CGColorSpaceRef colorSpace;
    
    if (cvMat.elemSize() == 1) {
        colorSpace = CGColorSpaceCreateDeviceGray();
    } else {
        colorSpace = CGColorSpaceCreateDeviceRGB();
    }
    
    CGDataProviderRef provider = CGDataProviderCreateWithCFData((__bridge CFDataRef)data);
    
    // Creating CGImage from cv::Mat
    CGImageRef imageRef = CGImageCreate(cvMat.cols,                                 //width
                                        cvMat.rows,                                 //height
                                        8,                                          //bits per component
                                        8 * cvMat.elemSize(),                       //bits per pixel
                                        cvMat.step[0],                            //bytesPerRow
                                        colorSpace,                                 //colorspace
                                        kCGImageAlphaNone|kCGBitmapByteOrderDefault,// bitmap info
                                        provider,                                   //CGDataProviderRef
                                        NULL,                                       //decode
                                        false,                                      //should interpolate
                                        kCGRenderingIntentDefault                   //intent
                                        );
    
    
    // Getting UIImage from CGImage
    UIImage *finalImage = [UIImage imageWithCGImage:imageRef];
    CGImageRelease(imageRef);
    CGDataProviderRelease(provider);
    CGColorSpaceRelease(colorSpace);
    
    return finalImage;
}
cv::Mat affineTriangle(cv::Point2f srcTri[3],cv::Point2f dstTri[3], cv::Mat &dstImage,cv::Mat srcImage){
    
    cv::Mat warp_mat( 2, 3, CV_32FC1 );
    
    cv::Mat warp_dst = cv::Mat::zeros( dstImage.rows, dstImage.cols, dstImage.type());
    
    /// Get the Affine Transform
    warp_mat = getAffineTransform( srcTri, dstTri );
    
    
    
    /// Apply the Affine Transform just found to the src image
    warpAffine( srcImage, warp_dst, warp_mat, warp_dst.size(), cv::INTER_CUBIC, cv::BORDER_REFLECT_101);
    std::vector<cv::Point> pts;
    pts.push_back(dstTri[0]);
    pts.push_back(dstTri[1]);
    pts.push_back(dstTri[2]);
    // cv::Mat dst(dstImage.size(), dstImage.type(), cv::Scalar(0));
    cropPolygon(pts, warp_dst,dstImage);
    
    return warp_mat;
}
void cropPolygon(std::vector<cv::Point> pts,cv::Mat src,cv::Mat& dst){
    cv::Mat mask = cv::Mat::zeros( src.size(), CV_8UC1 );
    fillConvexPoly( mask, pts, cv::Scalar( 255 ));
    cv::Rect rect = boundingRect( pts );
    if(rect.x<0 || rect.y<0 || rect.x+rect.width>=src.cols || rect.y+rect.height>=src.rows)return ;
    if(rect.x<0 || rect.y<0 || rect.x+rect.width>=dst.cols || rect.y+rect.height>=dst.rows)return ;
    cv::Mat roi = src( rect ).clone();
    mask = mask( rect ).clone();
    cv::Mat srcROI = dst( rect );
    roi.copyTo( srcROI, mask );
    
}
cv::Mat seamlessPts(cv::Mat src ,cv::Mat dst, std::vector<cv::Point>pts){
    cv::Mat res=dst.clone();
    cv::Mat srcImage=cv::Mat::zeros( src.size(), CV_8UC3 );
    cv::Mat dstImage=cv::Mat::zeros( dst.size(), CV_8UC3 );
    cv::Mat resImage=cv::Mat::zeros( dst.size(), CV_8UC3 );;
    cv::cvtColor(src, srcImage, CV_RGBA2RGB);
    cv::cvtColor(res, dstImage, CV_RGBA2RGB);
    
    cv::Mat mask = cv::Mat::zeros(dstImage.rows, dstImage.cols, dstImage.depth());
    
    
    
    std::vector<std::vector<cv::Point> > fillContAll;
    
    fillContAll.push_back(pts);
    
    cv::fillPoly( mask, fillContAll,  cv::Scalar( 255, 255, 255));
    
    
    cv::Rect r = cv::boundingRect(pts);
    cv::Point center = (r.tl() + r.br()) / 2;
    cv::seamlessClone(srcImage,dstImage,  mask,center , resImage, cv::NORMAL_CLONE);
    
    
    
    cv::cvtColor(resImage, res, CV_RGB2RGBA);
    return res;
    
}

cv::Mat mixSrcBackMask(cv::Mat src,cv::Mat mask,cv::Mat back)
{
    cv::Mat res;
    
    cv::Mat sc = src.clone();
    cv::Mat bk=back.clone();
    
    res= bk.clone();
    
    for (int x = 0; x < sc.cols; x++)
    {
        for (int y = 0; y < sc.rows; y++)
        {
            
            int R = cv::saturate_cast<uchar>((sc.at<cv::Vec4b>(y, x)[0]));
            int G = cv::saturate_cast<uchar>((sc.at<cv::Vec4b>(y, x)[1]));
            int B = cv::saturate_cast<uchar>((sc.at<cv::Vec4b>(y, x)[2]));
            int mR = cv::saturate_cast<uchar>((mask.at<cv::Vec4b>(y, x)[0]));
            int bRR = cv::saturate_cast<uchar>((bk.at<cv::Vec4b>(y, x)[0]));
            int bGG = cv::saturate_cast<uchar>((bk.at<cv::Vec4b>(y, x)[1]));
            int bBB = cv::saturate_cast<uchar>((bk.at<cv::Vec4b>(y, x)[2]));
            
            
            float rf=mR/255.0;
            float rt=rf;
            int  RR = (R*rt + bRR*(1-rt));
            int  GG = (G*rt + bGG*(1-rt));
            int  BB = (B*rt + bBB*(1-rt));
            
            res.at<cv::Vec4b>(y, x)[0] = RR;
            res.at<cv::Vec4b>(y, x)[1] = GG;
            res.at<cv::Vec4b>(y, x)[2] = BB;
            res.at<cv::Vec4b>(y, x)[3] = 255;
            
            
        }
    }
    
    
    return res;
}
cv::Rect resizeRect(cv::Rect rect,float rate){
    cv::Rect new_size(
                      rect.x-rate*rect.width/2,
                      rect.y-rate*rect.height/2,
                      rect.width*(1+rate),
                      rect.height*(1+rate));
    return new_size;
}
@end
