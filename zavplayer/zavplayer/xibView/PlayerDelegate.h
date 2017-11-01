//
//  PlayerDelegate.h
//  zavplayer
//
//  Created by zhupengfei on 2017/11/2.
//  Copyright © 2017年 zhupengfei. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol PlayerDelegate <NSObject>

@optional
-(void)doSometing;

-(void)clickPlay;
-(void)clickSeek: (float) msec;

@end
