//
//  MoviesViewController.m
//  RottenTomatoes
//
//  Created by Carter Chang on 6/15/15.
//  Copyright (c) 2015 Carter Chang. All rights reserved.
//

#import "MoviesViewController.h"
#import "MovieCell.h"
#import <UIImageView+AFNetworking.h>
#import "ViewController.h"

@interface MoviesViewController () <UITableViewDataSource, UITableViewDelegate>
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (strong, nonatomic) NSArray *movies;
@end

@implementation MoviesViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.tableView.dataSource = self;
    self.tableView.delegate = self;
    //[self.tableView registerClass:[UITableViewCell class] forCellReuseIdentifier:@"MyMovieCell"];
    
    //RottenTomatoesURLString = "http://api.rottentomatoes.com/api/public/v1.0/lists/dvds/top_rentals.json?apikey=" +
    NSString *url = @"http://api.rottentomatoes.com/api/public/v1.0/lists/movies/box_office.json?apikey=dagqdghwaq3e3mxyrp7kmmj5&limit=20&country=us";
    
    //NSString *url = @"http://api.rottentomatoes.com/api/public/v1.0/lists/movies/box_office.json?apikey=ekdwwnbkujx8padkhpqmfpdh&limit=20&country=us";
    
    NSURLRequest *request = [NSURLRequest requestWithURL:[NSURL URLWithString:url]];
    [NSURLConnection sendAsynchronousRequest:request queue:[NSOperationQueue mainQueue] completionHandler:
     ^(NSURLResponse *response, NSData *data, NSError *connectionError) {
         NSDictionary *dict = [NSJSONSerialization JSONObjectWithData:data options:0 error:nil];
         self.movies = dict[@"movies"];
         [self.tableView reloadData];
     }];
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.movies.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    MovieCell *cell = [tableView dequeueReusableCellWithIdentifier:@"MyMovieCell" forIndexPath:indexPath];
    NSDictionary *movie = self.movies[indexPath.row];
    cell.titleLabel.text = movie[@"title"];
    cell.synopsisLabel.text = movie[@"synopsis"];
    NSString *posterUrl = [movie valueForKeyPath:@"posters.thumbnail"];
    [cell.posterView setImageWithURL:[NSURL URLWithString:posterUrl]];
    //NSLog(@"Row %ld", (long)indexPath.row);
    return cell;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    ViewController *destinationVC = segue.destinationViewController;
    MovieCell *mc = sender;
    NSIndexPath *indexPath = [self.tableView indexPathForCell:mc];
    NSDictionary *movie = self.movies[indexPath.row];
    destinationVC.movie = movie;
    destinationVC.placeholder = mc.posterView.image; 
}


@end
