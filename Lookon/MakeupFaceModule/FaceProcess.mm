//
//  FaceProcess.m
//  Lookon
//
//  Created by My Star on 8/17/17.
//  Copyright © 2017 My Star. All rights reserved.
//

#import "FaceProcess.h"
#import "MySpline.h"
static FaceProcess *_sharedInstance;
unsigned short _faceBound[]={
    0,1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,16,26,25,24,23,22,21,20,19,18,17
};
unsigned short remeshEyes[]={
    0,1,11,
    1,2,11,
    2,11,10,
    2,10,3,
    3,10,9,
    3,9,4,
    4,9,8,
    4,8,5,
    8,5,7,
    5,7,6,
    12,0,1,
    12,1,2,
    12,2,3,
    12,3,15,
    3,15,4,
    4,15,5,
    5,15,6,
    15,6,14,
    6,14,7,
    7,14,8,
    8,14,9,
    14,9,13,
    9,13,10,
    10,13,11,
    11,13,0,
    13,0,12
    
};
//unsigned short _faceBound[]={
//    21,19,36,4,5,8,11,12,45,24
//};
@interface FaceProcess(){
    
}
@end
@implementation FaceProcess
+ (FaceProcess *)sharedInstance
{
    
    if ( !_sharedInstance )
    {
        _sharedInstance = [FaceProcess new];
    }
    return _sharedInstance;
}
-(id)init{
    
    return [super init];
}
-(void)autoBirghtness:(FaceImage**)src{
    cv::Mat face=(*src).src_image;
    cv::Mat grey;
    cv::cvtColor( face,grey,CV_RGBA2GRAY);
    cv::Scalar color= cv::mean(grey);
    face=face*125/color.val[0];
    //face.convertTo(face, -1, 1.2, 0);
    (*src).src_image=face;
}

-(void)curvesColorChange:(FaceImage**)face StartCurvePoint:(cv::Point) px1 EndCurvePoint:(cv::Point) px2{
    MySpline *spline = [[MySpline alloc] init:65];
    [spline addPoint:cv::Point(0,0)];
    [spline addPoint:px1];
    [spline addPoint:px2];
    [spline addPoint:cv::Point(255,255)];
    std::vector<cv::Point> colorArray=[spline getSplinePoints];
    colorArray.push_back( cv::Point(255,255));
    
    cv::Mat src=(*face).src_image.clone();
    cv::Mat dst=(*face).src_image;
    
    

    
    for (int x = 0; x < src.cols; x++)
    {
        for (int y = 0; y < src.rows; y++)
        {
            
            int R = cv::saturate_cast<uchar>((src.at<cv::Vec4b>(y, x)[0]));
            int G = cv::saturate_cast<uchar>((src.at<cv::Vec4b>(y, x)[1]));
            int B = cv::saturate_cast<uchar>((src.at<cv::Vec4b>(y, x)[2]));
            int Rval=(R+G+B)/3;
            
            int Rcon=getCurveColor(colorArray, Rval);
            
            float Rcolor=1.0*Rcon/Rval;
            if(Rval==0)Rcolor=0.0;
            int  RR = R*Rcolor;
            int  GG = G*Rcolor;
            int  BB = B*Rcolor;
            RR=MAX(MIN(RR,255),0);
            GG=MAX(MIN(GG,255),0);
            BB=MAX(MIN(BB,255),0);
            dst.at<cv::Vec4b>(y, x)[0] = RR;
            dst.at<cv::Vec4b>(y, x)[1] = GG;
            dst.at<cv::Vec4b>(y, x)[2] = BB;

            
            
        }
    }
    

    
}
int getCurveColor(std::vector<cv::Point>  colors , int val){
    cv::Point res;
    for (int i=0;i<colors.size()-1;i++){
        if(colors[i+1].x==colors[i].x)continue;
        if(colors[i].x<=val && val<=colors[i+1].x){
            res=  colors[i]+1.0*(colors[i+1]-colors[i])*(colors[i+1].x-val)/(colors[i+1].x-colors[i].x);
            break;
        }
    }
    return res.y;
}

-(void)eyePupilReplace:(FaceImage**)face{

    
    
    std::vector<cv::Point> pts_src;
        pts_src=[(*face) getFeaturePointsWithStartIndex:36 endPoint:41];

    
    float rt=1.2;
    resizeVector(pts_src,rt);
    
    cv::Rect rect=boundingRect(pts_src);
    
    cv::Mat eyesImage=(*face).src_image(rect);
    
    cv::Mat gray;
    cv::cvtColor(eyesImage, gray, CV_BGR2GRAY);
    
    // Convert to binary image by thresholding it
    cv::threshold(gray, gray, 0, 120, cv::THRESH_BINARY);
    
    // Find all contours
    std::vector<std::vector<cv::Point> > contours;
    cv::findContours(gray.clone(), contours, CV_RETR_EXTERNAL, CV_CHAIN_APPROX_NONE);
    
    // Fill holes in each contour
    cv::drawContours(gray, contours, -1, CV_RGB(255,255,255), -1);
    for (int i = 0; i < contours.size(); i++)
    {
        double area = cv::contourArea(contours[i]);
        cv::Rect rect = cv::boundingRect(contours[i]);
        int radius = rect.width/2;
        
        // If contour is big enough and has round shape
        // Then it is the pupil
        if (area >= 30)  {
            
            const cv::Point *pts = (const cv::Point*) cv::Mat(contours[i]).data;
            int npts = cv::Mat(contours[i]).rows;
            
            std::cout << "Number of polygon vertices: " << npts << std::endl;
            
            // draw the polygon
            
            polylines(eyesImage, &pts,&npts, 1,
                      true, 			// draw closed contour (i.e. joint end to start)
                      cv::Scalar(0,255,0),// colour RGB ordering (here = green)
                      3, 		        // line thickness
                      CV_AA, 0);
            //   cv::circle(eyesImage, cv::Point(rect.x + radius, rect.y + radius), radius, CV_RGB(255,0,0), 2);
        }
    }
    
}
-(void)mixSeamlessCloneSrc:(FaceImage*)src addDestination:(FaceImage**)dst {

  //  res=dst.clone;

    
    cv::Mat srcImage=cv::Mat::zeros( src.src_image.size(), CV_8UC3 );
    cv::Mat dstImage=cv::Mat::zeros( (*dst).src_image.size(), CV_8UC3 );
    cv::Mat resImage=cv::Mat::zeros( (*dst).src_image.size(), CV_8UC3 );;
    cv::cvtColor(src.src_image, srcImage, CV_RGBA2RGB);
    cv::cvtColor((*dst).src_image, dstImage, CV_RGBA2RGB);
    
    cv::Mat mask = cv::Mat::zeros(dstImage.rows, dstImage.cols, dstImage.depth());

    
    std::vector<cv::Point> facecropPts;
    
    int indecisCount=sizeof(_faceBound)/sizeof(_faceBound[0]);
    
    for (int i=0;i<indecisCount;i++){
        int k=_faceBound[i];
        cv::Point pt=(*dst).facelandmark[k];
        facecropPts.push_back(pt);
        
    }
    
    std::vector<std::vector<cv::Point> > fillContAll;
    
    fillContAll.push_back(facecropPts);
    
    cv::fillPoly( mask, fillContAll,  cv::Scalar( 255, 255, 255));


    cv::Rect r = cv::boundingRect(facecropPts);
    cv::Point center = (r.tl() + r.br()) / 2;
    cv::seamlessClone(srcImage,dstImage,  mask,center , resImage, cv::MIXED_CLONE);
    
    
    
    cv::cvtColor(resImage, (*dst).src_image, CV_RGB2RGBA);


}
-(void)remeshEyes:(FaceImage**)face{
    std::vector<cv::Point> eyes_l=[(*face) getFeaturePointsWithStartIndex:36 endPoint:41];
    std::vector<cv::Point> eyes_r=[(*face) getFeaturePointsWithStartIndex:42 endPoint:47];
    changeEyeShape(face ,eyes_l);
    changeEyeShape(face ,eyes_r);
}
void changeEyeShape(FaceImage** face ,std::vector<cv::Point> eyes_l){
    
    cv::Rect rect= resizeRect( boundingRect(eyes_l),1.05);
    cv::Rect rectImage= resizeRect( rect,1.05);
    cv::Point px=rectImage.tl();
    cv::Point p1=rect.tl();
    cv::Point p2=cv::Point(rect.x,rect.y+rect.height);
    cv::Point p3=rect.br();
    cv::Point p4=cv::Point(rect.x+rect.width,rect.y);
    
    MySpline *spline_l=[[MySpline alloc] init:3];
    //MySpline *spline_dst=[[MySpline alloc] init:3];
    std::vector<cv::Point> lg_pts;
    for (int i=0;i<eyes_l.size();i++){
        [spline_l addPoint:eyes_l[i]-px];
        lg_pts.push_back(eyes_l[i]-px);
        cv::Point nextPt;
        if(i==eyes_l.size()-1){
            nextPt=(eyes_l[i]+eyes_l[0])/2;
        }else{
            nextPt=(eyes_l[i]+eyes_l[i+1])/2;
        }
        
        lg_pts.push_back(nextPt-px);
        
        
    }
    [spline_l addPoint:eyes_l[0]-px];
    std::vector<cv::Point> sp_pts=[spline_l getSplinePoints];
    std::vector<cv::Point> temp;
    temp.push_back(sp_pts[0]);
    for (int i=1;i<sp_pts.size()-1;i++){
        if(sp_pts[i].x==sp_pts[i-1].x && sp_pts[i].y==sp_pts[i].y){
            continue;
        }
        temp.push_back(sp_pts[i]);
    }
    sp_pts=temp;
    lg_pts.push_back(p1-px);
    lg_pts.push_back(p2-px);
    lg_pts.push_back(p3-px);
    lg_pts.push_back(p4-px);
    
    sp_pts.push_back(p1-px);
    sp_pts.push_back(p2-px);
    sp_pts.push_back(p3-px);
    sp_pts.push_back(p4-px);
    
    int indecisCount=sizeof(remeshEyes)/sizeof(remeshEyes[0]);
    int  meshCount=indecisCount/3;
    
    cv::Mat _srcImage=(*face).src_image(rectImage);
    cv::Mat _dstImage=_srcImage.clone();
    
    for (int index=0;index<meshCount;index++){
        
        cv::Point2f srcTri[3];
        cv::Point2f dstTri[3];
        int i =remeshEyes[3*index];
        int j =remeshEyes[3*index+1];
        int k =remeshEyes[3*index+2];
        
        dstTri[0]=sp_pts[i];
        dstTri[1]=sp_pts[j];
        dstTri[2]=sp_pts[k];
        
        srcTri[0]=lg_pts[i];
        srcTri[1]=lg_pts[j];
        srcTri[2]=lg_pts[k];
        
        affineTriangle(srcTri,dstTri,_dstImage,_srcImage);
        //        cv::line(_dstImage,sp_pts[i],sp_pts[j],cv::Scalar(0,255,0),1);
        //        cv::line(_dstImage,sp_pts[k],sp_pts[j],cv::Scalar(0,255,0),1);
        //        cv::line(_dstImage,sp_pts[i],sp_pts[k],cv::Scalar(0,255,0),1);
    }
    _dstImage.copyTo(_srcImage);
    

}
-(void)faceInFace:(FaceImage*)smallFace addDestination:(FaceImage**)largeFace Rect:(cv::Rect)rect{

    cv::Mat src=(*largeFace).src_image;

    cv::Mat roi = smallFace.src_image;  
        
        cv::Mat srcROI = src( rect );
        roi.copyTo( srcROI);
      //  res.src_image=src;


     //  return res;
}
- (FaceImage*)beautyMixBound:(int)depth addFace:(FaceImage*)face addBack:(FaceImage*)back{
    
    FaceImage*res=[FaceImage new];
    
    cv::Mat imageMat=face.src_image;

    cv::cvtColor(imageMat, imageMat, CV_RGBA2BGR);
    cv::Mat bilaImage;
    cv::bilateralFilter(imageMat, bilaImage, depth, 40,0);
     cv::cvtColor(bilaImage, bilaImage, CV_BGR2RGBA);
    res=face.clone;
    res.src_image=bilaImage;//mixSrcBackMask(bilaImage,src_mask,back.src_image);

    return res;
    
}
- (void)ovelayImageOnFace:(FaceImage**)face{
    
    cv::Mat imageMat=(*face).src_image;

    CGFloat width, height;
    UIImage *imageBack=  [Utils UIImageFromCVMat:imageMat];    // input image to be composited over new image as example
    UIImage *imageOver=[(*face) getOverlayImage];
    UIImage *outputImage ;
    width=imageBack.size.width;
    height=imageBack.size.height;
    
    if(imageOver){
    // create a new bitmap image context at the device resolution (retina/non-retina)
    UIGraphicsBeginImageContextWithOptions(CGSizeMake(width, height), YES, 0.0);
    
    // get context
    CGContextRef context = UIGraphicsGetCurrentContext();
    
    // push context to make it current
    // (need to do this manually because we are not drawing in a UIView)
    UIGraphicsPushContext(context);
    
    // drawing code comes here- look at CGContext reference
    // for available operations
    // this example draws the inputImage into the context
    [imageBack drawInRect:CGRectMake(0, 0, width, height)];
    [imageOver drawInRect:CGRectMake(0, 0, width, height)];
    // pop context
    UIGraphicsPopContext();
    
    // get a UIImage from the image context- enjoy!!!
    outputImage = UIGraphicsGetImageFromCurrentImageContext();
    
    // clean up drawing environment
    UIGraphicsEndImageContext();
    
//    cv::Mat imageMat=(*face).src_image;
//    cv::Mat overlayMat=[(*face) getOverlayImage];
//    if(!overlayMat.empty()){
//     (*face).src_image=overlayImage(imageMat,overlayMat);
//   
//    }
    }else{
        outputImage=imageBack;
    }
    (*face).src_image=[Utils cvMatFromUIImage:outputImage];
    imageBack=nil;
    imageOver=nil;

}

- (void)blurMixBound:(int)depth addFace:(FaceImage*)face addBack:(FaceImage**)back{
    
  
    
    cv::Mat imageMat=face.src_image;
    
        cv::Mat src_mask(imageMat.rows,imageMat.cols, CV_8UC4, cv::Scalar(0,0,0,0));
    
        std::vector<cv::Point> facecropPts;
        int indecisCount=sizeof(_faceBound)/sizeof(_faceBound[0]);
        for (int i=0;i<indecisCount;i++){
            int k=_faceBound[i];
            cv::Point pt=face.facelandmark[k];
//            if(k==2 ){
//                pt=(face.facelandmark[36]+face.facelandmark[5])/2;
//            }
//            else if(k==14){
//                pt=(face.facelandmark[45]+face.facelandmark[12])/2;
//            }
//            
            facecropPts.push_back(pt);

        }
    
        resizeVector(facecropPts,0.90);
       // cv::Mat cropMat=src_mask.clone();
      //  croppolygon(facecropPts,imageMat,cropMat);
    
        std::vector<std::vector<cv::Point> > fillContAll;
    
        fillContAll.push_back(facecropPts);
    
        cv::fillPoly( src_mask, fillContAll,  cv::Scalar( 255, 255, 255,255));
    
        cv::GaussianBlur(src_mask,src_mask,cv::Size(depth,depth),depth);
    


    (*back).src_image=mixSrcBackMask(imageMat,src_mask,(*back).src_image);
    

    
}

-(UIImage*)Jpg2Png:(UIImage*)image{
    
    NSData* imageData = UIImagePNGRepresentation(image);
    // UIImageOrientationRight,
    
    cv::Mat mat=[Utils cvMatFromUIImage:[UIImage imageWithData:imageData]];
    
    
    
    if(image.imageOrientation == UIImageOrientationLeft || image.imageOrientation == UIImageOrientationRight )
    {
        mat=mat.t();
        cv::resize(mat, mat, cv::Size(480,640));
    }
    else {
        
        int rh=480*480/640;
        
        if(image.imageOrientation == UIImageOrientationDown){
            
            cv::flip(mat, mat, -1);
        }
        cv::Mat crop;
        cv::resize(mat, crop, cv::Size(480,rh));
        cv::Mat whole_image;//(480,640, CV_8UC4, cv::Scalar(0,0,0,0));
        
        cv::resize(mat, whole_image, cv::Size(480,640));
        
        whole_image=0;
        cv::Rect rect=cv::Rect(0,(640-rh)/2,480,rh);
        
        cv::Mat srcROI = whole_image( rect );
        crop.copyTo( srcROI);
        mat=whole_image;//.clone();
        NSLog(@"%li",image.imageOrientation);
        
    }
    //
    return [Utils UIImageFromCVMat:mat];
}

void resizeVector(std::vector<cv::Point>& v,float rate){
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
cv::Scalar getSkinToneColor(cv::Mat face){
    
     cv::Mat res;
    
    cv::Mat sc = face.clone();//background Image
    
    
    res= sc.clone();
    float  kp[512];
    int range=32;
    int div=256/range;
    cv::Scalar meanColor;
    float Rm=0;
    float Gm=0;
    float Bm=0;
    memset(kp, 0, sizeof(float) * 512);
    for (int x = 0; x < sc.cols; x++)
    {
        for (int y = 0; y < sc.rows; y++)
        {
            
            int R = cv::saturate_cast<uchar>((sc.at<cv::Vec4b>(y, x)[0]));
            int G = cv::saturate_cast<uchar>((sc.at<cv::Vec4b>(y, x)[1]));
            int B = cv::saturate_cast<uchar>((sc.at<cv::Vec4b>(y, x)[2]));
            int Rx=R/range;
            int Gx=G/range;
            int Bx=B/range;
            int index=Bx*(div*div)+Gx*div+Rx;
            kp[index]+=0.1;
        }
    }
    int maxelem = 0;
    float  maxV=0;
 
    for (int i = 0; i <512; i++)
    {
        if(kp[i]>maxV){
            maxV=kp[i];
            maxelem=i;
        }
    }
    long count=0;
    for (int x = 0; x < sc.cols; x++)
    {
        for (int y = 0; y < sc.rows; y++)
        {
            int R = cv::saturate_cast<uchar>((sc.at<cv::Vec4b>(y, x)[0]));
            int G = cv::saturate_cast<uchar>((sc.at<cv::Vec4b>(y, x)[1]));
            int B = cv::saturate_cast<uchar>((sc.at<cv::Vec4b>(y, x)[2]));
            int Rx=R/range;
            int Gx=G/range;
            int Bx=B/range;
            int index=Bx*(div*div)+Gx*div+Rx;
            if(index==maxelem){
                
                Rm+=R/255.0;
                Gm+=G/255.0;
                Bm+=B/255.0;
                count++;

           }
        }
    }
    meanColor.val[0]=Rm*255/count;
    meanColor.val[1]=Gm*255/count;
    meanColor.val[2]=Bm*255/count;
    return meanColor;
    
}


cv::Mat overlayImage(cv::Mat src,cv::Mat overlay)
{
    cv::Mat res;
    
    cv::Mat bk = src.clone();

    
    res= src.clone();
    
    for (int x = 0; x < overlay.cols; x++)
    {
        for (int y = 0; y < overlay.rows; y++)
        {
            
            int R = cv::saturate_cast<uchar>((overlay.at<cv::Vec4b>(y, x)[0]));
            int G = cv::saturate_cast<uchar>((overlay.at<cv::Vec4b>(y, x)[1]));
            int B = cv::saturate_cast<uchar>((overlay.at<cv::Vec4b>(y, x)[2]));
            int A = cv::saturate_cast<uchar>((overlay.at<cv::Vec4b>(y, x)[3]));
            int bRR = cv::saturate_cast<uchar>((bk.at<cv::Vec4b>(y, x)[0]));
            int bGG = cv::saturate_cast<uchar>((bk.at<cv::Vec4b>(y, x)[1]));
            int bBB = cv::saturate_cast<uchar>((bk.at<cv::Vec4b>(y, x)[2]));
            int bAA = cv::saturate_cast<uchar>((bk.at<cv::Vec4b>(y, x)[3]));
            
            float rt=A/255.0;
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
//void overlayImage(cv::Mat &src, cv::Mat overlay)
//{
//    for (int y =  0; y < src.rows; ++y)
//    {
//        int fY = y;
//        
//
//        
//        for (int x = 0; x < src.cols; ++x)
//        {
//            int fX = x;
//            
//            
//            double opacity = ((double)overlay.data[3]) / 255;
//            
//            for (int c = 0; opacity > 0 && c < src.channels(); ++c)
//            {
//                unsigned char overlayPx = overlay.data[fY * overlay.step + fX * overlay.channels() + c];
//                unsigned char srcPx = src.data[y * src.step + x * src.channels() + c];
//                src.data[y * src.step + src.channels() * x + c] = srcPx * (1. - opacity) + overlayPx * opacity;
//            }
//        }
//    }
//}
int changeColorRate(int Rmax,int Rt,int R){
    return R*(Rt-255)/(Rt-Rmax)+Rt*(255-Rmax)/(Rt-Rmax);
}
void normalizeColor(int &R,int &G, int &B){
    int maxV=std::max(std::max(R,G),B);
    R=255*R/maxV;
    G=255*G/maxV;
    B=255*B/maxV;
    
}
void croppolygon(std::vector<cv::Point> pts,cv::Mat src,cv::Mat& dst){
    cv::Mat mask = cv::Mat::zeros( src.size(), CV_8UC1 );
    std::vector<std::vector<cv::Point> > fillContAll;
    fillContAll.push_back(pts);
    cv::fillPoly( mask, fillContAll,  cv::Scalar( 255));
    cv::Rect rect = boundingRect( pts );
    cv::Mat roi = src( rect ).clone();
    mask = mask( rect ).clone();
    cv::Mat srcROI = dst( rect );
    roi.copyTo( srcROI, mask );
    
}

@end
