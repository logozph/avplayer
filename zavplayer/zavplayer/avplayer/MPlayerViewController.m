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
#import "Foundation/NSError.h"



@interface MPlayerViewController ()
- (void)play:(id)sender;
- (void)pause:(id)sender;
- (void)stop:(id)sender;
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

static void *AVPlayerDemoPlaybackViewControllerStatusObservationContext = &AVPlayerDemoPlaybackViewControllerStatusObservationContext;


@implementation MPlayerViewController

@synthesize mURL, mPlayer, mAsset, mPlayerItem;

- (void)viewDidLoad {
    [super viewDidLoad];

    CGRect rect = self.view.frame;
    //rect.origin.y = 100;
    //rect.size.height /= 2;
    
    PlayerView* playview = [[PlayerView alloc]initWithFrame:rect];
    UIColor* black = [UIColor colorWithRed:0 green:0 blue:0 alpha:1];
    playview.backgroundColor = black;
    
    [self prepareToPlay];
    [playview setPlayer:self.mPlayer];
    [self.view addSubview:playview];
    
    [self initProgressbar];
    [self initTextField];
   
    [self showButtonFront];
    [self initmButton];
    // Do any additional setup after loading the view, typically from a nib.
}

-(void)showPlayButton{
    self.playback.enabled = true;
}

-(void)showStopButton{
    self.stop.enabled = true;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)play:(id)sender{
    if(mPlayer)
        [mPlayer play];
    else
    {
        [self prepareToPlay];
    }
    
    [self addPeriodicTimeObserver];
}

-(void)pause:(id)sender{
    [mPlayer pause];
}

-(void)stop:(id)sender{
    [mPlayer setRate:0];
    [mPlayer replaceCurrentItemWithPlayerItem:nil];
    mPlayerItem = nil;
    mAsset = nil;
    mPlayer = nil;
}

-(void)prepareToPlay
{
    NSURL *url = [[NSURL alloc]initWithString:@"http://pcvideows.titan.mgtv.com/mp4/2016/dianshiju/byqc_51445/8F8F8039D7ACEB75551B0D1AFF5292A2_20160630_1_1_214.mp4/playlist.m3u8?arange=0&pm=5HqZRvGg4jel2EjlYZ5AFsxHZjTSbsZ0Rlghky7EEhiXw9Gwam__1v9l068Ql2iac5vLn8oSCUZ1uYXifkeYStVdQ5vKsB2rYBzF2yzocwEITu_HrR6r10k~QW2cD8KcUa5ODhI6zaYUY3koQtZozOpBAQ_D227MHwgZn1gir9aa8Ur8ufJ5A70YrBVlNNsa~MR5Vs01PFxBcIoPnozO7rAYYvDis5vla~6bc8oTDSJbOmxv3ehTMsC45U6Vkj~Ht_eAj_pQCc1LeLX9abS5hl47dEN6beCqgWXv7gYqxLOnuglZdsr_SKZBqbF~J6b7P9CtoT9A0QxdE1ESbyzX_Ws4MZ9mZCBZWge85qW9KbN_6RguNhVhpymUiv3ywBYKtdOqKhMLTCOIwSbm7DnKyg--"];
    mAsset = [AVURLAsset URLAssetWithURL:url options:nil];
    NSArray *assetKeys = @[@"playable", @"hasProtectedContent"];
    mPlayerItem = [AVPlayerItem playerItemWithAsset:mAsset automaticallyLoadedAssetKeys:assetKeys];
    
    //CMTime vinfo = [mAsset duration];

    NSKeyValueObservingOptions options =
    NSKeyValueObservingOptionOld | NSKeyValueObservingOptionNew;
    
    // Register as an observer of the player item's status property
    [mPlayerItem addObserver:self
                 forKeyPath:@"status"
                    options:options
                    context:&AVPlayerDemoPlaybackViewControllerStatusObservationContext];
    
    // Associate the player item with the player
    mPlayer = [AVPlayer playerWithPlayerItem:mPlayerItem];
    
    self.playback.enabled = false;
    self.stop.enabled = false;
}

- (void)observeValueForKeyPath:(NSString *)keyPath
                      ofObject:(id)object
                        change:(NSDictionary<NSString *,id> *)change
                       context:(void *)context {
    // Only handle observations for the PlayerItemContext
    if (context != &AVPlayerDemoPlaybackViewControllerStatusObservationContext) {
        [super observeValueForKeyPath:keyPath ofObject:object change:change context:context];
        return;
    }
    
    if ([keyPath isEqualToString:@"status"]) {
        AVPlayerItemStatus status = AVPlayerItemStatusUnknown;
        // Get the status change from the change dictionary
        NSNumber *statusNumber = change[NSKeyValueChangeNewKey];
        if ([statusNumber isKindOfClass:[NSNumber class]]) {
            status = statusNumber.integerValue;
        }
        // Switch over the status
        NSError *err = nil;
        switch (status) {
            case AVPlayerItemStatusReadyToPlay:
                NSLog(@"stastus AVPlayerItemStatusReadyToPlay");
                // Ready to Play
                self.playback.enabled = true;
                self.stop.enabled = true;
                break;
            case AVPlayerItemStatusFailed:
                // Failed. Examine AVPlayerItem.error
                err = mPlayerItem.error;
                NSLog(@"failed des %@, reason %@", [err localizedDescription], [err localizedFailureReason]);
                break;
            case AVPlayerItemStatusUnknown:
                // Not ready
                break;
        }
    }
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
    
    //hidden play button
    self.pause.hidden = false;
    self.pause.enabled = true;
    self.playback.hidden = true;
    
//    UIControlState bstate = self.playback.state;
//    UIButtonType types = self.playback.buttonType;
    //[self.playback setTitle:@"pause" forState:UIControlStateNormal];
}
- (IBAction)clickPause:(id)sender {
    //hidden pause button
    self.pause.hidden = true;
    self.playback.hidden = false;
    [self pause: @""];
}

- (IBAction)clickstop:(id)sender {
    NSLog(@"click stop!");
    [self stop:@""];
}

- (IBAction)triggerprogressbar:(id)sender {
    float currtime = self.progressbar.value;
    CMTime time = CMTimeMakeWithSeconds(currtime, 1);
    NSLog(@"seek to time %f second", currtime);
    if(currtime > 0)
    {
        [mPlayer seekToTime:time];
    };
}

//add PeriodicTimeObserver
-(void)addPeriodicTimeObserver{
    
    CMTime time = CMTimeMakeWithSeconds(0.5, NSEC_PER_SEC);
    dispatch_queue_t queue = dispatch_get_main_queue();
    __weak typeof(self) wSelf = self;
    [self.mPlayer addPeriodicTimeObserverForInterval:time queue:queue usingBlock:^(CMTime time) {
        [wSelf updateprogress];
    }];
}



- (IBAction)seekProgress:(id)sender {
}

//progressbar
-(void)initProgressbar{
    CMTime fileduration = self.mAsset.duration;
    float totalsec = fileduration.value/fileduration.timescale;
    
    //init progressbar
    [self.progressbar setMinimumValue:0.0];
    [self.progressbar setMaximumValue:totalsec];
    [self.progressbar setValue:0.0];
}

-(void)initTextField{
    CMTime fileduration = self.mAsset.duration;
    float totalsec = fileduration.value/fileduration.timescale;
    //init textfield
    [self.mPlayTime setText:@"00:00"];
    int min = (int)totalsec/60;
    int sec = (int)totalsec%60;
    NSString *durationstr = [NSString stringWithFormat:@"%2d:%2d",min,sec];
    [self.mDuration setText:durationstr];
}

-(void)updateprogress{
    CMTime currtime = [self.mPlayer currentTime];
    int totalsec = (int)(currtime.value/currtime.timescale);
    //upadte progressbar
    [self.progressbar setValue:totalsec];
    
    //update textfield
    int min = totalsec/60;
    int sec = totalsec%60;
    NSString *playtimestr = [NSString stringWithFormat:@"%02d:%02d",min,sec];
    [self.mPlayTime setText:playtimestr];
}

-(void)initmButton{
    self.playback.hidden = false;
    self.pause.hidden = true;
    self.stop.hidden = false;
}

-(void)showButtonFront{
    [self.view bringSubviewToFront:self.playback];
    [self.view bringSubviewToFront:self.stop];
    [self.view bringSubviewToFront:self.pause];
    [self.view bringSubviewToFront:self.progressbar];
    
    [self.view bringSubviewToFront:self.mPlayTime];
    [self.view bringSubviewToFront:self.mDuration];
}

@end
