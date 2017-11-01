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
}

- (IBAction)clickPlay:(id)sender {
    
}

- (IBAction)clickSeek:(id)sender {
    
}

-(void)initSlider{
    [self.progressSlider setValue:0.0f];
    
    //TODO
    [self.progressSlider setMaximumValue:0];
}

-(void)updateProgress{
    
}

-(void)setButtonIcon{
    [self.playButt setImage:[UIImage imageNamed:@"play"] forState:UIControlStateNormal];
}

@end
