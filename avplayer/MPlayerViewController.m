//
//  PlayerViewController.m
//  zavplayer
//
//  Created by 朱鹏飞 on 2017/10/20.
//  Copyright © 2017年 zhupengfei. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "MPlayerViewController.h"
#import "MAVPlayerView.h"

@interface MPlayerViewController ()
- (void)play:(id)sender;
- (void)pause:(id)sender;
- (void)showMetadata:(id)sender;
- (void)initScrubberTimer;
- (void)showPlayButton;
- (void)showStopButton;
//- (void)syncScrubber;
//- (BOOL)isScrubbing;
//- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil;
- (id)init;
//- (void)dealloc;
//- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation;
- (void)viewDidLoad;
- (void)viewWillDisappear:(BOOL)animated;
- (void)handleSwipe:(UISwipeGestureRecognizer*)gestureRecognizer;
//- (void)syncPlayPauseButtons;
- (void)setURL:(NSURL*)URL;
- (NSURL*)URL;
@end

@interface MPlayerViewController (Player)
- (void)removePlayerTimeObserver;
- (CMTime)playerItemDuration;
- (BOOL)isPlaying;
- (void)playerItemDidReachEnd:(NSNotification *)notification ;
- (void)observeValueForKeyPath:(NSString*) path ofObject:(id)object change:(NSDictionary*)change context:(void*)context;
@end


@implementation MPlayerViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    //[_mediainfo setText: @"this is init test!"];
    CGRect rect = self.view.frame;
    rect.origin.x = 0;
    rect.origin.y = 100;
    rect.size.height /= 2;
    MAVPlayerView* playview = [[MAVPlayerView alloc]initWithFrame:rect];
    
    UIColor* bgc = [UIColor colorWithRed:0.7 green:0.6 blue:0.2 alpha:0.9];
    playview.backgroundColor = bgc;
    [self.view addSubview:playview];
    // Do any additional setup after loading the view, typically from a nib.
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)play:(id)sender{
    [mPlayer play];
}

-(void)pause:(id)sender{
    [mPlayer pause];
}

-(id)init{
    NSURL* tmp = [[NSURL alloc]initWithString:@"http://pcvideoyf.titan.mgtv.com/mp4/2016/dianshiju/byqc_51445/8F8F8039D7ACEB75551B0D1AFF5292A2_20160630_1_1_214.mp4/playlist.m3u8?arange=0&pm=95tV9iJyqDR~RGwQgXQ3h_~IkDNRt79zk8o_COAf~9XqgK9b9QDapJI3~COhGb8Lfm5VD~kRwHTk3rJ9txxYp1EJvJvXKpOU9Fpu~Og4dn4G5vHlHWz4UA7w9PdkVxv9HgWMImAddr4LC4jKdkOQX9MieDFQLsF2_E8pgtTTU3IE52KUGYd56AjK_8XTEK~HElGkE0~YSwkrOJb_FsmAQzXWQNm1GhH3clg6~zjbIaSlsea1qQhi0FPFCl9nNSb1gbCGUDA65zrmrIzF0Jj9bPJFautZ14zrKRS57SgywSyynNFkWCA~3xviG_gHVaf0smAU4YrORO9OO3tDXSaVqWX77RGZVz5oC1gBeoEIPHJYUzn3unzuZL4JbTcMciGd4C9qtHcuMydgJy0hh4oRGw--"];
    mPlayer = [mPlayer initWithURL:tmp];
    return self;
}

-(void)showMetadata:(id)sender
{
    //TODO
    NSLog(@"");
}

-(void)setURL:(NSURL *)URL{
    self.URL = URL;
    mURL = URL;
}

- (IBAction)clickplay:(id)sender {
    NSLog(@"click play!");
    [self play: @""];
}

- (IBAction)clickstop:(id)sender {
    NSLog(@"click stop!");
}


@end
