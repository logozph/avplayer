//
//  AVPlayerView.m
//  zavplayer
//
//  Created by 朱鹏飞 on 2017/10/20.
//  Copyright © 2017年 zhupengfei. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "MAVPlayerView.h"

@implementation MAVPlayerView;

@synthesize mLayer, mplayer;

+ (Class)layerClass
{
    return [AVPlayerLayer class];
}

- (AVPlayer *)player {
    return self.mLayer.player;
}

- (void)setPlayer:(AVPlayer*)player
{
    self.mLayer.player = player;
}

- (void)setVideoFillMode:(NSString *)fillMode
{
    AVPlayerLayer *playerLayer = (AVPlayerLayer*)[self layer];
    playerLayer.videoGravity = fillMode;
}

- (AVPlayerLayer *)playerLayer {
    return (AVPlayerLayer *)self.layer;
}


@end
