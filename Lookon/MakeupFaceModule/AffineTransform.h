//
//  AffinTransform.h
//  Lookon
//
//  Created by My Star on 8/14/17.
//  Copyright © 2017 My Star. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "FaceImage.h"
@interface AffineTransform : NSObject
-(FaceImage*)transformAffine:(FaceImage*)dst addSource:(FaceImage*)src;
-(FaceImage*)transformRectAffine:(FaceImage*)dst addSource:(FaceImage*)src;
-(void)testWrapAffine:(cv::Mat&)dstImage addSource:(cv::Mat)srcImage;
@end
