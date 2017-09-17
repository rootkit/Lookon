//
//  MakeupProcess.m
//  Lookon
//
//  Created by My Star on 8/23/17.
//  Copyright © 2017 My Star. All rights reserved.
//

#import "MakeupProcess.h"
#import "MySpline.h"
#import "AffineTransform.h"
static MakeupProcess *_sharedInstance;
enum{
    MIXEDCOLOR_ADDCOLOR=1,
    MIXEDCOLOR_SELF=2
    
};
unsigned short EyeIndices[]{
    0,1,5,
    1,5,2,
    2,5,4,
    2,4,3
};
unsigned short EyeMakeIndices[]={
    0,36,1,
    1,36,2,
    2,36,3,
    3,36,4,
    4,36,5,
    36,41,5,
    5,41,6,
    41,40,6,
    6,40,7,
    40,39,7,
    7,39,8,
    8,39,42,
    8,42,9,
    9,42,10,
    42,10,47,
    47,10,11,
    11,47,46,
    46,11,12,
    46,12,45,
    12,45,13,
    13,45,14,
    14,45,15,
    15,45,16,
    16,45,26,
    26,25,45,
    25,44,45,
    25,44,24,
    24,43,44,
    24,43,23,
    23,42,43,
    23,42,22,
    42,39,21,
    22,42,21,
    38,39,21,
    20,38,21,
    37,38,20,
    19,37,20,
    36,37,19,
    18,36,19,
    17,18,36,
    17,36,0,
    42,43,47,
    47,43,44,
    47,44,46,
    44,46,45,
    39,38,40,
    38,40,37,
    40,37,41,
    37,41,36
};

@implementation MakeupProcess
+ (MakeupProcess *)sharedInstance
{
    
    if ( !_sharedInstance )
    {
        _sharedInstance = [MakeupProcess new];
    }
    return _sharedInstance;
}

//-(void)overdrawEyes:(FaceImage**)face  src:(FaceImage*)initface opacity:(float)opacity{
//    FaceImage *overlay=(*face).clone;
//    cv::Mat imageMat=overlay.src_image;
//    cv::Mat originFace=initface.src_image;
//    std::vector<cv::Point> pts_left;
//    std::vector<cv::Point> pts_right;
//    for (int i=36;i<42;i++){
//       pts_left.push_back(overlay.facelandmark[i]);
//       pts_right.push_back(overlay.facelandmark[i+6]);
//    }
//    std::vector<std::vector<cv::Point> > fillContAll;
//    fillContAll.push_back(pts_left);    
//    cv::Mat src_mask(imageMat.rows,imageMat.cols, CV_8UC4, cv::Scalar(0,0,0,0));
//    float opacity_alpa=255*opacity;
//    cv::fillPoly( src_mask, fillContAll,  cv::Scalar( opacity_alpa, opacity_alpa, opacity_alpa,opacity_alpa));
//    
//  
//    (*face).src_image=mixSrcBackMask(imageMat,originFace,imageMat.clone());
//}
-(void)overdrawEyes:(FaceImage**)dstface  src:(FaceImage*)src opacity:(float)opacity{
    
    FaceImage *dst=(*dstface);
  
    
    std::vector<cv::Point> pts_src;
    std::vector<cv::Point> pts_dst;
    std::vector<cv::Point> pts_src_1;
    std::vector<cv::Point> pts_dst_1;
    
  //  cv::Point src_center_left=(src.facelandmark[37]+src.facelandmark[40])/2;
  //  cv::Point src_center_right=(src.facelandmark[44]+src.facelandmark[47])/2;

  //  cv::Point dst_center_left=(dst.facelandmark[37]+dst.facelandmark[40])/2;
  //  cv::Point dst_center_right=(dst.facelandmark[44]+dst.facelandmark[47])/2;
    
   // float rate1=cv::norm(dst.facelandmark[36]-dst.facelandmark[39])/cv::norm(src.facelandmark[36]-src.facelandmark[39]);
   // float rate2=cv::norm(dst.facelandmark[42]-dst.facelandmark[45])/cv::norm(src.facelandmark[42]-src.facelandmark[45]);
  //  float rtAlpa=-angleBetween2Lines( src_center_left-src_center_right, dst_center_left-dst_center_right);
   // int thick=cv::norm(dst.facelandmark[36]-dst.facelandmark[39]);
    
   // float rate=1.2*(rate1+rate2)/2;
    pts_src=[src getFeaturePointsWithStartIndex:36 endPoint:41];
    pts_dst=[dst getFeaturePointsWithStartIndex:36 endPoint:41];
    pts_src_1=[src getFeaturePointsWithStartIndex:42 endPoint:47];
    pts_src_1=[dst getFeaturePointsWithStartIndex:42 endPoint:47];
    
   float rt=1.0;
   resizeMVector(pts_src,rt);
   resizeMVector(pts_src_1,rt);
   resizeMVector(pts_dst,rt);
   resizeMVector(pts_dst_1,rt);
   affineArray(&dst, src, pts_src, pts_dst);
   affineArray(&dst, src, pts_src_1, pts_dst_1);
    
//    std::vector<cv::Point> temp;
//    for (int i=0;i<dst.facelandmark.size();i++)
//    {
//        
//        if(i>=36 && i<=41){
//            temp.push_back(pts_dst[i-36]);
//         //   cv::circle(dst.src_image, pts_dst[i-36], 2, cv::Scalar(255,255,0));
//        }else if(i>=42 && i<=47){
//            temp.push_back(pts_dst_1[i-42]);
//        }else{
//            temp.push_back(dst.facelandmark[i]);
//        }
//        
//    }
//    dst.facelandmark=temp;
    
  


}
void resizeEyes(std::vector<cv::Point> &eyes ,float thick,BOOL left){
    std::vector<cv::Point> pts;
    for (int i=0;i<6;i++){
        cv::Point lp = getOffsetPoint(eyes[i],eyes[i+1],eyes[i],thick*0.15,left);
        if(i==5)lp = getOffsetPoint(eyes[i-1],eyes[i],eyes[i],thick*0.15,left);
        pts.push_back(lp);
        
    }
    eyes=pts;
}
void affineArray(FaceImage**face ,FaceImage*initface,std::vector<cv::Point> pts_src,std::vector<cv::Point> pts_dst){
    
//
//    resizeMVector(pts_src,1.6);
    
    
    MySpline *spline_src=[[MySpline alloc] init:3];
    MySpline *spline_dst=[[MySpline alloc] init:3];
    for (int i=0;i<pts_src.size();i++){
        [spline_src addPoint:pts_src[i]];
        [spline_dst addPoint:pts_dst[i]];
        
    }
    [spline_src addPoint:pts_src[0]];
    [spline_dst addPoint:pts_dst[0]];
    
    cv::Point src_c= getCenterPosition(pts_src);
    cv::Point dst_c= getCenterPosition(pts_dst);
    
    
    std::vector<cv::Point> pts_1=[spline_dst getSplinePoints];//pts_1.push_back(pts_dst[0]);
    
    std::vector<cv::Point> pts_2=[spline_src getSplinePoints];//pts_2.push_back(pts_src[0]);
    
    cv::Mat src_dst=((*face).src_image).clone();
    cv::Mat dst=src_dst.clone();
    
    cv::Mat src=initface.src_image;
    for (int index=0;index<pts_1.size()-1;index++){
        
     
        
                cv::Point2f srcTri[3];
                cv::Point2f dstTri[3];
    
        
                dstTri[0]=dst_c;
                dstTri[1]=pts_1[index];
                dstTri[2]=pts_1[index+1];
        
                srcTri[0]=src_c;
                srcTri[1]=pts_2[index];
                srcTri[2]=pts_2[index+1];
               affineTriangle(srcTri,dstTri,dst,src);
        //   cv::circle(dst, pts_1[index], 2, cv::Scalar(0,0,255),-1);
    }
    int depth =cv::norm(pts_src[0]-pts_src[3])*0.01;
    if(depth%2==0)depth++;
    if(depth<3)depth=3;
    cv::Mat src_mask(dst.rows,dst.cols, CV_8UC4, cv::Scalar(0,0,0,0));
    
    std::vector<std::vector<cv::Point> > fillContAll;
    float alpa=0.5;
    fillContAll.push_back(pts_1);
    
    cv::fillPoly( src_mask, fillContAll,  cv::Scalar( 255*alpa, 255*alpa, 255*alpa, 255*alpa));
    
    cv::GaussianBlur(src_mask,src_mask,cv::Size(depth,depth),depth);
    
 
    (*face).src_image=mixSrcBackMask(dst,src_mask,src_dst);
   // resizeMVector(pts_1,1.5);
  //  (*face).src_image= seamlessPts(dst,src_dst,pts_1);
    
}
-(void)changeEyeSize:(FaceImage**)face  Scale:(float)scale{
   FaceImage *affine=(*face).clone;
   
    std::vector<cv::Point> pts;

    for (int i=0;i<(*face).facelandmark.size();i++)
        pts.push_back((*face).facelandmark[i]);

    std::vector<cv::Point> ptd;
    for (int i=0;i<affine.facelandmark.size();i++)
        ptd.push_back(affine.facelandmark[i]);
    int thick=cv::norm(pts[36]-pts[39]);
    ptd[37]= getOffsetPoint(pts[37],pts[38],pts[37],thick*scale,YES);   // [[AffineTransform init]  alloc]
    ptd[38]= getOffsetPoint(pts[37],pts[38],pts[38],thick*scale,YES);
    
    ptd[40]= getOffsetPoint(pts[40],pts[41],pts[40],thick*scale*0.8,YES);   // [[AffineTransform init]  alloc]
    ptd[41]= getOffsetPoint(pts[40],pts[41],pts[41],thick*scale*0.8,YES);
    
    thick=cv::norm(pts[42]-pts[45]);
    ptd[44]= getOffsetPoint(pts[44],pts[43],pts[44],thick*scale,NO);   // [[AffineTransform init]  alloc]
    ptd[43]= getOffsetPoint(pts[44],pts[43],pts[43],thick*scale,NO);
    
    ptd[47]= getOffsetPoint(pts[47],pts[46],pts[47],thick*scale*0.8,NO);   // [[AffineTransform init]  alloc]
    ptd[46]= getOffsetPoint(pts[47],pts[46],pts[46],thick*scale*0.8,NO);
    
    cv::Mat _srcImage=(*face).src_image.clone();
    cv::Mat _dstImage=affine.src_image.clone();
    (*face).facelandmark=ptd;
    int indecisCount=sizeof(EyeMakeIndices)/sizeof(EyeMakeIndices[0]);

    int meshCount=indecisCount/3;
    for (int index=0;index<meshCount;index++){
        
        cv::Point2f srcTri[3];
        cv::Point2f dstTri[3];
        int i =EyeMakeIndices[3*index];
        int j =EyeMakeIndices[3*index+1];
        int k =EyeMakeIndices[3*index+2];
        
        dstTri[0]=ptd[i];
        dstTri[1]=ptd[j];
        dstTri[2]=ptd[k];
        
        srcTri[0]=pts[i];
        srcTri[1]=pts[j];
        srcTri[2]=pts[k];
        
        affineTriangle(srcTri,dstTri,_dstImage,_srcImage);
        
    }
    (*face).src_image=_dstImage.clone();
    
}
-(void) eyeLine:(FaceImage**)face addColor:(cv::Scalar)color{
    
    cv::Mat src_image=(*face).src_image;
    std::vector<cv::Point> left_pts;
     left_pts.push_back((*face).facelandmark[36]);
     left_pts.push_back((*face).facelandmark[37]);
     left_pts.push_back((*face).facelandmark[38]);
     left_pts.push_back((*face).facelandmark[39]);
     left_pts.push_back((*face).facelandmark[40]);
     left_pts.push_back((*face).facelandmark[41]);
    [self eyelineDraw:src_image addPoints:left_pts addColor:color addSide:YES];
    std::vector<cv::Point> right_pts;
    right_pts.push_back((*face).facelandmark[45]);
    right_pts.push_back((*face).facelandmark[44]);
    right_pts.push_back((*face).facelandmark[43]);
    right_pts.push_back((*face).facelandmark[42]);
    right_pts.push_back((*face).facelandmark[47]);
    right_pts.push_back((*face).facelandmark[46]);
    [self eyelineDraw:src_image addPoints:right_pts addColor:color addSide:NO];
    (*face).src_image=src_image;
}
-(void) eyeShadow:(FaceImage**)face addColor:(cv::Scalar)color{


    //*******************EyeShadow*******************
    float s=0.1+(1-0.5)*0.9;
     cv::Mat src_image=(*face).src_image;

    std::vector<cv::Point> left_pts;
    left_pts.push_back((*face).facelandmark[36]);
    left_pts.push_back((*face).facelandmark[37]);
    left_pts.push_back((*face).facelandmark[38]);
    left_pts.push_back((*face).facelandmark[39]);
    left_pts.push_back((*face).facelandmark[40]);
    left_pts.push_back((*face).facelandmark[41]);
    MakeEyeshadow(src_image , left_pts , color,YES,s);
    std::vector<cv::Point> right_pts;
    right_pts.push_back((*face).facelandmark[45]);
    right_pts.push_back((*face).facelandmark[44]);
    right_pts.push_back((*face).facelandmark[43]);
    right_pts.push_back((*face).facelandmark[42]);
    right_pts.push_back((*face).facelandmark[47]);
    right_pts.push_back((*face).facelandmark[46]);
    MakeEyeshadow(src_image , right_pts , color,NO,s);
    (*face).src_image=src_image;

}
- (void)lipSticker:(FaceImage**)face addColor:(cv::Scalar)color{

    MySpline *spline_lip1=[[MySpline alloc] init:21];
    MySpline *spline_lip2=[[MySpline alloc] init:21];
    [spline_lip1 addPoint:(*face).facelandmark[48]];
    [spline_lip1 addPoint:(*face).facelandmark[49]];
    [spline_lip1 addPoint:(*face).facelandmark[50]];
    [spline_lip1 addPoint:(*face).facelandmark[51]];
    [spline_lip1 addPoint:(*face).facelandmark[52]];
    [spline_lip1 addPoint:(*face).facelandmark[53]];
    [spline_lip1 addPoint:(*face).facelandmark[54]];
    [spline_lip1 addPoint:(*face).facelandmark[64]];
    [spline_lip1 addPoint:(*face).facelandmark[63]];
    [spline_lip1 addPoint:(*face).facelandmark[62]];
    [spline_lip1 addPoint:(*face).facelandmark[61]];
    [spline_lip1 addPoint:(*face).facelandmark[60]];
    
    [spline_lip2 addPoint:(*face).facelandmark[48]];
    [spline_lip2 addPoint:(*face).facelandmark[60]];
    [spline_lip2 addPoint:(*face).facelandmark[67]];
    [spline_lip2 addPoint:(*face).facelandmark[66]];
    [spline_lip2 addPoint:(*face).facelandmark[65]];
    [spline_lip2 addPoint:(*face).facelandmark[64]];
    [spline_lip2 addPoint:(*face).facelandmark[54]];
    [spline_lip2 addPoint:(*face).facelandmark[55]];
    [spline_lip2 addPoint:(*face).facelandmark[56]];
    [spline_lip2 addPoint:(*face).facelandmark[57]];
    [spline_lip2 addPoint:(*face).facelandmark[58]];
    [spline_lip2 addPoint:(*face).facelandmark[59]];
    
    //*******Lip enhancemend
    float f=0.6+(1-0.7)*0.4;
    
    cv::Point f51=(*face).facelandmark[51];
    cv::Point f57=(*face).facelandmark[57];
    
    //***********************
    float dist=cv::norm(f51-f57);
    std::vector<cv::Point>lip1= [spline_lip1 getSplinePoints];
    cv::Mat srcImage=(*face).src_image;
    LipEnhancement(srcImage,lip1,color,dist,f);
    
    std::vector<cv::Point>lip2= [spline_lip2 getSplinePoints];
    LipEnhancement(srcImage,lip2,color,dist,f);
    (*face).src_image=srcImage;
  
}
- (FaceImage*)drawEyeBrows:(FaceImage*)face{
    FaceImage*res=[FaceImage new];
    res=face.clone;
    
   // res.facelandmark[17]
    return res;
}

-(void)eyelineDraw:(cv::Mat&) src_image addPoints:(std::vector<cv::Point>) ptx addColor:(cv::Scalar)color addSide:(BOOL) flg{
    
    MySpline *spline_eyeline_left=[[MySpline alloc] init:10];
    int thick=cv::norm(ptx[0]-ptx[3]);
    [spline_eyeline_left addPoint:getOffsetPoint(ptx[2],ptx[3],ptx[3],thick*0.06,flg)];
    [spline_eyeline_left addPoint:getOffsetPoint(ptx[2],ptx[3],ptx[2],thick*0.09,flg)];
    [spline_eyeline_left addPoint:getOffsetPoint(ptx[1],ptx[2],ptx[1],thick*0.12,flg)];
    
    [spline_eyeline_left addPoint:getOffsetPoint(ptx[0],ptx[1],ptx[0],thick*0.15,flg)];
    [spline_eyeline_left addPoint:ptx[0]+(ptx[0]-ptx[5])*1.0];
    
    [spline_eyeline_left addPoint:ptx[0]];
    [spline_eyeline_left addPoint:ptx[1]];
    [spline_eyeline_left addPoint:ptx[2]];
    [spline_eyeline_left addPoint:ptx[3]];
    
    
    std::vector<cv::Point>eyeline_left= [spline_eyeline_left getSplinePoints];
    
    
    
    int kk=int(thick*0.15);
    if(kk%2==0)kk+=1;
    if(kk<4)kk=3;
    polygonAddSmoothImage(src_image, eyeline_left, color,kk,kk/2,0.3,MIXEDCOLOR_ADDCOLOR,0.1,0.1);
      //draw eyeline
    
//    MySpline *spline_eyeline_bottom=[[MySpline alloc] init:10];
//    
//    [spline_eyeline_bottom addPoint:getOffsetPoint(ptx[3],ptx[4],ptx[3],thick*0.1,flg)];
//    [spline_eyeline_bottom addPoint:getOffsetPoint(ptx[4],ptx[5],ptx[4],thick*0.11,flg)];
//    [spline_eyeline_bottom addPoint:getOffsetPoint(ptx[4],ptx[0],ptx[4],thick*0.11,flg)];
//    [spline_eyeline_bottom addPoint:getOffsetPoint(ptx[4],ptx[0],ptx[0],thick*0.1,flg)];
//    [spline_eyeline_bottom addPoint:ptx[0]+(ptx[0]-ptx[5])*1.2];
//   
//    [spline_eyeline_bottom addPoint:ptx[5]];
//    [spline_eyeline_bottom addPoint:ptx[4]];
//    [spline_eyeline_bottom addPoint:ptx[3]];
//    
//    kk=int(thick*0.2);
//    if(kk%2==0)kk+=1;
//    if(kk<4)kk=3;
//
//    std::vector<cv::Point>eyeline_left_btm= [spline_eyeline_bottom getSplinePoints];
//    polygonAddSmoothImage(src_image, eyeline_left_btm, color,kk,kk/2,0.6,MIXEDCOLOR_ADDCOLOR,0.1,0.1);
    
    
//    float draw_eye_bt_thick=thick*0.05;
//    if (draw_eye_bt_thick<1)draw_eye_bt_thick=1;
//    std::vector<cv::Point>eyeline_left_bottom= [spline_eyeline_bottom getSplinePoints];
//    cv::Mat  overlay =src_image.clone();
//    for (int i=1;i<eyeline_left_bottom.size();i++){
//        
//        cv::line(overlay,eyeline_left_bottom[i],eyeline_left_bottom[i-1],color,draw_eye_bt_thick,cv::LINE_AA);
//    }
//    
//    float  opacity = 0.4;
//    cv::addWeighted(overlay, opacity, src_image, 1 - opacity, 0, src_image);
    
    

}

#pragma mark makeover function

void LipEnhancement(cv::Mat &backGround, std::vector<cv::Point> lipVertex, cv::Scalar lipOverlayColor,float dist,float alpa){
    
    int kk=int(dist*0.2);
    if(kk%2==0)kk+=1;
    if(kk<4)kk=3;
    
    polygonAddSmoothImage(backGround, lipVertex, lipOverlayColor,kk,kk/2,alpa,MIXEDCOLOR_ADDCOLOR,0.1,0.1);
    
    
}
void MakeEyeshadow(cv::Mat& src_image , std::vector<cv::Point> ptx , cv::Scalar color,bool left_right,float alpa){
    
    MySpline *spline_eyeline_left=[[MySpline alloc] init:10];
    int thick=cv::norm(ptx[0]-ptx[3])*2;
    [spline_eyeline_left addPoint:getOffsetPoint(ptx[2],ptx[3],ptx[3],thick*0.06,left_right)];
    [spline_eyeline_left addPoint:getOffsetPoint(ptx[2],ptx[3],ptx[2],thick*0.09,left_right)];
    [spline_eyeline_left addPoint:getOffsetPoint(ptx[1],ptx[2],ptx[1],thick*0.15,left_right)];
    [spline_eyeline_left addPoint:getOffsetPoint(ptx[0],ptx[1],ptx[0],thick*0.2,left_right)];
    [spline_eyeline_left addPoint:ptx[0]+(ptx[0]-ptx[5])*1.0];
    
    [spline_eyeline_left addPoint:ptx[0]];
    [spline_eyeline_left addPoint:ptx[1]];
    [spline_eyeline_left addPoint:ptx[2]];
    [spline_eyeline_left addPoint:ptx[3]];
    
    
    std::vector<cv::Point>eyeline_left= [spline_eyeline_left getSplinePoints];
    
    
    
    int kk=int(thick*0.15);
    if(kk%2==0)kk+=1;
    if(kk<4)kk=3;
    polygonAddSmoothImage(src_image, eyeline_left, color,kk,kk/2,0.3,MIXEDCOLOR_ADDCOLOR,0.1,0.4);
    
    
}

void polygonAddSmoothImage(cv::Mat &backGround, std::vector<cv::Point> vertexs, cv::Scalar overlayColor,int blur_fact,int blur_f1,float alpha,int paint_type,float Rx,float Ry){
    
    cv::Rect lip_rect=  boundingRect(vertexs);
    
    float dy=lip_rect.height*Ry;
    
    float dx=lip_rect.width*Rx;
    
    float bx=dx;
    
    float by=dy;
    
    
    lip_rect=cv::Rect(lip_rect.x-dx,lip_rect.y-dy,lip_rect.width+dx+bx,lip_rect.height+dy+by);
    //cv::rectangle(backGround,lip_rect, cv::Scalar(0,0,255));
    
    if (lip_rect.x-dx<0)
        lip_rect.x=0;
    if (lip_rect.y-dy<0)
        lip_rect.y=0;
    if(lip_rect.width+dx+bx>backGround.cols)
        lip_rect.width=backGround.cols-dx;
    if(lip_rect.height+dy+by>backGround.rows)
        lip_rect.height=backGround.rows-dy;
    cv::Mat src_Mask(backGround.rows,backGround.cols, CV_8UC4, cv::Scalar(0,0,0,0));
    
    std::vector<std::vector<cv::Point> > fillContAll;
    
    fillContAll.push_back(vertexs);
    
    cv::fillPoly( src_Mask, fillContAll,  cv::Scalar( 255, 255, 255,255));
    
    
    cv::Mat small_lip;
    cv::Mat small_mask= src_Mask(lip_rect);
    cv::Mat src=backGround(lip_rect);
    
    if(blur_fact>3){
    cv::GaussianBlur(small_mask,small_mask,cv::Size(blur_fact,blur_fact),blur_f1);
    }
    small_lip=mixImages(src,small_mask,overlayColor,alpha,paint_type);
    
    //
    cv::Mat dstROI=backGround(lip_rect);
    
    small_lip.copyTo(dstROI);
}
cv::Mat mixImages(cv::Mat src,cv::Mat mask, cv::Scalar color,float alpa,int paint_type)
{
    cv::Mat res;
    
    cv::Mat dg = src.clone();//background Image
    
    res= dg.clone();
  //  cv::Scalar aver_color=cv::mean(src);
    //cv::Scalar mem_color;
    
    for (int x = 0; x < dg.cols; x++)
    {
        for (int y = 0; y < dg.rows; y++)
        {
            
            int R = cv::saturate_cast<uchar>((dg.at<cv::Vec4b>(y, x)[0]));
            int G = cv::saturate_cast<uchar>((dg.at<cv::Vec4b>(y, x)[1]));
            int B = cv::saturate_cast<uchar>((dg.at<cv::Vec4b>(y, x)[2]));
            int mR = cv::saturate_cast<uchar>((mask.at<cv::Vec4b>(y, x)[0]));
            int RR=0;
            int GG=0;
            int BB=0;
            float rf= mR/255.0;
            float rt=alpa;
            rt=(rt-1)*rf+1;
            if(paint_type==MIXEDCOLOR_ADDCOLOR)
            {
                if(R>=0)RR = (R*rt + color.val[0]*(1-rt));
                if(G>=0)GG = (G*rt + color.val[1]*(1-rt));
                if(B>=0)BB = (B*rt + color.val[2]*(1-rt));
                
            }
            else{
                
                float a=(R+G+B)/3.0;
                float k=a*(1.0+rt*0.8*exp(-a/25.5));
                rt=0.6*rt;
                
                RR=k*rt+R*(1.0-rt);
                GG=k*rt+G*(1.0-rt);
                BB=k*rt+B*(1.0-rt);
                
                
            }
            if (RR<0)RR=0;if(RR>255)RR=255;
            if (GG<0)GG=0;if(GG>255)GG=255;
            if (BB<0)BB=0;if(BB>255)BB=255;
            
            res.at<cv::Vec4b>(y, x)[0] = RR;
            res.at<cv::Vec4b>(y, x)[1] = GG;
            res.at<cv::Vec4b>(y, x)[2] = BB;
            res.at<cv::Vec4b>(y, x)[3] = 255;
            
        }
    }
    return res;
}
cv::Point divPoint(cv::Point p1,cv::Point p2,float div){
    cv::Point res;
    res.x=p1.x+(p2.x-p1.x)/div;
    res.y=p1.y+(p2.y-p1.y)/div;
    return res;
}
void resizeMVector(std::vector<cv::Point>& v, float rate){
    cv::Point cen;

    for (int i=0;i<v.size();i++){
        cen+=v[i];
    }
    cen.x=cen.x*1.0/v.size();
    cen.y=cen.y*1.0/v.size();
    for (int i=0;i<v.size();i++){
        v[i]=cen+rate*(v[i]-cen);
    }
    
}
cv::Point getCenterPosition(std::vector<cv::Point> v)
{
        cv::Point cen;
        std::vector<cv::Point> vv;
        for (int i=0;i<v.size();i++){
            cen+=v[i];
            vv.push_back(v[i]);
        }
        cen.x=cen.x*1.0/vv.size();
        cen.y=cen.y*1.0/vv.size();
    return cen;
}
//P1:start point
//p2:end point
//dis:offset distance

cv::Point getOffsetPoint(cv::Point p1,cv::Point p2,cv::Point pos, float dis,BOOL flg){
    float D=cv::norm(p1-p2);
    cv::Point pl=(p2-p1)*dis/D;
    cv::Point pk;
    if(flg==YES){
    pk.x=pl.y;
    pk.y=-pl.x;
    }
    else
    {
    pk.x=-pl.y;
    pk.y=pl.x;
    }
    return pk+pos;
}
float angleBetween2Lines(cv::Point line1, cv::Point line2)
{
    double angle1 = atan2(line1.y,
                               line1.x );
    double angle2 = atan2(line2.y,
                               line2.x);
    return angle1-angle2;
}
cv::Point rotatePoint(cv::Point pt, float alpa){
    int xx=pt.x*cos(alpa)-pt.y*sin(alpa);
    int yy=pt.x*sin(alpa)+pt.y*cos(alpa);
    return cv::Point(xx,yy);
}
@end
