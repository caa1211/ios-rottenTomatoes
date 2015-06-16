//
//  MovieCell.m
//  RottenTomatoes
//
//  Created by Carter Chang on 6/15/15.
//  Copyright (c) 2015 Carter Chang. All rights reserved.
//

#import "MovieCell.h"

@implementation MovieCell

- (void)awakeFromNib {
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];
    //NSLog(@"%@",self.synopsisLabel.textColor );
    
    UIView *selectedView = [[UIView alloc] init];
    selectedView.backgroundColor = [UIColor colorWithRed:243/255.0
                                                      green:236/255.0
                                                       blue:253/255.0
                                                      alpha:0.5];
    self.selectedBackgroundView = selectedView;
    
    self.highlighted = selected;
}

- (void)setHighlighted:(BOOL)highlighted animated:(BOOL)animated{
    [super setHighlighted:highlighted animated:animated];
    
    if (highlighted) {
        self.synopsisLabel.textColor = [UIColor brownColor];
    } else {
        self.synopsisLabel.textColor = [UIColor colorWithRed:0.363376 green:0.360478 blue:0.363376 alpha:1.0];
    }
}

- (void)prepareForReuse {
    [super prepareForReuse];
    self.posterView.image = nil;
    
    // Fade in
//    CABasicAnimation *fade = [CABasicAnimation animationWithKeyPath:@"opacity"];
//    fade.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut];
//    fade.fromValue = [NSNumber numberWithFloat:0.0f];
//    fade.toValue = [NSNumber numberWithFloat:1.0f];
//    fade.duration = 0.5f;
//    [self.posterView.layer addAnimation:fade forKey:@"fade"];
    
}



@end
