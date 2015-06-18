//
//  MovieGridCell.h
//  RottenTomatoes
//
//  Created by Carter Chang on 6/18/15.
//  Copyright (c) 2015 Carter Chang. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface MovieGridCell : UICollectionViewCell
@property (weak, nonatomic) IBOutlet UIImageView *posterView;
@property (weak, nonatomic) IBOutlet UILabel *titleLabel;

@end
