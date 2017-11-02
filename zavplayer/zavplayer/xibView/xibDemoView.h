//
//  xibDemoView.h
//  zavplayer
//
//  Created by 朱鹏飞 on 2017/10/27.
//  Copyright © 2017年 zhupengfei. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "PlayerDelegate.h"

enum outletTagInfo{
    clickPlayingTag
};

@interface xibDemoView : UIView

+ (instancetype)loadFromNib;



@property (nonatomic, weak) id<PlayerDelegate> delegate;
@property (strong, nonatomic) IBOutlet UIView *controlView;
@property (strong, nonatomic) IBOutlet UILabel *playedTime;
@property (strong, nonatomic) IBOutlet UILabel *totalTime;
@property (strong, nonatomic) IBOutlet UISlider *progressSlider;
@property (strong, nonatomic) IBOutlet UIButton *playButt;
@property (strong, nonatomic) IBOutlet UIView *progressView;
@property (strong, nonatomic) IBOutlet UILabel *networkDisplay;

@property (nonatomic) Boolean isControlshow;

-(void)bringControlViewToFront;
-(void)showControl;
-(void)showProgressView: (BOOL) show;
-(void)updateProgress: (int)sec;
-(void)initSliderAndField: (int)totalsec;
-(void)setButtonIcon: (Boolean) play;
-(void)bufferempty: (float) speed;
@end
