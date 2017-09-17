//
//  DlibWrapper.m
//  DisplayLiveSamples
//
//  Created by Luis Reisewitz on 16.05.16.
//  Copyright © 2016 ZweiGraf. All rights reserved.
//

#import "DlibWrapper.h"
#import <UIKit/UIKit.h>
#include <dlib/image_processing/frontal_face_detector.h>
#include <dlib/image_processing.h>
#include <dlib/image_io.h>
//#include <dlib/opencv/cv_image.h>

//#import "Utils.h"
@interface DlibWrapper ()

@property (assign) BOOL prepared;

+ (std::vector<dlib::rectangle>)convertCGRectValueArray:(NSArray<NSValue *> *)rects;

@end
static DlibWrapper *_sharedInstance;
@implementation DlibWrapper {
    dlib::shape_predictor sp;
    dlib::frontal_face_detector detector;
    CIDetector *faceDetector;

}
@synthesize  facelandmark;

- (instancetype)init {
    self = [super init];
    if (self) {
        _prepared = NO;
    }
    return self;
}
+ (DlibWrapper *)sharedInstance
{
    
    if ( !_sharedInstance )
    {
        _sharedInstance = [DlibWrapper new];
    }
    return _sharedInstance;
}
- (void)prepare {
    NSString *modelFileName = [[NSBundle mainBundle] pathForResource:@"shape_predictor_68_face_landmarks" ofType:@"dat"];

  //  NSString *location = [[NSBundle mainBundle] resourcePath];

    std::string modelFileNameCString = [modelFileName UTF8String];
    
    dlib::deserialize(modelFileNameCString) >> sp;
  //  NSDictionary *detectorOptions = @{ CIDetectorAccuracy : CIDetectorAccuracyHigh }; // TODO: read doc for more tuneups
    faceDetector = [CIDetector detectorOfType:CIDetectorTypeFace context:nil options:@{CIDetectorAccuracy: CIDetectorAccuracyLow}];
   
    // FIXME: test this stuff for memory leaks (cpp object destruction)
    self.prepared = YES;
}

//
//
//-(BOOL)oneImageProcessing:(cv::Mat)image{
//    
//   
//
//    if (!self.prepared) {
//        [self prepare];
//    }
//    
//    dlib::array2d<dlib::bgr_pixel> img;
//    cv::cvtColor(image, image, CV_RGBA2BGR);
//    dlib::assign_image(img, dlib::cv_image<dlib::bgr_pixel>(image));
//
//    
//  
//    
//
//    cv::Mat frame_gray;
//    
//    cvtColor( image, frame_gray, CV_BGR2GRAY );
//    equalizeHist( frame_gray, frame_gray );
// 
//    //-- Detect faces
//  
//    std::vector<cv::Rect> faces;
//    classifier.detectMultiScale(frame_gray, faces, 1.2, 2, CV_HAAR_SCALE_IMAGE, cv::Size(250, 250));
//
//    
//    
//    // convert the face bounds list to dlib format
//
//    std::vector<cv::Point> temp;
//    // for every detected face
//
//    for (unsigned long j = 0; j < faces.size(); ++j)
//    {
//        // detect all landmarks
//        dlib::full_object_detection shape = sp(img, dlib::rectangle(faces[j].x,faces[j].y,faces[j].x+faces[j].width,faces[j].y+faces[j].height));
//        
//        // and draw them into the image (samplebuffer)
//        for (unsigned long k = 0; k < shape.num_parts(); k++) {
//            dlib::point p = shape.part(k);
//            temp.push_back(cv::Point((int)p.x(),(int)p.y()));
//            // draw_solid_circle(img, p, 3, dlib::rgb_pixel(0, 255, 255));
//        }
//    }
//    facelandmark=temp;
//    return YES;
// }
-(BOOL)findFaceLandMark:(UIImage*)image{
    
    
    
    CIImage *ciImage = [CIImage imageWithCGImage:image.CGImage];
    NSArray *features = [faceDetector featuresInImage:ciImage options:nil];
    NSMutableArray *returnBounds = [NSMutableArray array];
    
    for (CIFeature *feature in features) {
        CGRect faceRect=[feature bounds];
        faceRect.origin.y = image.size.height - faceRect.origin.y - faceRect.size.height;
        [returnBounds addObject:[NSValue valueWithCGRect:faceRect]];
    }
//    int exifOrientation;
//    switch (image.imageOrientation) {
//        case UIImageOrientationUp:
//            exifOrientation = 1;
//            break;
//        case UIImageOrientationDown:
//            exifOrientation = 3;
//            break;
//        case UIImageOrientationLeft:
//            exifOrientation = 8;
//            break;
//        case UIImageOrientationRight:
//            exifOrientation = 6;
//            break;
//        case UIImageOrientationUpMirrored:
//            exifOrientation = 2;
//            break;
//        case UIImageOrientationDownMirrored:
//            exifOrientation = 4;
//            break;
//        case UIImageOrientationLeftMirrored:
//            exifOrientation = 5;
//            break;
//        case UIImageOrientationRightMirrored:
//            exifOrientation = 7;
//            break;
//        default:
//            break;
//    }
//
//
//    NSArray *features = [faceDetector featuresInImage:image.CIImage
//                                              options:@{CIDetectorImageOrientation:[NSNumber numberWithInt:exifOrientation]}];
    if([features count]==0)return NO;
//    NSMutableArray *boundArray=[NSMutableArray new];
//    for(CIFaceFeature* faceFeature in features)
//    {
//        
//        CGRect rect=faceFeature.bounds;
//       
//       [boundArray addObject: [NSValue valueWithCGRect:rect]];
//    }
      [ self doWorkOnPixelBuffer:[self pixelBufferFromCGImage:image.CGImage] inRects:returnBounds];
    return YES;
}
- (void)doWorkOnSampleBuffer:(CMSampleBufferRef)sampleBuffer inRects:(NSArray<NSValue *> *)rects {
    

    
    // MARK: magic
    CVImageBufferRef imageBuffer = CMSampleBufferGetImageBuffer(sampleBuffer);
   
    [ self doWorkOnPixelBuffer:imageBuffer inRects:rects];
        
    
  
}
- (void)doWorkOnPixelBuffer:(CVImageBufferRef)imageBuffer inRects:(NSArray<NSValue *> *)rects {
    
    if (!self.prepared) {
        [self prepare];
    }
    
    dlib::array2d<dlib::bgr_pixel> img;
    
    // MARK: magic

    //CVPixelBufferLockBaseAddress(imageBuffer, kCVPixelBufferLock_ReadOnly);
      CVPixelBufferLockBaseAddress(imageBuffer, 0);
    size_t width = CVPixelBufferGetWidth(imageBuffer);
    size_t height = CVPixelBufferGetHeight(imageBuffer);
    char *baseBuffer = (char *)CVPixelBufferGetBaseAddress(imageBuffer);
    
    
    // set_size expects rows, cols format
    img.set_size(height, width);
    
    // copy samplebuffer image data into dlib image format
    img.reset();
    long position = 0;
    while (img.move_next()) {
        dlib::bgr_pixel& pixel = img.element();
        
        // assuming bgra format here
        long bufferLocation = position * 4; //(row * width + column) * 4;
        char b = baseBuffer[bufferLocation];
        char g = baseBuffer[bufferLocation + 1];
        char r = baseBuffer[bufferLocation + 2];
        
        dlib::bgr_pixel newpixel(b, g, r);
        pixel = newpixel;
        
        position++;
    }
    
    // unlock buffer again until we need it again
    //CVPixelBufferUnlockBaseAddress(imageBuffer, kCVPixelBufferLock_ReadOnly);
     CVPixelBufferUnlockBaseAddress(imageBuffer, 0);
    
    // convert the face bounds list to dlib format
    std::vector<dlib::rectangle> convertedRectangles = [DlibWrapper convertCGRectValueArray:rects];
    std::vector<cv::Point>temp;
    // for every detected face
    for (unsigned long j = 0; j <1; ++j)
    {
        dlib::rectangle oneFaceRect = convertedRectangles[j];
        
        // detect all landmarks
        dlib::full_object_detection shape = sp(img, oneFaceRect);
        
        // and draw them into the image (samplebuffer)
        for (unsigned long k = 0; k < shape.num_parts(); k++) {
            dlib::point p = shape.part(k);
            temp.push_back(cv::Point((int)p.x(),(int)p.y()));
       // draw_solid_circle(img, p, 3, dlib::rgb_pixel(0, 255, 255));
        }
    }
    facelandmark=temp;
//    // lets put everything back where it belongs
//    CVPixelBufferLockBaseAddress(imageBuffer, 0);
//    
//    // copy dlib image data back into samplebuffer
//    img.reset();
//    position = 0;
//    while (img.move_next()) {
//        dlib::bgr_pixel& pixel = img.element();
//        
//        // assuming bgra format here
//        long bufferLocation = position * 4; //(row * width + column) * 4;
//        baseBuffer[bufferLocation] = pixel.blue;
//        baseBuffer[bufferLocation + 1] = pixel.green;
//        baseBuffer[bufferLocation + 2] = pixel.red;
//        //        we do not need this
//        //        char a = baseBuffer[bufferLocation + 3];
//        
//        position++;
//    }
//    CVPixelBufferUnlockBaseAddress(imageBuffer, 0);
}

+ (std::vector<dlib::rectangle>)convertCGRectValueArray:(NSArray<NSValue *> *)rects {
    std::vector<dlib::rectangle> myConvertedRects;
    for (NSValue *rectValue in rects) {
        CGRect rect = [rectValue CGRectValue];
        long left = rect.origin.x;
        long top = rect.origin.y;
        long right = left + rect.size.width;
        long bottom = top + rect.size.height;
        dlib::rectangle dlibRect(left, top, right, bottom);

        myConvertedRects.push_back(dlibRect);
    }
    return myConvertedRects;
}
- (CVPixelBufferRef) pixelBufferFromCGImage: (CGImageRef) image
{
    
    CGSize frameSize = CGSizeMake(CGImageGetWidth(image), CGImageGetHeight(image));
    NSDictionary *options = [NSDictionary dictionaryWithObjectsAndKeys:
                             [NSNumber numberWithBool:YES], kCVPixelBufferCGImageCompatibilityKey,
                             [NSNumber numberWithBool:YES], kCVPixelBufferCGBitmapContextCompatibilityKey,
                             nil];
    CVPixelBufferRef pxbuffer = NULL;
    CVReturn status = CVPixelBufferCreate(kCFAllocatorDefault, frameSize.width,
                                          frameSize.height, kCVPixelFormatType_32ARGB, (__bridge CFDictionaryRef) options,
                                          &pxbuffer);
    NSParameterAssert(status == kCVReturnSuccess && pxbuffer != NULL);
    
    CVPixelBufferLockBaseAddress(pxbuffer, 0);
    void *pxdata = CVPixelBufferGetBaseAddress(pxbuffer);
    NSParameterAssert(pxdata != NULL);
    
    CGColorSpaceRef rgbColorSpace = CGColorSpaceCreateDeviceRGB();
    CGContextRef context = CGBitmapContextCreate(pxdata, frameSize.width,
                                                 frameSize.height, 8, 4*frameSize.width, rgbColorSpace,
                                                 kCGImageAlphaNoneSkipFirst);
    NSParameterAssert(context);
    CGAffineTransform frameTransform=CGAffineTransformMakeRotation(0);
    CGContextConcatCTM(context, frameTransform);
    CGContextDrawImage(context, CGRectMake(0, 0, CGImageGetWidth(image),
                                           CGImageGetHeight(image)), image);
    CGColorSpaceRelease(rgbColorSpace);
    CGContextRelease(context);
    
    CVPixelBufferUnlockBaseAddress(pxbuffer, 0);
    
    return pxbuffer;
}

@end
