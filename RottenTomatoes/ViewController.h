//
//  ViewController.h
//  RottenTomatoes
//
//  Created by Carter Chang on 6/15/15.
//  Copyright (c) 2015 Carter Chang. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ViewController : UIViewController
@property (weak, nonatomic) IBOutlet UIImageView *posterView;
@property (strong, nonatomic) IBOutlet UILabel *titleLabel;
@property (strong, nonatomic) IBOutlet UILabel *synopsisLabel;

@property (weak, nonatomic) IBOutlet UIScrollView *infoView;
@property (strong, nonatomic) NSDictionary *movie;
@property (strong, nonatomic) UIImage *placeholder;
@property (weak, nonatomic) IBOutlet UINavigationItem *navigationTitle;

@end

