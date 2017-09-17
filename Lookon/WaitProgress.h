//
//  WaitProgress.h
//  Lookon
//
//  Created by My Star on 8/24/17.
//  Copyright © 2017 My Star. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
@interface WaitProgress : NSObject
-(void)start;
-(void)stop;
-(id)initWithView:(UIView*)view;
@end
