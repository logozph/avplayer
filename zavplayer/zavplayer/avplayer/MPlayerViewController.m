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

    //rect.origin.y = 100;
    //rect.size.height /= 2;

//    playview.backgroundColor = black;
//
    [self prepareToPlay];
//    [playview setPlayer:self.mPlayer];
//    [self.view addSubview:playview];
//
//    [self initProgressbar];
//    [self initTextField];
//
//    [self showButtonFront];
//    [self initmButton];

    self.isplaying = false;
    CGRect rect = self.view.frame;
    self.myXibView = [xibDemoView loadFromNib];
    self.myXibView.delegate = self;
    [self.myXibView setButtonIcon];
    CGRect viewrect = CGRectMake(0, 20, rect.size.width, rect.size.height*0.4);
    self.myXibView.frame = viewrect;
    [self.view addSubview:self.myXibView ];

    CGRect rect_play = self.myXibView.frame;
    rect_play.origin.x = 0;
    rect_play.origin.y = 0;
    PlayerView* playview = [[PlayerView alloc]initWithFrame:rect_play];
    //UIColor* black = [UIColor colorWithRed:0 green:0 blue:0 alpha:1];

    [self.myXibView addSubview:playview];
    [self.myXibView showControl];

    [playview setPlayer:self.mPlayer];
    //[playview setBackgroundColor:black];
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
    NSURL *url = [[NSURL alloc]initWithString:@"http://mobaliyun.res.mgtv.com/new_video/2017/10/27/1021/5FB9EAC11551779E3C7DA7DF5E9BAF41_20171027_1_1_666.mp4"];
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
                NSLog(@"status AVPlayerItemStatusReadyToPlay");
                // Ready to Play
                //init progressbar
                [self initProgressbarAndField];
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

//add PeriodicTimeObserver
-(void)addPeriodicTimeObserver{
    
    CMTime time = CMTimeMakeWithSeconds(0.5, NSEC_PER_SEC);
    dispatch_queue_t queue = dispatch_get_main_queue();
    __weak typeof(self) wSelf = self;
    [self.mPlayer addPeriodicTimeObserverForInterval:time queue:queue usingBlock:^(CMTime time) {
        [wSelf updateprogress];
    }];
}

//progressbar
-(void)initProgressbarAndField{
    CMTime fileduration = self.mAsset.duration;
    float totalsec = fileduration.value/fileduration.timescale;

    [self.myXibView initSliderAndField:totalsec];
}

-(void)initTextField{
    CMTime fileduration = self.mAsset.duration;
    float totalsec = fileduration.value/fileduration.timescale;

    [self.myXibView initSliderAndField:totalsec];
}

-(void)updateprogress{
    CMTime currtime = [self.mPlayer currentTime];
    int totalsec = (int)(currtime.value/currtime.timescale);

    [self.myXibView updateProgress:totalsec];
}

-(void)clickPlay{
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

-(void)clickSeek: (float) sec{
    CMTime time = CMTimeMakeWithSeconds(sec, 1);
    NSLog(@"seek to time %f second", sec);
    if(sec > 0)
    {
        [mPlayer seekToTime:time];
    };
}


@end
