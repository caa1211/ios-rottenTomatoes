//
//  MovieGridCell.m
//  RottenTomatoes
//
//  Created by Carter Chang on 6/18/15.
//  Copyright (c) 2015 Carter Chang. All rights reserved.
//

#import "MovieGridCell.h"

@implementation MovieGridCell


- (void)prepareForReuse {
    [super prepareForReuse];
    self.posterView.image = nil;
}

@end
