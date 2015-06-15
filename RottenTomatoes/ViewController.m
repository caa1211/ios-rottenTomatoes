//
//  ViewController.m
//  RottenTomatoes
//
//  Created by Carter Chang on 6/15/15.
//  Copyright (c) 2015 Carter Chang. All rights reserved.
//

#import "ViewController.h"
#import <UIImageView+AFNetworking.h>

@interface ViewController ()
@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.titleLabel.text = self.movie[@"title"];
    self.synopsisLabel.text = self.movie[@"synopsis"];
   [self.synopsisLabel sizeToFit];
    
    NSString *url = [self.movie valueForKeyPath:@"posters.detailed"];
    NSString *highResUrl = [self convertPosterUrlStringToHighRes:url];
    
    //NSLog(@"url: %@", highResUrl);
    [self.posterView setImageWithURL:[NSURL URLWithString:highResUrl]];
}

- (NSString *) convertPosterUrlStringToHighRes:(NSString *)urlString{
    NSRange range = [urlString rangeOfString: @".*cloudfront.net/" options:NSRegularExpressionSearch];
    NSString *returnValue = urlString;
    if (range.length > 0){
        returnValue = [urlString stringByReplacingCharactersInRange:range withString:@"https://content6.flixster.com/"];
    }
    return returnValue;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
