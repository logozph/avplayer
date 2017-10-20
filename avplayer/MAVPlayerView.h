//
//  AVPlayerView.h
//  zavplayer
//
//  Created by 朱鹏飞 on 2017/10/20.
//  Copyright © 2017年 zhupengfei. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <AVFoundation/AVFoundation.h>
#import <AVFoundation/AVPlayer.h>

@class AVPlayer;

@interface MAVPlayerView : UIView
@property (nonatomic, strong) AVPlayer* mplayer;
@property (nonatomic, strong) AVPlayerLayer* mLayer;


- (void)setPlayer:(AVPlayer*)player;
- (void)setVideoFillMode:(NSString *)fillMode;

@end
