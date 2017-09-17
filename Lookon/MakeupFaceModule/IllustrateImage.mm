//
//  IllustrateImage.m
//  Lookon
//
//  Created by My Star on 9/1/17.
//  Copyright © 2017 My Star. All rights reserved.
//

#import "IllustrateImage.h"
#import <MessageUI/MFMailComposeViewController.h>
@interface IllustrateImage(){
    UIViewController *selfViewController;
}
@end
@implementation IllustrateImage
@synthesize eyelineColor,eyeshadowColor,lipColor,result;

-(id)init{
    eyelineColor=cv::Scalar(14,12,10);
    eyeshadowColor=cv::Scalar(14,12,10);
    lipColor=cv::Scalar(196,36,80);
    return [super init];
}
-(IllustrateImage*)clone{
    
    IllustrateImage *res=[IllustrateImage new];
    res.src_image=super.src_image.clone();
    std::vector<cv::Point>temp;
    for (int i=0;i<super.facelandmark.size();i++)
        temp.push_back(super.facelandmark[i]);
    res.facelandmark=temp;

    res.scale=super.scale;
    res.imageName=[NSString stringWithFormat:@"%@",super.imageName];

    res.eyelineColor=eyelineColor;
    res.eyeshadowColor=eyeshadowColor;
    res.lipColor=lipColor;
    return res;
}
-(void)destory{
    [super clone];
    result.release();
}
-(IllustrateImage*)overSet:(FaceImage*)face{
    IllustrateImage *res=[IllustrateImage new];
    std::vector<cv::Point>temp;
    for (int i=0;i<face.facelandmark.size();i++)
        temp.push_back(face.facelandmark[i]);

    res.scale=face.scale;
    res.imageName=[NSString stringWithFormat:@"%@",face.imageName];
    
    res.eyelineColor=eyelineColor;
    res.eyeshadowColor=eyeshadowColor;
    res.lipColor=lipColor;

    return res;
}
-(BOOL)loadFacialFeature{
    NSString* fileName;
    fileName= [super.imageName stringByReplacingOccurrencesOfString:@"sample.png"
                                                           withString:@"data"];
    
    NSString *url1 = [[NSBundle mainBundle] pathForResource:fileName ofType:@"txt"];
    if(url1==nil) return NO;
    NSString * data = [NSString stringWithContentsOfFile:url1 encoding:NSUTF8StringEncoding error:nil];
    NSMutableArray *array=(NSMutableArray*)[data componentsSeparatedByString:@"\r\n"];
    std::vector<cv::Point>temp;
    for (int i=0;i<[array count];i++)
    {
        
        NSString *v=[array objectAtIndex:i];
        NSMutableArray *arrayPt =[v componentsSeparatedByString:@" "];
        switch (i) {
        case 0:{
            lipColor=cv::Scalar([[arrayPt objectAtIndex:1] intValue],[[arrayPt objectAtIndex:2] intValue],[[arrayPt objectAtIndex:3] intValue]);
            }
            break;
        case 1:{
            eyelineColor=cv::Scalar([[arrayPt objectAtIndex:1] intValue],[[arrayPt objectAtIndex:2] intValue],[[arrayPt objectAtIndex:3] intValue]);
            }
            break;
        case 2:{
            eyeshadowColor=cv::Scalar([[arrayPt objectAtIndex:1] intValue],[[arrayPt objectAtIndex:2] intValue],[[arrayPt objectAtIndex:3] intValue]);
            }
            break;
        default:{
            if([arrayPt count]==2)
            temp.push_back(cv::Point([[arrayPt objectAtIndex:0] intValue],[[arrayPt objectAtIndex:1] intValue]));

            }
                break;
        }
        
    }
    super.facelandmark=temp;
    return YES;
}
-(void)savefacialfeature:(UIViewController*)viewController{
    

    NSString* fileName;
    fileName= [super.imageName stringByReplacingOccurrencesOfString:@"sample.png"
                                                        withString:@"data"];
    
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory = [paths objectAtIndex:0]; // Get documents directory
    NSString *appFile=[fileName stringByAppendingString:@".txt"];
    NSString * path=[NSString stringWithFormat:@"%@",[ documentsDirectory stringByAppendingPathComponent:appFile] ];
    
    NSError *error;
    NSString *vertex_data=[[NSString alloc] init];
    
    vertex_data= [vertex_data stringByAppendingString:[NSString stringWithFormat:@"lip %d %d %d\n",(int)lipColor.val[0],(int)lipColor.val[1],(int)lipColor.val[2]]];
    vertex_data= [vertex_data stringByAppendingString:[NSString stringWithFormat:@"lip %d %d %d\n",(int)eyelineColor.val[0],(int)eyelineColor.val[1],(int)eyelineColor.val[2]]];
    vertex_data= [vertex_data stringByAppendingString:[NSString stringWithFormat:@"lip %d %d %d\n",(int)eyeshadowColor.val[0],(int)eyeshadowColor.val[1],(int)eyeshadowColor.val[2]]];
    for (int i=0;i<super.facelandmark.size();i++){
        NSString* format=@"%d %d\n";
        if(i==super.facelandmark.size()-1){
          format=@"%d %d";
        }
        vertex_data= [vertex_data stringByAppendingString:[NSString stringWithFormat:format,super.facelandmark[i].x,super.facelandmark[i].y]];
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
   // picker.mailComposeDelegate = self;
    [picker setSubject:@"Data File"];
    
    
    NSData *myData = [NSData dataWithContentsOfFile:filePath];
    [picker addAttachmentData:myData mimeType:@"text/plain" fileName:filename];
    
    // Fill out the email body text
    NSString *emailBody = @"Text file";
    [picker setMessageBody:emailBody isHTML:NO];
    
    [selfViewController presentModalViewController:picker animated:YES];
    
    
}

@end
