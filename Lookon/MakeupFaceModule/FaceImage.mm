//
//  FaceDetector.m
//  Lookon
//
//  Created by My Star on 8/14/17.
//  Copyright © 2017 My Star. All rights reserved.
//

#import "FaceImage.h"
#import "Utils.h"
#import "MySpline.h"
//unsigned short synFaceIndices[]={
//    19,21,27,
//    19,27,36,
//    36,27,30,
//    36,30,4,
//    4,30,33,
//    4,33,5,
//    5,33,51,
//    5,51,57,
//    5,57,8,
//    8,57,11,
//    11,57,51,
//    51,11,33,
//    33,11,12,
//    12,33,30,
//    30,12,45,
//    45,30,27,
//    27,45,24,
//    24,27,21
//};
//unsigned short fullvertex[]={
//  
//
//58,59,6,
//34,52,35,
//44,45,25,
//39,40,29,
//37,18,36,
//27,42,22,
//23,44,24,
//41,36,1,
//57,58,7,
//28,27,39,
//52,34,51,
//54,14,35,
//29,42,28,
//35,15,46,
//37,19,18,
//36,0,1,
//18,17,36,
//37,20,19,
//38,20,37,
//21,20,38,
//21,38,39,
//24,44,25,
//30,34,35,
//21,39,27,
//28,42,27,
//39,29,28,
//29,30,35,
//31,30,29,
//30,33,34,
//31,29,40,
//36,17,0,
//41,31,40,
//31,32,30,
//31,41,1,
//49,31,48,
//48,2,3,
//
//4,48,3,
//5,48,4,
//6,59,5,
//59,48,5,
//
//7,58,6,
//
//31,2,48,
//31,50,32,
//1,2,31,
//
//50,31,49,
//34,33,51,
//
//32,50,51,
//
//    
//54,55,11,
//57,8,9,
//8,57,7,
//56,57,9,
//    
//
//    
//10,56,9,
//55,56,10,
//53,54,35,
//53,35,52,
//12,54,11,
//55,10,11,
//    
//
//    
//12,13,54,
//14,54,13,
//15,35,14,
//47,35,46,
//33,32,51,
//30,32,33,
//29,35,47,
//15,45,46,
//22,21,27,
//43,23,22,
//29,47,42,
//22,42,43,
//23,43,44,
//45,16,26,
//15,16,45,
//25,45,26,
//41,36,37,
//40,41,37,
//38,40,37,
//39,40,38,
//47,42,43,
//46,47,43,
//46,43,44,
//45,46,44,
//48,49,59,
//49,59,50,
//50,59,58,
//50,58,51,
//58,51,57,
//51,57,56,
//51,56,52,
//52,56,53,
//53,56,55,
//53,55,54,
//    
//77,26,16,
//25,26,77,
//25,77,76,
//24,25,76,
//24,76,75,
//24,75,74,
//24,74,23,
//73,74,23,
//73,23,22,
//72,22,73,
//72,22,21,
//72,71,21,
//71,21,20,
//71,20,70,
//70,20,19,
//70,19,69,
//69,19,18,
//69,18,68,
//68,18,17,
//68,17,0
//    
//};
//unsigned short faceIndices2[]={
//58,67,59,
//60,49,48,
//58,59,6,
//34,52,35,
//44,45,25,
//39,40,29,
//37,18,36,
//27,42,22,
//23,44,24,
//41,36,1,
//50,62,51,
//57,58,7,
//28,27,39,
//52,34,51,
//54,14,35,
//29,42,28,
//19,20,24,
//35,15,46,
//37,19,18,
//36,0,1,
//18,17,36,
//37,20,19,
//38,20,37,
//21,20,38,
//21,38,39,
//24,44,25,
//30,34,35,
//21,39,27,
//28,42,27,
//39,29,28,
//29,30,35,
//31,30,29,
//30,33,34,
//31,29,40,
//36,17,0,
//41,31,40,
//31,32,30,
//31,41,1,
//49,31,48,
//48,2,3,
//67,60,59,
//4,48,3,
//5,48,4,
//6,59,5,
//59,48,5,
//60,48,59,
//7,58,6,
//61,49,60,
//58,66,67,
//31,2,48,
//31,50,32,
//1,2,31,
//61,50,49,
//52,62,63,
//50,31,49,
//34,33,51,
//51,62,52,
//32,50,51,
//50,61,62,
//63,53,52,
//54,55,11,
//57,8,9,
//66,58,57,
//8,57,7,
//56,57,9,
//66,57,56,
//10,56,9,
//55,56,10,
//53,54,35,
//53,35,52,
//12,54,11,
//55,10,11,
//65,56,55,
//64,55,54,
//65,55,64,
//54,53,64,
//12,13,54,
//14,54,13,
//15,35,14,
//47,35,46,
//33,32,51,
//30,32,33,
//29,35,47,
//15,45,46,
//22,21,27,
//20,21,23,
//43,23,22,
//29,47,42,
//23,21,22,
//24,20,23,
//22,42,43,
//23,43,44,
//45,16,26,
//15,16,45,
//25,45,26,
//    
//77,26,16,
//25,26,77,
//25,77,76,
//24,25,76,
//24,76,75,
//24,75,74,
//24,74,23,
//73,74,23,
//73,23,22,
//72,22,73,
//72,22,21,
//72,71,21,
//71,21,20,
//71,20,70,
//70,20,19,
//70,19,69,
//69,19,18,
//69,18,68,
//68,18,17,
//68,17,0
//
//};
//unsigned short faceSyncIndices[]={
//    0,68,6,
//    68,6,36,
//    3,0,6,
//    6,36,48,
//    6,48,7,
//    7,48,8,
//    8,48,54,
//    8,54,9,
//    9,54,10,
//    10,54,45,
//    
//    10,45,77,
//    10,77,16,
//    10,16,13,
//   
//    39,42,54,
//    39,54,48,
//    36,79,37,
//    79,37,80,
//    80,37,38,
//    80,38,81,
//    81,38,39,
//    36,48,37,
//    37,48,38,
//    38,48,39,
//    45,44,86,
//    44,86,85,
//    85,44,43,
//    85,43,84,
//    84,42,43,
//    42,54,43,
//    43,54,44,
//    44,54,45,   
//
//    
//   
//
//  
//
//    83,84,42,
//    83,42,39,
//    83,39,82,
//    81,82,39,
//
//
//  
//    78,36,79,
//
//  
//    45,86,87,
//
//    17,78,79,
//    17,79,18,
//    79,18,80,
//    18,80,19,
//    19,80,81,
//    19,81,20,
//    20,81,21,
//    81,21,82,
//    82,21,83,
//    21,83,22,
//    22,83,84,
//    22,84,23,
//    23,84,85,
//    23,85,24,
//    24,85,86,
//    24,86,25,
//    25,86,87,
//    25,87,26,
//    25,26,77,
//    25,77,76,
//    24,25,76,
//    24,76,75,
//    24,75,74,
//    24,74,23,
//    73,74,23,
//    73,23,22,
//    72,22,73,
//    72,22,21,
//    72,71,21,
//    71,21,20,
//    71,20,70,
//    70,20,19,
//    70,19,69,
//    69,19,18,
//    69,18,68,
//    68,18,17
//
//
//    
//    
//};
unsigned short faceSyncSkine[]={
    17,36,68,
    68,17,37,
    37,17,69,
    69,17,21,
    69,21,38,
    38,21,70,
    70,21,39,
    71,6,39,
    40,6,71,
    40,6,72,
    72,6,41,
    41,6,73,
    73,6,36,
    36,68,73,
    68,73,41,
    68,41,37,
    37,41,72,
    37,72,69,
    69,72,40,
    69,40,38,
    40,38,71,
    38,70,71,
    70,71,39,
    
    
    
    42,22,74,
    74,22,43,
    43,22,75,
    75,22,26,
    75,26,44,
    44,26,76,
    76,26,45,
    45,10,77,
    77,10,46,
    46,10,78,
    78,10,47,
    47,10,79,
    79,10,42,
    42,74,79,
    79,74,43,
    43,79,47,
    47,43,75,
    75,47,78,
    78,75,44,
    44,78,46,
    46,44,76,
    76,46,77,
    77,76,45,
    
    
    
//    22,42,43,
//    22,43,44,
//    22,44,26,
//    26,44,45,
//    42,43,47,
//    43,47,44,
//    44,47,46,
//    44,46,45,
//    42,47,10,
//    47,46,10,
//    46,10,45,
    
    
    17,36,0,
    0,36,6,
    10,16,45,
    45,16,26,
    
    
    42,22,21,
    21,42,39,
    
    
    6,42,10,
    
    6,42,39,
    17,19,21,
    0,3,6,
    6,8,10,
    10,13,16,
    22,24,26,
    19,20,21,
    17,18,19,
    0,1,3,
    1,2,3,
    3,4,5,
    3,5,6,
    6,7,8,
    8,9,10,
    10,11,13,
    11,12,13,
    13,14,15,
    13,15,16,
    24,25,26,
    22,23,24
   };

@interface FaceImage(){
 
}
@end

@implementation FaceImage

@synthesize  facelandmark, src_image,scale,faceMeshIndices,meshCount,imageName;
-(id)init{
    scale=1.0;
    int indecisCount=sizeof(faceSyncSkine)/sizeof(faceSyncSkine[0]);
    faceMeshIndices=new short[indecisCount];
    meshCount=indecisCount/3;
   for (int index=0;index<indecisCount;index++){
       faceMeshIndices[index]=faceSyncSkine[index];
   }
    return [super init];
}
-(void)destroy{
    src_image.release();
    facelandmark.clear();
    delete []faceMeshIndices;


}
-(FaceImage*)clone{
    
    FaceImage *res=[FaceImage new];
    res.src_image=src_image.clone();
    
    std::vector<cv::Point>temp;
    for (int i=0;i<facelandmark.size();i++)
        temp.push_back(facelandmark[i]);
    res.facelandmark=temp;
    res.scale=scale;
    res.imageName=[NSString stringWithFormat:@"%@",imageName];
  //  res.overlayUIImage=[UIImage imageWithCGImage:overlayUIImage.CGImage];
    return res;
}

-(void)setImagesWithName:(NSString*)imagename{
    imageName=imagename;
    
    UIImage *image=[UIImage imageNamed:imagename];
    cv::Mat mat=[Utils cvMatFromUIImage:image];
    src_image=mat;
 }

-(UIImage *)getUIImage{
  return   [Utils UIImageFromCVMat:src_image];
}
-(void)changeForehead:(float)fact{
    /*
     extending 17~27 points on forehead in facelandmark
     */
    
   // cv::Point center=(facelandmark[0]+ facelandmark[16])/2;

    //virtual face height
   // cv::Point dP=facelandmark[0]- center;
//    float f=0.6;
//    facelandmark.push_back(facelandmark[17]+(facelandmark[17]-facelandmark[36])*f*0.3);
//    facelandmark.push_back(facelandmark[18]+(facelandmark[18]-facelandmark[37])*f*0.5);
//    facelandmark.push_back(facelandmark[19]+(facelandmark[19]-facelandmark[37])*f*0.7);
//    facelandmark.push_back(facelandmark[20]+(facelandmark[20]-facelandmark[38])*f);
//    facelandmark.push_back(facelandmark[21]+(facelandmark[21]-facelandmark[39])*f);
//    
//    facelandmark.push_back(facelandmark[22]+(facelandmark[22]-facelandmark[42])*f);
//    facelandmark.push_back(facelandmark[23]+(facelandmark[23]-facelandmark[43])*f);
//    facelandmark.push_back(facelandmark[24]+(facelandmark[24]-facelandmark[44])*f*0.7);
//    facelandmark.push_back(facelandmark[25]+(facelandmark[25]-facelandmark[44])*f*0.5);
//    facelandmark.push_back(facelandmark[26]+(facelandmark[26]-facelandmark[45])*f*0.3);
//    
//    f=0.2;
//    
//    facelandmark.push_back(facelandmark[17]-(facelandmark[17]-facelandmark[36])*f);
//    facelandmark.push_back(facelandmark[18]-(facelandmark[18]-facelandmark[37])*f);
//    facelandmark.push_back(facelandmark[19]-(facelandmark[19]-facelandmark[37])*f);
//    facelandmark.push_back(facelandmark[20]-(facelandmark[20]-facelandmark[38])*f);
//    facelandmark.push_back(facelandmark[21]-(facelandmark[21]-facelandmark[39])*f);
//    
//    facelandmark.push_back(facelandmark[22]-(facelandmark[22]-facelandmark[42])*f);
//    facelandmark.push_back(facelandmark[23]-(facelandmark[23]-facelandmark[43])*f);
//    facelandmark.push_back(facelandmark[24]-(facelandmark[24]-facelandmark[44])*f);
//    facelandmark.push_back(facelandmark[25]-(facelandmark[25]-facelandmark[44])*f);
//    facelandmark.push_back(facelandmark[26]-(facelandmark[26]-facelandmark[45])*f);
//
//    for (int i=17;i<27;i++){
//        cv::Point pt=facelandmark[i]+(facelandmark[i+51]-facelandmark[i])*0.3;
//        facelandmark.push_back(pt);
//    }
//
//    resizeRangeVector(facelandmark,36,41,1.5);
//    
//    resizeRangeVector(facelandmark,42,47,1.5);
    
//     for (int i=17;i<27;i++){
//         
//         float aa=-M_PI*(i-16)/11;
//         int dx=dP.x*cos(aa)+dP.y*sin(aa);
//         int dy=-dP.x*sin(aa)+dP.y*cos(aa);
//         int x=center.x+dx;
//         int y=center.y+dy;
//         
//         facelandmark[i]=cv::Point(x,y);
//     }
//    facelandmark[45]=facelandmark[45]+(facelandmark[45]-facelandmark[42])*0.5;
//    facelandmark[36]=facelandmark[36]+(facelandmark[36]-facelandmark[39])*0.5;
//    facelandmark[21]=(facelandmark[21]+facelandmark[22])/2;
//    facelandmark[4]=(facelandmark[4]+facelandmark[36])/2;
//    facelandmark[12]=(facelandmark[12]+facelandmark[45])/2;
//    facelandmark[19]=facelandmark[36]+(facelandmark[36]-facelandmark[5])*0.2;
//    facelandmark[24]=facelandmark[45]+(facelandmark[45]-facelandmark[11])*0.2;
//    
//   facelandmark[31]=facelandmark[31]+(facelandmark[31]-facelandmark[33])*0.8;
//   facelandmark[35]=facelandmark[35]+(facelandmark[35]-facelandmark[33])*0.8;
  std::vector<cv::Point> eyes_l=[self getFeaturePointsWithStartIndex:36 endPoint:41];
    [self addSplEyes:eyes_l];
  std::vector<cv::Point> eyes_r=[self getFeaturePointsWithStartIndex:42 endPoint:47];
    [self addSplEyes:eyes_r];
}
-(void) addSplEyes:(std::vector<cv::Point> )eyes_l
{
    
    MySpline *spline_l=[[MySpline alloc] init:3];
   for (int i=0;i<eyes_l.size();i++){
        [spline_l addPoint:eyes_l[i]];
        
    }
    [spline_l addPoint:eyes_l[0]];
    std::vector<cv::Point> sp_pts=[spline_l getSplinePoints];
  //  facelandmark.push_back(sp_pts[0]);
    for (int i=0;i<sp_pts.size()-1;i++){
//        if(sp_pts[i].x==sp_pts[i-1].x && sp_pts[i].y==sp_pts[i].y){
//            continue;
//        }
        if(i%3==1)
        facelandmark.push_back(sp_pts[i]);
    }

   
}
void resizeRangeVector(std::vector<cv::Point>& v, int ii,int jj, float rate){
    cv::Point cen;
    std::vector<cv::Point> vv;
    for (int i=ii;i<=jj;i++){
        cen+=v[i];
        vv.push_back(v[i]);
    }
    cen.x=cen.x*1.0/vv.size();
    cen.y=cen.y*1.0/vv.size();
    for (int i=ii;i<=jj;i++){
        v[i]=cen+rate*(v[i]-cen);
    }
    
}
-(void)keepFromFaceFeatures:(FaceImage*)face Start:(int)ii End:(int)jj{
    std::vector<cv::Point> temp;
    for (int i=0;i<facelandmark.size();i++){
        if(i>=ii && i<=jj){
           temp.push_back(face.facelandmark[i]);
        }else
        temp.push_back(facelandmark[i]);
        
    }
    facelandmark=temp;
}
-(cv::Rect)resizeByFaceBound:(float)rate{

    cv::Rect rect = boundingRect( facelandmark );

    float scaleX = rate; // 10%
    float scaleY = rate*1.2; // 10%
    cv::Rect new_size(
                      rect.x-scaleX*rect.width/2,
                      rect.y-scaleY*rect.height/2,
                      rect.width*(1+scaleX),
                      rect.height*(1+scaleY));
   
    for (int i=0;i<facelandmark.size();i++){
            facelandmark[i].y=facelandmark[i].y-new_size.y;
            facelandmark[i].x=facelandmark[i].x-new_size.x;
    }
    if(new_size.x<0)new_size.x=0;
    if(new_size.y<0)new_size.y=0;
    if(new_size.x+new_size.width>src_image.cols-1)new_size.width=src_image.cols-new_size.x;
    if(new_size.y+new_size.height>src_image.rows-1)new_size.height=src_image.cols-new_size.y;
     src_image= src_image( new_size ).clone();    
  ;
    return new_size;
}
#pragma mark - check Draw element

-(cv::Mat)checkFacialFeaturePoint{
    cv::Mat drw_image=src_image.clone();
    for (unsigned long i=0;i<facelandmark.size();i++){
    cv::circle(drw_image, facelandmark[i], drw_image.cols/200, cv::Scalar(0,255,0),-1);
        
    }

    return drw_image;
}
-(cv::Mat)checkTriangleSigleMesh{
    
    cv::Mat drw_image=src_image.clone();
    
    if(facelandmark.empty())return drw_image;

    for (int index=0;index<meshCount;index++){
        
 
        int ii =faceMeshIndices[3*index];
        int jj =faceMeshIndices[3*index+1];
        int kk =faceMeshIndices[3*index+2];

        cv::Point pt1=SAFEDRWPOINT(drw_image,facelandmark[ii]);
        cv::Point pt2=SAFEDRWPOINT(drw_image,facelandmark[jj]);
        cv::Point pt3=SAFEDRWPOINT(drw_image,facelandmark[kk]);
        cv::line(drw_image,pt1,pt2,cv::Scalar(255,0,0));
        cv::line(drw_image,pt2,pt3,cv::Scalar(255,0,0));
        cv::line(drw_image,pt3,pt1,cv::Scalar(255,0,0));
        
        
    }

    return drw_image;

}
-(cv::Mat)checkTriangleMesh:(int)type{
    
    cv::Mat drw_image=src_image.clone();
    
    switch (type) {
        case 0:
            drw_image=[self checkTriangleSigleMesh];
            break;
        case 1:
            drw_image=[self checkTriangleFullMesh];
            break;
     
    }
    return drw_image;
    
}
-(cv::Mat)checkTriangleFullMesh{
    
    cv::Mat drw_image=src_image.clone();
    
//    if(facelandmark.empty())return drw_image;
//    
//    for (int index=0;index<triangles.rows;index++){
//        
//        
//        int ii =triangles.at<int>(3*index);// faceMeshIndices[3*index];
//        int jj =triangles.at<int>(3*index+1);
//        int kk =triangles.at<int>(3*index+2);
//        
//        cv::Point pt1=SAFEDRWPOINT(drw_image,facelandmark[ii]);
//        cv::Point pt2=SAFEDRWPOINT(drw_image,facelandmark[jj]);
//        cv::Point pt3=SAFEDRWPOINT(drw_image,facelandmark[kk]);
//        cv::line(drw_image,pt1,pt2,cv::Scalar(255,0,0));
//        cv::line(drw_image,pt2,pt3,cv::Scalar(255,0,0));
//        cv::line(drw_image,pt3,pt1,cv::Scalar(255,0,0));
//        
//        
//    }
//    
    return drw_image;
    
}
-(std::vector<cv::Point>)getFeaturePointsWithStartIndex:(int)i endPoint:(int)j{
    std::vector<cv::Point> pts;
    for (int index=i;index<=j;index++){
        pts.push_back(facelandmark[index]);
    }
    return pts;
}
cv::Point SAFEDRWPOINT(cv::Mat back, cv::Point pt){
    if(pt.x>back.cols-1)pt.x=back.cols-1;
    if(pt.y>back.rows-1)pt.y=back.rows-1;
    if(pt.x<0)pt.x=0;
    if(pt.y<0)pt.y=0;
    return cv::Point(pt.x,pt.y);
}
float anglefromPts(cv::Point p2,cv::Point p1,cv::Point p3){
    float p12=    distance(p1,p2);
    float p23=    distance(p3,p2);
    float p31=    distance(p3,p1);
    if(abs(p12)<1 || (p31<1))return 0;
    float res=acos((p12*p12+p31*p31-p23*p23)/(2*p12*p31));
    return res;
}
float distance(cv::Point p1,cv::Point p2){
    int dx=p1.x-p2.x;
    int dy=p1.y-p2.y;
    
    float res=sqrt(dx*dx+dy*dy);
    if(res<1)res=1;
    return  res;
}


#pragma  mark illustrate 
-(cv::Mat)getBlurBackGroundImage{
  
    NSString *sample= [imageName stringByReplacingOccurrencesOfString:@"sample"
                                                           withString:@"blur"];
    

  
   return  [Utils cvMatFromUIImage:[UIImage imageNamed:sample]];
}
-(UIImage*)getOverlayImage{
    
     NSString *sample = [imageName stringByReplacingOccurrencesOfString:@"sample"
                                                 withString:@"ovrelay"];


    return  [UIImage imageNamed:sample];
}

@end
