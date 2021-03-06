//
//  PlayerViewController.h
//  zavplayer
//
//  Created by 朱鹏飞 on 2017/10/20.
//  Copyright © 2017年 zhupengfei. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "AVFoundation/AVPlayer.h"
#import "AVFoundation/AVAsset.h"
#import "xibDemoView.h"
#import "PlayerDelegate.h"

enum ZPlayerStatus{
    ZPlayerStatusUnknow,
    ZPlayerStatusPlaying,
    ZPlayerStatusPause,
    ZPlayerStatusSuspend,
    ZPlayerStatusStop
};

@interface MPlayerViewController : UIViewController<PlayerDelegate>
{
@private
    AVPlayer* mPlayer;
    AVPlayerItem* mPlayeritem;
    NSURL* mURL;
    
}
//@property (strong, nonatomic) IBOutlet UITextField *mediainfo;
@property (strong, nonatomic) AVPlayer *mPlayer;
@property (strong, nonatomic) AVPlayerItem *mPlayerItem;
@property (strong, nonatomic) AVURLAsset *mAsset;
@property (strong, nonatomic) NSURL *mURL;
@property (strong, nonatomic) IBOutlet UIButton *playback;
@property (strong, nonatomic) IBOutlet UIButton *pause;
@property (strong, nonatomic) IBOutlet UIButton *stop;
@property (strong, nonatomic) IBOutlet UISlider *progressbar;
@property (strong, nonatomic) IBOutlet UILabel *mPlayTime;
@property (strong, nonatomic) IBOutlet UILabel *mDuration;

@property (strong, nonatomic) IBOutlet UIToolbar *playToolBar;
@property (strong, nonatomic) IBOutlet UILabel *mBarPlayTime;
@property (strong, nonatomic) IBOutlet UISlider *mBarSlider;
@property (strong, nonatomic) IBOutlet UILabel *mBarDuration;
@property (strong, nonatomic) IBOutlet UIButton *mBarPlay;


@property (strong, nonatomic) xibDemoView *myXibView;
@property (nonatomic) enum ZPlayerStatus playstate;

@end
