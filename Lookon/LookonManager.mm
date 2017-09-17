//
//  LookonManager.m
//  Lookon
//
//  Created by My Star on 8/15/17.
//  Copyright © 2017 My Star. All rights reserved.
//

#import "LookonManager.h"
#include "DlibWrapper.h"
#import "AffineTransform.h"
#import "FaceProcess.h"
#import "MakeupProcess.h"
#import "CameraViewController.h"
#import "PreviewController.h"
#import "IllustrateViewController.h"
#import <MessageUI/MFMailComposeViewController.h>
#define kThumbnailSamples @[@"1_illustrate_thumbnail.png",@"2_illustrate_thumbnail.png",@"3_illustrate_thumbnail.png",@"4_illustrate_thumbnail.png",@"5_illustrate_thumbnail.png",@"6_illustrate_thumbnail.png",@"7_illustrate_thumbnail.png"]
static LookonManager *_sharedInstance;
@interface LookonManager(){

    BOOL reading;
    UIViewController *selfViewController;

    BOOL process_image;

}

@end
@implementation LookonManager
@synthesize  userFace,shape2D,visibilities,startFlag,illustratesDetectArrays,current_index,thumbnailSamples,preview_image,main_viewer,camera_viewer,preview_viewer;
+ (LookonManager *)sharedInstance
{
    
    if ( !_sharedInstance )
    {
        _sharedInstance = [LookonManager new];       
        
        
    }
    return _sharedInstance;
}
-(id)init{
    reading=NO;
    id res=[super init];
    userFace=[FaceImage new];
   // facetracking=[[FaceARDetectIOS alloc] init];
     illustratesDetectArrays=[NSMutableArray new];
     reading=YES;
     process_image=YES;
    
    NSString * storyboardName = @"Main";
    
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:storyboardName bundle: nil];
    CameraViewController* cameraViewer = (CameraViewController*)[storyboard instantiateViewControllerWithIdentifier:@"CameraViewController"];
    PreviewController*  preViewer = (PreviewController*)[storyboard instantiateViewControllerWithIdentifier:@"PreviewController"];
    IllustrateViewController*  mainViewer = (IllustrateViewController*)[storyboard instantiateViewControllerWithIdentifier:@"IllustrateViewController"];
    camera_viewer=cameraViewer;
    preview_viewer=preViewer;
    main_viewer=mainViewer;
    
    return res;
}
-(void)appendIllustrate:(NSString*)imagePath{
    
   IllustrateImage *face=[IllustrateImage new];
   [face setImagesWithName:imagePath];
    if(![face loadFacialFeature]){
    BOOL res= [self faceDectection:&face];
    if(res)[illustratesDetectArrays addObject:face];
    }else [illustratesDetectArrays addObject:face];
}
-(BOOL)checkFacialFeature:(FaceImage**)face{
    NSString* fileName;
    fileName= [(*face).imageName stringByReplacingOccurrencesOfString:@"sample.png"
                                                        withString:@"data"];
    
    NSString *url1 = [[NSBundle mainBundle] pathForResource:fileName ofType:@"txt"];
    if(url1==nil) return NO;
    NSString * data = [NSString stringWithContentsOfFile:url1 encoding:NSUTF8StringEncoding error:nil];
    NSMutableArray *array=(NSMutableArray*)[data componentsSeparatedByString:@"\n"];
    std::vector<cv::Point>temp;
    for (int i=0;i<[array count];i++)
    {
        NSString *v=[array objectAtIndex:i];
        NSMutableArray *arrayPt =[v componentsSeparatedByString:@" "];
        temp.push_back(cv::Point([[arrayPt objectAtIndex:0] intValue],[[arrayPt objectAtIndex:1] intValue]));
    }
    (*face).facelandmark=temp;
    return YES;
}
-(BOOL)faceDectection:(FaceImage**)face{

    UIImage*image=(*face).getUIImage;
    BOOL res=[Tracker findFaceLandMark:image];
    if(res==NO) NSLog(@"Can't detect face in current Image");
    (*face).src_image.release();
    (*face).facelandmark=Tracker.facelandmark;
    return  res;
}
-(BOOL)isReady{
    return reading;
}
-(void)loadAsset{

    
    //dispatch_async(_serialloadQueue, ^{
    NSArray * imagesArray=kThumbnailSamples;
    thumbnailSamples=[[NSMutableArray alloc] initWithCapacity:imagesArray.count];
    
    for (NSString *name in imagesArray){
        
        
        NSString *sample= [name stringByReplacingOccurrencesOfString:@"thumbnail"
                                                          withString:@"sample"];
        UIImage *image=[UIImage imageNamed:name];
        [thumbnailSamples addObject:image];
        [self appendIllustrate:sample];
    }

    //  });
    
}

-(void)sendFacialData:(int)index addViewController:(UIViewController*)viewController{

    FaceImage *face=[illustratesDetectArrays objectAtIndex:index];
    NSString* fileName;
     fileName= [face.imageName stringByReplacingOccurrencesOfString:@"sample.png"
                                                 withString:@"data"];

    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory = [paths objectAtIndex:0]; // Get documents directory
    NSString *appFile=[fileName stringByAppendingString:@".txt"];
    NSString * path=[NSString stringWithFormat:@"%@",[ documentsDirectory stringByAppendingPathComponent:appFile] ];
    
    NSError *error;
    NSString *vertex_data=[[NSString alloc] init];
    
    for (int i=0;i<face.facelandmark.size();i++){
        vertex_data= [vertex_data stringByAppendingString:[NSString stringWithFormat:@"%d %d\n",face.facelandmark[i].x ,face.facelandmark[i].y]];
    }
    BOOL succeed = [vertex_data writeToFile:path
                                 atomically:YES encoding:NSUTF8StringEncoding error:&error];
    if(succeed){
        selfViewController=viewController;
        [self displayComposerSheet:path saveFileName:appFile];
    }


}
-(void)displayComposerSheet:(NSString*)filePath saveFileName:(NSString*)filename
{
    MFMailComposeViewController *picker = [[MFMailComposeViewController alloc] init];
    picker.mailComposeDelegate = self;
    [picker setSubject:@"Data File"];
    
    
    NSData *myData = [NSData dataWithContentsOfFile:filePath];
    [picker addAttachmentData:myData mimeType:@"text/plain" fileName:filename];
    
    // Fill out the email body text
    NSString *emailBody = @"Text file";
    [picker setMessageBody:emailBody isHTML:NO];
    
    [selfViewController presentModalViewController:picker animated:YES];
    
    
}

- (void)processIllustrate:(int)index{
    

    
    if(process_image==YES){
        
        process_image=NO;     

            
            
            
                IllustrateImage* demo = (IllustrateImage *)[AppManager.illustratesDetectArrays objectAtIndex:index];
            
        
                IllustrateImage *illustrate=demo.clone;
                
                illustrate.src_image=[demo getBlurBackGroundImage];
                
                FaceImage *cropIllustrate=demo.clone;
        
                cropIllustrate.src_image=[demo getBlurBackGroundImage];
                
                [cropIllustrate changeForehead:0];
                
                cv::Rect rect=[cropIllustrate resizeByFaceBound:0.4];
                
                FaceImage *user=AppManager.userFace;
                
                FaceImage *smallUserFace=user.clone;
                
                [smallUserFace resizeByFaceBound:0.4];
                
                [Process autoBirghtness:&smallUserFace];
                
                
                FaceImage *affineFace = [[[AffineTransform alloc] init] transformAffine:cropIllustrate addSource:smallUserFace];
        
                [smallUserFace destroy];

                FaceImage *faceDetect=[FaceImage new];
                faceDetect.src_image=affineFace.src_image;
                [AppManager faceDectection:&faceDetect];
                
                [affineFace keepFromFaceFeatures:faceDetect Start:48 End:67];
                [affineFace changeForehead:0];
        
                [faceDetect destroy];
              
                
                FaceImage *makeover=cropIllustrate.clone;
                
                [Process mixSeamlessCloneSrc:affineFace addDestination:&cropIllustrate];
                
                [Process curvesColorChange:&cropIllustrate StartCurvePoint:cv::Point(57,29) EndCurvePoint:cv::Point(190,190)];
        
                int size=cropIllustrate.src_image.cols;
        
                int depth=size/10;
                if(depth%2==0)depth++;
                [Process blurMixBound:depth addFace:cropIllustrate addBack:&makeover];
        
                 [cropIllustrate destroy];
        
                [makeover keepFromFaceFeatures:affineFace Start:0 End:(int)makeover.facelandmark.size()-1];
                
                //
        
                [affineFace destroy];
        
                [Makeup lipSticker:&makeover addColor:illustrate.lipColor];
                
                [Makeup eyeShadow:&makeover addColor:illustrate.eyeshadowColor];
                //
                [Makeup eyeLine:&makeover addColor:illustrate.eyelineColor];
                
                
                
                //
                [Process faceInFace:makeover addDestination:&illustrate Rect:rect];
        
        
        
                [Process ovelayImageOnFace:&illustrate];
        
                demo.result.release();
        
        demo.result=illustrate.src_image.clone() ;
     //   demo.result=[cropIllustrate checkTriangleMesh:0];
                [makeover destroy];
                [illustrate destroy];     
        
        
                  //  res = finalImage;
                    
            
             current_index=index;
            // UIImage*finalImage= [Utils UIImageFromCVMat:affineFace.src_image];
            
            
            // resultview= makeover.getUIImage;

            process_image=YES;
    }

}

- (void)mailComposeController:(MFMailComposeViewController*)controller didFinishWithResult:(MFMailComposeResult)result error:(NSError*)error
{
    // Notifies users about errors associated with the interface
    switch (result)
    {
        case MFMailComposeResultCancelled:
            NSLog(@"Result: canceled");
            break;
        case MFMailComposeResultSaved:
            NSLog(@"Result: saved");
            break;
        case MFMailComposeResultSent:
            NSLog(@"Result: sent");
            break;
        case MFMailComposeResultFailed:
            NSLog(@"Result: failed");
            break;
        default:
            NSLog(@"Result: not sent");
            break;
    }
    [selfViewController dismissModalViewControllerAnimated:YES];
}

@end
