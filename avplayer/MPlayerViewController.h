//
//  PlayerViewController.h
//  zavplayer
//
//  Created by 朱鹏飞 on 2017/10/20.
//  Copyright © 2017年 zhupengfei. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "AVFoundation/AVPlayer.h"

@interface MPlayerViewController : UIViewController
{
@private
    AVPlayer* mPlayer;
    AVPlayerItem* mPlayeritem;
    NSURL* mURL;
    
}
//@property (strong, nonatomic) IBOutlet UITextField *mediainfo;
@property (strong, nonatomic) AVPlayer *mPlayer;
@property (strong, nonatomic) AVPlayerItem *mPlayeritem;
@property (strong, nonatomic) NSURL *mURL;

@end
