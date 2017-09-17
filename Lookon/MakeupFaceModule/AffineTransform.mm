//
//  AffinTransform.m
//  Lookon
//
//  Created by My Star on 8/14/17.
//  Copyright © 2017 My Star. All rights reserved.
//

#import "AffineTransform.h"

@implementation AffineTransform
-(FaceImage*)transformAffine:(FaceImage*)dst addSource:(FaceImage*)src{
    FaceImage*res=[FaceImage new];
    res=dst.clone;
    cv::Mat _srcImage=src.src_image.clone();
    cv::Mat _dstImage=dst.src_image.clone();

    for (int index=0;index<dst.meshCount;index++){
        
        cv::Point2f srcTri[3];
        cv::Point2f dstTri[3];
        int i =dst.faceMeshIndices[3*index];
        int j =dst.faceMeshIndices[3*index+1];
        int k =dst.faceMeshIndices[3*index+2];

        dstTri[0]=dst.facelandmark[i];
        dstTri[1]=dst.facelandmark[j];
        dstTri[2]=dst.facelandmark[k];
        
        srcTri[0]=src.facelandmark[i];
        srcTri[1]=src.facelandmark[j];
        srcTri[2]=src.facelandmark[k];

        affineTriangle(srcTri,dstTri,_dstImage,_srcImage);
       
     
    }
     res.src_image=_dstImage;
     return res;
}
void getFixPoint(int p,int q,int r, int s ,std::vector<cv::Point> &res,FaceImage*dst,FaceImage*src){
  
    float s1=cv::norm(src.facelandmark[48]-src.facelandmark[54]);
    float s2=cv::norm(dst.facelandmark[48]-dst.facelandmark[54]);
    cv::Point cen1=(src.facelandmark[p]+src.facelandmark[q])/2;
    cv::Point cen2=(dst.facelandmark[p]+dst.facelandmark[q])/2;
    
    res[p]=cen2+(src.facelandmark[p]-cen1)*s2/s1;
    res[q]=cen2+(src.facelandmark[q]-cen1)*s2/s1;
    res[r]=cen2+(src.facelandmark[r]-cen1)*s2/s1;
    res[s]=cen2+(src.facelandmark[s]-cen1)*s2/s1;

}

void getFixPoint2(int p,int q,int r, int s ,std::vector<cv::Point> &res,FaceImage*dst,FaceImage*src){
     cv::Point cenpq1=(src.facelandmark[p]+src.facelandmark[q])/2;
     cv::Point cenpq2=(dst.facelandmark[p]+dst.facelandmark[q])/2;
    cv::Point cenrs1=(src.facelandmark[r]+src.facelandmark[s])/2;
    cv::Point cenrs2=(dst.facelandmark[r]+dst.facelandmark[s])/2;
    
//    float p1=cv::norm(src.facelandmark[p]-cenp1);
//    float p2=cv::norm(dst.facelandmark[p]-cenp2);
//    float r1=cv::norm(src.facelandmark[p]-cenr1);
//    float r2=cv::norm(dst.facelandmark[p]-cenr2);
    
    float ps1=cv::norm(cenpq1-src.facelandmark[48]);
    float ps2=cv::norm(cenpq2-dst.facelandmark[48]);
    
    float rs1=cv::norm(cenrs1-src.facelandmark[54]);
    float rs2=cv::norm(cenrs2-dst.facelandmark[54]);
    
    res[p]=cenpq2+(src.facelandmark[p]-cenpq1)*ps2/ps1;
    res[r]=cenrs2+(src.facelandmark[r]-cenrs1)*rs2/rs1;
    
//    cv::Point cenq1=(src.facelandmark[q]+src.facelandmark[q])/2;
//    cv::Point cenq2=(dst.facelandmark[q]+dst.facelandmark[q])/2;
//    cv::Point cens1=(src.facelandmark[s]+src.facelandmark[s])/2;
//    cv::Point cens2=(dst.facelandmark[s]+dst.facelandmark[s])/2;
    
    //    float p1=cv::norm(src.facelandmark[p]-cenp1);
    //    float p2=cv::norm(dst.facelandmark[p]-cenp2);
    //    float r1=cv::norm(src.facelandmark[p]-cenr1);
    //    float r2=cv::norm(dst.facelandmark[p]-cenr2);
    
    float qs1=cv::norm(cenpq1-src.facelandmark[48]);
    float qs2=cv::norm(cenpq2-dst.facelandmark[48]);
    
    float ss1=cv::norm(cenrs1-src.facelandmark[54]);
    float ss2=cv::norm(cenrs2-dst.facelandmark[54]);
    
    res[q]=cenpq2+(src.facelandmark[q]-cenpq1)*qs2/qs1;
    res[s]=cenrs2+(src.facelandmark[s]-cenrs1)*ss2/ss1;

    
    
   // cv::Point pn1=cenp2+(dst.facelandmark[p]-cenp2)*ps2/ps1;
    
}
void getFixPoint3(int p,int q,int r, int s ,std::vector<cv::Point> &res,FaceImage*dst,FaceImage*src){
    cv::Point cenpq1=(src.facelandmark[p]+src.facelandmark[q])/2;
    cv::Point cenpq2=(dst.facelandmark[p]+dst.facelandmark[q])/2;
    cv::Point cenrs1=(src.facelandmark[r]+src.facelandmark[s])/2;
    cv::Point cenrs2=(dst.facelandmark[r]+dst.facelandmark[s])/2;
    
    //    float p1=cv::norm(src.facelandmark[p]-cenp1);
    //    float p2=cv::norm(dst.facelandmark[p]-cenp2);
    //    float r1=cv::norm(src.facelandmark[p]-cenr1);
    //    float r2=cv::norm(dst.facelandmark[p]-cenr2);
    
    float ps1=cv::norm(cenpq1-src.facelandmark[48]);
    float ps2=cv::norm(cenpq2-dst.facelandmark[48]);
    
    float rs1=cv::norm(cenrs1-src.facelandmark[54]);
    float rs2=cv::norm(cenrs2-dst.facelandmark[54]);
    
    res[p]=cenpq2+(dst.facelandmark[p]-cenpq2)*ps2/ps1;
    res[r]=cenrs2+(dst.facelandmark[r]-cenrs2)*rs2/rs1;
    
    //    cv::Point cenq1=(src.facelandmark[q]+src.facelandmark[q])/2;
    //    cv::Point cenq2=(dst.facelandmark[q]+dst.facelandmark[q])/2;
    //    cv::Point cens1=(src.facelandmark[s]+src.facelandmark[s])/2;
    //    cv::Point cens2=(dst.facelandmark[s]+dst.facelandmark[s])/2;
    
    //    float p1=cv::norm(src.facelandmark[p]-cenp1);
    //    float p2=cv::norm(dst.facelandmark[p]-cenp2);
    //    float r1=cv::norm(src.facelandmark[p]-cenr1);
    //    float r2=cv::norm(dst.facelandmark[p]-cenr2);
    
    float qs1=cv::norm(cenpq1-src.facelandmark[48]);
    float qs2=cv::norm(cenpq2-dst.facelandmark[48]);
    
    float ss1=cv::norm(cenrs1-src.facelandmark[54]);
    float ss2=cv::norm(cenrs2-dst.facelandmark[54]);
    
    res[q]=cenpq2+(dst.facelandmark[q]-cenpq2)*qs2/qs1;
    res[s]=cenrs2+(dst.facelandmark[s]-cenrs2)*ss2/ss1;
    
    
    
    // cv::Point pn1=cenp2+(dst.facelandmark[p]-cenp2)*ps2/ps1;
    
}

cv::Point getFromHdis(cv::Point p1, cv::Point p2, float h){
    float d=cv::norm(p2-p1);
    float cos=(p2.x-p1.x)/d;
    float sin=(p2.y-p1.y)/d;
    int xx=p2.x-(d*cos-h*sin);
    int yy=p2.y-(h*cos+d*sin);
    return cv::Point(xx,yy);
}
-(FaceImage*)transformRectAffine:(FaceImage*)dst addSource:(FaceImage*)src{
    
    FaceImage*res=[FaceImage new];
    res=dst.clone;
    std::vector<cv::Point> dstPoint=[self getRectFromface:dst];
    std::vector<cv::Point> srcPoint=[self getRectFromface:src];
    cv::Mat _srcImage=src.src_image.clone();
    cv::Mat _dstImage=dst.src_image.clone();
    cv::Point2f srcTri[3];
    cv::Point2f dstTri[3];
    
    dstTri[0]=dstPoint[0];
    dstTri[1]=dstPoint[1];
    dstTri[2]=dstPoint[2];
    
    srcTri[0]=srcPoint[0];
    srcTri[1]=srcPoint[1];
    srcTri[2]=srcPoint[2];
    affineTriangle(srcTri,dstTri,_dstImage,_srcImage);
    
    dstTri[0]=dstPoint[0];
    dstTri[1]=dstPoint[2];
    dstTri[2]=dstPoint[3];
    
    srcTri[0]=srcPoint[0];
    srcTri[1]=srcPoint[2];
    srcTri[2]=srcPoint[3];
    cv::Mat affin=affineTriangle(srcTri,dstTri,_dstImage,_srcImage);
    cv::transform(src.facelandmark, res.facelandmark, affin);
    res.src_image=_dstImage;
    return res;
}
-(std::vector<cv::Point>)getRectFromface:(FaceImage*)face{
//    cv::Mat _dstImage=face.src_image.clone();
//    
//    cv::Point eye_center= findDropPoint(face.facelandmark[8], face.facelandmark[0],face.facelandmark[16]);
//    
//    cv::Point p2=face.facelandmark[8]+(face.facelandmark[0]-eye_center);
//    cv::Point p3=face.facelandmark[8]+(face.facelandmark[16]-eye_center);
//
//    cv::Point headtopCenter=eye_center+(eye_center-face.facelandmark[8])*0.4;//(face.facelandmark[21]+face.facelandmark[22])/2;
//    cv::Point dropPoint=findDropPoint(headtopCenter,face.facelandmark[0],face.facelandmark[16]);
//    cv::Point p1=headtopCenter+(face.facelandmark[0]-dropPoint);
//    cv::Point p4=headtopCenter+(face.facelandmark[16]-dropPoint);
    float rate=2.5;
    cv::Mat _dstImage=face.src_image.clone();
    
    cv::Point eye_left=(face.facelandmark[37]+face.facelandmark[40])/2;
    cv::Point eye_right=(face.facelandmark[43]+face.facelandmark[46])/2;
    
    cv::Point eye_center= findDropPoint(face.facelandmark[27], eye_left,eye_right);
    
    cv::Point p2=face.facelandmark[8]+(eye_left-eye_center)*rate;
    cv::Point p3=face.facelandmark[8]+(eye_right-eye_center)*rate;
    
    cv::Point headtopCenter=eye_center+(eye_center-face.facelandmark[8])*0.4;//(face.facelandmark[21]+face.facelandmark[22])/2;
    cv::Point dropPoint=findDropPoint(headtopCenter,eye_left,eye_right);
    cv::Point p1=headtopCenter+(eye_left-dropPoint)*rate;
    cv::Point p4=headtopCenter+(eye_right-dropPoint)*rate;

    std::vector<cv::Point> res;
    res.push_back(p1);
    res.push_back(p2);
    res.push_back(p3);
    res.push_back(p4);
    return res;
}
-(void)testWrapAffine:(cv::Mat&)dstImage addSource:(cv::Mat)srcImage{
    cv::Point2f srcTri[3];
    cv::Point2f dstTri[3];
    
    
    /// Set your 3 points to calculate the  Affine Transform
    srcTri[0] = cv::Point2f( 0,0 );
    srcTri[1] = cv::Point2f( srcImage.cols - 1, 0 );
    srcTri[2] = cv::Point2f( 0, srcImage.rows - 1 );
    
    dstTri[0] = cv::Point2f( dstImage.cols*0.0, dstImage.rows*0.33 );
    dstTri[1] = cv::Point2f( dstImage.cols*0.85, dstImage.rows*0.25 );
    dstTri[2] = cv::Point2f( dstImage.cols*0.15, dstImage.rows*0.7 );
    affineTriangle(srcTri,dstTri,dstImage,srcImage);
}
//cv::Mat affineTriangle(cv::Point2f srcTri[3],cv::Point2f dstTri[3], cv::Mat &dstImage,cv::Mat srcImage){
//  
//    cv::Mat warp_mat( 2, 3, CV_32FC1 );
//    
//    cv::Mat warp_dst = cv::Mat::zeros( srcImage.rows, srcImage.cols, srcImage.type());
//    
//    /// Get the Affine Transform
//    warp_mat = getAffineTransform( srcTri, dstTri );
//    
//    
//    
//    /// Apply the Affine Transform just found to the src image
//    warpAffine( srcImage, warp_dst, warp_mat, warp_dst.size(), cv::INTER_CUBIC, cv::BORDER_REFLECT_101);
//    std::vector<cv::Point> pts;
//    pts.push_back(dstTri[0]);
//    pts.push_back(dstTri[1]);
//    pts.push_back(dstTri[2]);
//   // cv::Mat dst(dstImage.size(), dstImage.type(), cv::Scalar(0));
//    cropPolygon(pts, warp_dst,dstImage);
//    
//    return warp_mat;
//}
cv::Point findDropPoint(cv::Point top, cv::Point B,cv::Point C){
    cv::Point A=top;
    float area=fabs((A.x*(B.y-C.y)+B.x*(C.y-A.y)+C.x*(A.y-B.y))/2.0);
    
    float BC=cv::norm(B-C);
    float AB=cv::norm(A-B);
    
    float HH=2*area/BC;
    float BE=sqrtf(AB*AB-HH*HH);
    cv::Point res=B+(C-B)*BE/BC;
    return res;
}

@end
