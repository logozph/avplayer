//
//  AVPlayerView.m
//  zavplayer
//
//  Created by 朱鹏飞 on 2017/10/20.
//  Copyright © 2017年 zhupengfei. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "MAVPlayerView.h"

@implementation PlayerView;


- (AVPlayer *)player {
    return self.playerLayer.player;
}

+ (Class)layerClass {
    return [AVPlayerLayer class];
}


- (void)setPlayer:(AVPlayer *)player {
    self.playerLayer.player = player;
}

- (AVPlayerLayer *)playerLayer {
    return (AVPlayerLayer *)self.layer;
}

@end

