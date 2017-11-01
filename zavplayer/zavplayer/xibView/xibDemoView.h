//
//  xibDemoView.h
//  zavplayer
//
//  Created by 朱鹏飞 on 2017/10/27.
//  Copyright © 2017年 zhupengfei. All rights reserved.
//

#import <UIKit/UIKit.h>

enum outletTagInfo{
    clickPlayingTag
};

@interface xibDemoView : UIView

+ (instancetype)loadFromNib;

-(void)setButtonIcon;
@property (strong, nonatomic) IBOutlet UIView *controlView;
@property (strong, nonatomic) IBOutlet UILabel *playedTime;
@property (strong, nonatomic) IBOutlet UILabel *totalTime;
@property (strong, nonatomic) IBOutlet UISlider *progressSlider;
@property (strong, nonatomic) IBOutlet UIButton *playButt;

@end
