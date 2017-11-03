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
@property (nonatomic) long long last_load_bytes;
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
    
    self.last_load_bytes = 0;
    [NSTimer scheduledTimerWithTimeInterval:1.0 target:self selector:@selector(myTimeObserve) userInfo:nil repeats:true];
    
    [self prepareToPlay];

    self.isplaying = false;
    CGRect rect = self.view.frame;
    self.myXibView = [xibDemoView loadFromNib];
    self.myXibView.delegate = self;
    [self.myXibView setButtonIcon: true];
    CGRect viewrect = CGRectMake(0, 20, rect.size.width, rect.size.height*0.4);
    self.myXibView.frame = viewrect;
    [self.view addSubview:self.myXibView ];

    CGRect rect_play = self.myXibView.frame;
    rect_play.origin.x = 0;
    rect_play.origin.y = 0;
    PlayerView* playview = [[PlayerView alloc]initWithFrame:rect_play];
    //UIColor* black = [UIColor colorWithRed:0 green:0 blue:0 alpha:1];

    [self.myXibView insertSubview:playview atIndex:0];
    [playview setPlayer:self.mPlayer];
    
    
//    NSTimer *looptime = [NSTimer timerWithTimeInterval:1 target:self selector:@selector(myTimeObserve) userInfo:nil repeats:true];
//    NSRunLoop *loop = [NSRunLoop currentRunLoop];
//    [loop addTimer:looptime forMode:NSDefaultRunLoopMode];
    
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
    if(mPlayer){
        [mPlayer play];
        self.playstate = ZPlayerStatusPlaying;
    }
    else
    {
        [self prepareToPlay];
    }
    
    [self addPeriodicTimeObserver];
}

-(void)pause:(id)sender{
    [mPlayer pause];
    self.playstate = ZPlayerStatusPause;
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
    //ad
    //http://mobaliyun.res.mgtv.com/new_video/2017/10/27/1021/5FB9EAC11551779E3C7DA7DF5E9BAF41_20171027_1_1_666.mp4
    //
    NSURL *url = [[NSURL alloc]initWithString:@"http://pcvideoyf.titan.mgtv.com/c1/2017/11/02_0/16ABC431F58120C330D71837D739FA13_20171102_1_1_2842_mp4/6AD59933ABA98F4BD287911AA29B49EC.m3u8?arange=0&pm=o9XgymnfhPLzGudNdfsJGzn_AIDbxtpK5gI1BLYAGl9Fx9B7PA6qJ0~1x7kglGn3hNKKYdwiHa59znSe_JOqUxqoQNL~qk~IEBgDoHaLlenvGL8V78GkoWZPf090kjTXC02Rk0BFzli0YTbN0pdJ~ugNRsQ6fyHJBbB5ZvViSTUdkePyaUx5B3ZpY3KnRrNalUGO~F7WcJyYRgbw3IKLumNsRtpQXMPC5LvUObtt7hxBhbtq_L~jFNOz5NBwfJkAxy6DneuVpsSfwFL22LMdoTAC66yEwk9r~aOLqmggMmNwoRVFgcLHC7bHxw~AEXrcxZTT7jE2bwyJLA4k2CvdZd5_0EO89aaHxXRi9JxrZ3LkK7HSuT4oogfEDQ1d7Um5WXd0EiOyN_1gpUAO6mpzP0fzjnK8zl1y49giDRhT6LDjRr97sERFjKn5RBI-"];
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
    
    //observer buffer
    [mPlayerItem addObserver:self forKeyPath:@"playbackBufferEmpty"
                     options:options
                     context:AVPlayerDemoPlaybackViewControllerStatusObservationContext];
    
    //observer buffer
    [mPlayerItem addObserver:self forKeyPath:@"playbackBufferFull"
                     options:options
                     context:AVPlayerDemoPlaybackViewControllerStatusObservationContext];
    
    [mPlayerItem addObserver:self forKeyPath:@"playbackLikelyToKeepUp"
                     options:options
                     context:AVPlayerDemoPlaybackViewControllerStatusObservationContext];
    
    
    //add playend
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(movieDidPlayToEndTime) name:AVPlayerItemDidPlayToEndTimeNotification object:mPlayerItem];
    
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
    else if([keyPath isEqualToString:@"playbackBufferEmpty"]){
        NSNumber *bufferempty = change[NSKeyValueChangeNewKey];
        bool result = [bufferempty boolValue];
        if(result){
            NSLog(@"buffer empty");
            if(self.playstate != ZPlayerStatusSuspend){
                //show buffer view
                [self.myXibView showProgressView:true];
                self.playstate = ZPlayerStatusSuspend;
            }
        }else{
            NSLog(@"buffer ok");
            //disappear buffer view
            [self.myXibView showProgressView:false];
        }
    }
    else if([keyPath isEqualToString:@"playbackBufferFull"]){
        NSNumber *value = change[NSKeyValueChangeNewKey];
        bool bufferfull = [value boolValue];
        if(bufferfull){
            NSLog(@"buffer full");
        }
        else{
            NSLog(@"buffering");
        }
    }
    else if([keyPath isEqualToString:@"playbackLikelyToKeepUp"]){
        NSNumber *newvalue = change[NSKeyValueChangeNewKey];
        NSNumber *oldvalue = change[NSKeyValueChangeOldKey];
        NSLog(@"playbackLikelyToKeepUp");
        bool newkeekup = [newvalue boolValue];
        bool oldkeekup = [oldvalue boolValue];
        if((newkeekup == 1) && (self.playstate == ZPlayerStatusSuspend)){
            self.playstate = ZPlayerStatusPlaying;
            [self.myXibView showProgressView:false];
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
    
    
    
    //rate 设置播放速率 1.0正常播放  >1.0 倍速播放  <1.0 低速播放
//    if([self.mPlayerItem canPlaySlowForward])
//        [self.mPlayer setRate:2.0];
//    float curr_rate = [self.mPlayer rate];
//    NSLog(@"curr rate : %f", curr_rate);
    
    NSArray<NSValue *> *times = self.mPlayerItem.loadedTimeRanges;
    CMTimeRange range = [[times firstObject] CMTimeRangeValue];
    float start_time = CMTimeGetSeconds(range.start);
    float buffer_range = CMTimeGetSeconds(range.duration);
    int buffer_time = start_time + buffer_range;
    NSLog(@"buffer time: %02d:%02d", buffer_time/60, buffer_time%60);
}

-(void)clickPlay{
    if(self.isplaying == false)
    {
        [self play: @""];
        self.isplaying = true;
        [self.myXibView setButtonIcon:false];
    }
    else
    {
        self.isplaying = false;
        [self pause: @""];
        [self.myXibView setButtonIcon:true];
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

-(void)movieDidPlayToEndTime{
    NSLog(@"movieDidPlayToEndTime");
}

-(void)myTimeObserve{
    NSLog(@"my time observe");
    //get speed
    if(self.mPlayerItem != nil){
        AVPlayerItemAccessLog *access_log = self.mPlayerItem.accessLog;
        
        NSArray<AVPlayerItemAccessLogEvent *> *event =  access_log.events;
        
        long long loadbyte = event.firstObject.numberOfBytesTransferred;
        if(self.last_load_bytes > 0){
            long long currsec_load_bytes = loadbyte - self.last_load_bytes;
            self.last_load_bytes = loadbyte;
            NSLog(@"current bitrate %0.6f KB/s", currsec_load_bytes/1024.0);
        }
        else
            self.last_load_bytes = loadbyte;
        //display speed
    }else{
        self.last_load_bytes = 0;
    }
}

@end
