//
//  DlibWrapper.h
//  DisplayLiveSamples
//
//  Created by Luis Reisewitz on 16.05.16.
//  Copyright © 2016 ZweiGraf. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreMedia/CoreMedia.h>
#import "Utils.h"
#define Tracker  DlibWrapper.sharedInstance
@interface DlibWrapper : NSObject

- (instancetype)init;
+ (DlibWrapper *)sharedInstance;
- (void)prepare;
- (void)doWorkOnSampleBuffer:(CMSampleBufferRef)sampleBuffer inRects:(NSArray<NSValue *> *)rects;
@property std::vector<cv::Point>facelandmark;
-(BOOL)findFaceLandMark:(UIImage*)image;
@end
