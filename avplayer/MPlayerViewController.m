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
    rect.origin.y = 100;
    rect.size.height /= 2;
    
    PlayerView* playview = [[PlayerView alloc]initWithFrame:rect];
    UIColor* black = [UIColor colorWithRed:0 green:0 blue:0 alpha:1];
    playview.backgroundColor = black;
    
    [self prepareToPlay];
    [playview setPlayer:self.mPlayer];
    [self.view addSubview:playview];
    
    [self initprogressbar];
    // Do any additional setup after loading the view, typically from a nib.
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
    NSURL *url = [[NSURL alloc]initWithString:@"http://pcvideoyf.titan.mgtv.com/mp4/2016/dianshiju/byqc_51445/8F8F8039D7ACEB75551B0D1AFF5292A2_20160630_1_1_214.mp4/playlist.m3u8?arange=0&pm=TL2yiUZ9pBvFzsZhLeDFm3jfttENi_J3Bfu1786hkNYBPt_b8lOC8O4tKddV9GSenn~ImTCUniRpHifLvCcM~s389ULsysN33d18tsGIhV9Og202U8Ugxm5xid2akKGerdybC_6f9CBio8~yhU3zoZkFycFZCJp18ocqT7KZNN9NuOSObnoCEVmUBx_fpryhQFVOZPHpI8qH8VLdZwt6s8BShRUczDBvq7azIxBZ5ZHUgPgZqLAQdYgzMiisSF7POaCN4cLxlQ0Q_DRoSXor7xF_qmDwJ0WjlMkVPl~2zuMbsOnn45qu87HtKepSeyf2PyuPpP9cbK5QKzeUpboX5TxWH77uzBD1nY09VuDTqvw0KQcM0hH~xKjO~dRydPJBqOh9audxMnGy~xDpgXRT8A--"];
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
    
    _playback.enabled = false;
    _stop.enabled = false;
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
                //[self play:@""];
                _playback.enabled = true;
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

/*
UIButtonTypeCustom = 0,                         // no button type
UIButtonTypeSystem NS_ENUM_AVAILABLE_IOS(7_0),  // standard system button

UIButtonTypeDetailDisclosure,
UIButtonTypeInfoLight,
UIButtonTypeInfoDark,
UIButtonTypeContactAdd,

UIButtonTypePlain
 */

- (IBAction)clickplay:(id)sender {
    NSLog(@"click play!");
    [self play: @""];
    
    UIControlState bstate = self.playback.state;
    UIButtonType types = self.playback.buttonType;
    [self.playback setTitle:@"pause" forState:UIControlStateNormal];
}

- (IBAction)clickstop:(id)sender {
    NSLog(@"click stop!");
    [self stop:@""];
}

-(void)initprogressbar{
    [self.progressbar setValue:0];
    [self.progressbar setMinimumValue:0];
    [self.progressbar setMaximumValue:1];
    
    if(mAsset != nil)
    {
        CMTime vinfo = [mAsset duration];
        float sec = vinfo.value/vinfo.timescale;
        [self.progressbar setMaximumValue:sec];
    }
}

- (IBAction)triggerprogressbar:(id)sender {
    float currtime = self.progressbar.value;
    CMTime seektime;
    seektime.value = currtime;
    if(currtime > 0)
    {
        
    };
}
@end
