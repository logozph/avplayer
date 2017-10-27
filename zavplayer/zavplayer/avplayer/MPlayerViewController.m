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
#import "../xibView/xibDemoView.h"



@interface MPlayerViewController ()

@property(nonatomic) bool isplaying;
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
//    playview.backgroundColor = black;
//
//    [self prepareToPlay];
//    [playview setPlayer:self.mPlayer];
//    [self.view addSubview:playview];
//
//    [self initProgressbar];
//    [self initTextField];
//
//    [self showButtonFront];
//    [self initmButton];
//    self.isplaying = false;
    
    
    xibDemoView *xibview = [xibDemoView loadFromNib];
    CGRect viewrect = CGRectMake(0, 20, rect.size.width, rect.size.height*0.4);
    xibview.frame = viewrect;
    [self.view addSubview:xibview];
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
    NSURL *url = [[NSURL alloc]initWithString:@"http://pcvideoyf.titan.mgtv.com/mp4/2016/dianshiju/byqc_51445/8F8F8039D7ACEB75551B0D1AFF5292A2_20160630_1_1_214.mp4/playlist.m3u8?arange=0&pm=wQD~2LmeLQIFwwnppAYm~2FBi0bnTO2pQ_gJ9UauBrQII4poPa0jit2zVAJ55VKc~IRgZ0DMnmG1dcp_SbVJmn08cBXf4yXMctLeQaJPayed0hW0_fS2ZkmsszayyKGddpC0AfbSBJYObPEUwIYreYsQvd~8IKEQMd_wo2Yy~FgjBG9pPBASG2EUb_s8Nxcy~FNsk2Yu66Q30mnJMj3qEypf4pyp5njNG4BSd51RNk4Ki8RZaS_x9BwryoaJe66_f~BnQ4FfNnucoI~nfhDE0~SWvmZAyS~~ixDa5tREc2FZggbm8YYapwWbPurdKA3utqJRLuoftqlRhkI3SYEVCquk5WSJ6vMWfyfEWAtLiB8qyMqmIXKuo5WAvZTkG4RALMcgNkaUMBdjmTIsEIOeig--"];
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
    
    self.mBarPlay.enabled = false;
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
                self.mBarPlay.enabled = true;
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
    
    //init progressbar
    [self.mBarSlider setMinimumValue:0.0];
    [self.mBarSlider setMaximumValue:totalsec];
    [self.mBarSlider setValue:0.0];
}

-(void)initTextField{
    CMTime fileduration = self.mAsset.duration;
    float totalsec = fileduration.value/fileduration.timescale;
    //init textfield
    [self.mPlayTime setText:@"00:00"];
    int min = (int)totalsec/60;
    int sec = (int)totalsec%60;
    NSString *durationstr = [NSString stringWithFormat:@"%02d:%02d",min,sec];
    [self.mDuration setText:durationstr];
    
    [self.mBarDuration setText:durationstr];
}

-(void)updateprogress{
    CMTime currtime = [self.mPlayer currentTime];
    int totalsec = (int)(currtime.value/currtime.timescale);
    //upadte progressbar
    [self.progressbar setValue:totalsec];
    [self.mBarSlider setValue:totalsec];
    
    //update textfield
    int min = totalsec/60;
    int sec = totalsec%60;
    NSString *playtimestr = [NSString stringWithFormat:@"%02d:%02d",min,sec];
    [self.mPlayTime setText:playtimestr];
    
    
    [self.mBarPlayTime setText:playtimestr];
}

-(void)initmButton{
    self.playback.hidden = false;
    self.pause.hidden = true;
    self.stop.hidden = false;
}

-(void)showButtonFront{
//    [self.view bringSubviewToFront:self.playback];
//    [self.view bringSubviewToFront:self.stop];
//    [self.view bringSubviewToFront:self.pause];
//    [self.view bringSubviewToFront:self.progressbar];
//
//    [self.view bringSubviewToFront:self.mPlayTime];
//    [self.view bringSubviewToFront:self.mDuration];
    
    [self.view bringSubviewToFront:self.playToolBar];
}

- (IBAction)barPlay:(id)sender {
    if(self.isplaying == false)
    {
        [self play: @""];
        [self.mBarPlay setTitle:@"Pause" forState:UIControlStateNormal];
        self.isplaying = true;
    }
    else
    {
        self.isplaying = false;
        [self pause: @""];
        [self.mBarPlay setTitle:@"Play" forState:UIControlStateNormal];
    }
}

- (IBAction)barClickProgress:(id)sender {
    float currtime = self.mBarSlider.value;
    CMTime time = CMTimeMakeWithSeconds(currtime, 1);
    
    if(currtime > 0)
    {
        [mPlayer seekToTime:time];
    };
}


@end
