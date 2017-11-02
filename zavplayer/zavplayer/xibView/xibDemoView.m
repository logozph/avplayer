//
//  xibDemoView.m
//  zavplayer
//
//  Created by 朱鹏飞 on 2017/10/27.
//  Copyright © 2017年 zhupengfei. All rights reserved.
//

#import "xibDemoView.h"

@implementation xibDemoView

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

+(instancetype)loadFromNib{
    NSArray *views = [[NSBundle mainBundle]loadNibNamed:@"xibTestView" owner:nil options:nil];
    for (id view in views) {
        if (view && [view isKindOfClass:[self class]]) {
            return view;
        }
    }
    return nil;
}

-(void)awakeFromNib{
    [super awakeFromNib];
    self.isControlshow = false;
}

- (IBAction)clickPlay:(id)sender {
    if(self.delegate){
        [self.delegate clickPlay];
    }
}

- (IBAction)clickSeek:(id)sender {
    float seek_time = self.progressSlider.value;
    if(self.delegate){
        [self.delegate clickSeek:seek_time];
    }
}

-(void)initSliderAndField: (int)totalsec{
    [self.progressSlider setValue:0.0f];
    
    //TODO
    [self.progressSlider setMaximumValue:totalsec];
    [self.progressSlider setMinimumValue:0];

    int min = totalsec/60;
    int sec = totalsec%60;
    NSString *playtimestr = [NSString stringWithFormat:@"%02d:%02d",min,sec];
    [self.totalTime setText:playtimestr];
}

-(void)updateProgress: (int)sec{

    //upadte progressbar
    [self.progressSlider setValue:sec];

    //update textfield
    int min = sec/60;
    int m_sec = sec%60;
    NSString *playtimestr = [NSString stringWithFormat:@"%02d:%02d",min,m_sec];
    [self.playedTime setText:playtimestr];
}

-(void)setButtonIcon: (Boolean) play{
    if(play)
        [self.playButt setImage:[UIImage imageNamed:@"play"] forState:UIControlStateNormal];
    else
        [self.playButt setImage:[UIImage imageNamed:@"pause-butt"] forState:UIControlStateNormal];
}

-(void)bringControlViewToFront{
    [self bringSubviewToFront:self.controlView];
    [self bringSubviewToFront:self.progressView];
}

-(void)showControl{
    if(self.isControlshow == false){
        [self bringSubviewToFront:self.controlView];
        self.controlView.hidden = false;
        self.isControlshow = true;
    }
    else{
        self.controlView.hidden = true;
        self.isControlshow = false;
    }
}

-(void)showProgressView: (BOOL) show{
    if(show){
        self.progressView.hidden = false;
    }
    else{
        self.progressView.hidden = true;
    }
}

-(void)bufferempty: (float) speed{
    NSString *text = [NSString stringWithFormat:@"%0.2f KB/s", speed];
    [self.networkDisplay setText:text];
}


@end
