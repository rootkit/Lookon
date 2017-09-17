//
//  WaitProgress.m
//  Lookon
//
//  Created by My Star on 8/24/17.
//  Copyright © 2017 My Star. All rights reserved.
//

#import "WaitProgress.h"
@interface WaitProgress(){
    BOOL waitCancel;
    UIImageView *spriteView;
    UIView *parentView;
    int progress;
    int relay_count;
}

@end

@implementation WaitProgress

-(id)initWithView:(UIView *)view{
 
    parentView=view;
    progress=0;
    spriteView=[[UIImageView alloc] init];
    
    CGSize spriteSize=CGSizeMake(64, 64);
    CGRect newframe=CGRectMake(view.frame.size.width/2-spriteSize.width/2,view.frame.size.height/2-spriteSize.height/2,spriteSize.width,spriteSize.height);
    [view addSubview:spriteView];
    relay_count=0;
    spriteView.frame=newframe;
    return [super init];
}
-(void)stop{
    waitCancel=YES;
}
- (void)doSomeWorkWithProgress:(NSTimer *)timer{
   
    // This just increases the progress indicator in a loop.

    if (waitCancel){
      [spriteView setHidden:YES];
     [timer invalidate];
        timer=nil;
        relay_count=0;
    }
    relay_count++;
    if(relay_count==2){
        dispatch_async(dispatch_get_main_queue(), ^{
            
            if(progress==14)progress=0;
            NSString *spriteName=[NSString stringWithFormat:@"Preloader_%d",progress];
            UIImage*image=[UIImage imageNamed:spriteName];
            spriteView.image=nil;
            spriteView.image=image;
            progress++;
        });
        relay_count=0;
    }

}

-(void)start{

    [parentView bringSubviewToFront:spriteView];
    [spriteView setHidden:NO];
    waitCancel = NO;
    [NSTimer scheduledTimerWithTimeInterval:0.1
                                     target:self
                                   selector:@selector(doSomeWorkWithProgress:)
                                   userInfo:nil
                                    repeats:YES];

}


@end
