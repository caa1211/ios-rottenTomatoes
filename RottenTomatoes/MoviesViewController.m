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
#import <SVProgressHUD.h>
#import <TSMessage.h>
#import "ViewController.h"

@interface MoviesViewController () <UITableViewDataSource, UITableViewDelegate, UISearchBarDelegate>
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (strong, nonatomic) NSMutableArray *movies;
@property (strong, nonatomic) NSMutableArray *allMovies;
@property (strong, nonatomic) NSMutableArray *filteredMovies;
@property (weak, nonatomic) IBOutlet UISearchBar *searchBar;
@property (strong, nonatomic) UIRefreshControl *refreshControl;
- (IBAction)onPan:(id)sender;

@end

@implementation MoviesViewController

Boolean isFilter;

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self initRefreshControl];
    
    self.tableView.dataSource = self;
    self.tableView.delegate = self;

    NSURLRequest *request = [self movieApiRequest];
    
    [SVProgressHUD showWithMaskType:SVProgressHUDMaskTypeBlack];
    // [SVProgressHUD show];
    [NSURLConnection sendAsynchronousRequest:request queue:[NSOperationQueue mainQueue] completionHandler:
     ^(NSURLResponse *response, NSData *data, NSError *connectionError) {
         if(connectionError){
             //[SVProgressHUD dismiss];
             [TSMessage showNotificationWithTitle:@"Newtork Error"
                                         subtitle:@"Please check your connection and try again later"
                                         type:TSMessageNotificationTypeWarning];
         }else{
             NSDictionary *dict = [NSJSONSerialization JSONObjectWithData:data options:0 error:nil];
             self.movies = dict[@"movies"];
             self.allMovies = self.movies;
             [self.tableView reloadData];
             //[SVProgressHUD showSuccessWithStatus:@"success"];
         }
         [SVProgressHUD dismiss];
     }];
}

- (void) initRefreshControl {
    self.refreshControl = [[UIRefreshControl alloc] init];
    self.refreshControl.backgroundColor = [UIColor colorWithRed:0.85 green:0.49 blue:0.47 alpha:1.0];
    self.refreshControl.tintColor = [UIColor whiteColor];
    [self.refreshControl addTarget:self
                         action: @selector(refreshData)
                         forControlEvents:UIControlEventValueChanged];
    
    [self.tableView insertSubview:self.refreshControl atIndex: 0];
}

-(NSURLRequest *) movieApiRequest {
    // My Key: (Account Inactive)
    // NSString *url = @"http://api.rottentomatoes.com/api/public/v1.0/lists/movies/box_office.json?apikey=ekdwwnbkujx8padkhpqmfpdh&limit=20&country=us";
    
    NSString *dvdUrl = @"http://api.rottentomatoes.com/api/public/v1.0/lists/dvds/top_rentals.json?apikey=dagqdghwaq3e3mxyrp7kmmj5&limit=20&country=us";
    
    NSString *url = @"http://api.rottentomatoes.com/api/public/v1.0/lists/movies/box_office.json?apikey=dagqdghwaq3e3mxyrp7kmmj5&limit=20&country=us";
    NSURLRequest *request = [NSURLRequest requestWithURL:[NSURL URLWithString:dvdUrl]
                                          cachePolicy:NSURLRequestReturnCacheDataElseLoad
                                          timeoutInterval:3];
    return request;
}

- (void)refreshData {
    NSURLRequest *request = [self movieApiRequest];
    
    [NSURLConnection sendAsynchronousRequest:request queue:[NSOperationQueue mainQueue] completionHandler:
     ^(NSURLResponse *response, NSData *data, NSError *connectionError) {
         if(connectionError){
             NSLog(@"refresh failed");
             [TSMessage showNotificationWithTitle:@"Newtork Error"
                                         subtitle:@"Please check your connection and try again later"
                                             type:TSMessageNotificationTypeWarning];
             [self.refreshControl endRefreshing];
         }else{
             NSLog(@"refresh success");
             NSDictionary *dict = [NSJSONSerialization JSONObjectWithData:data options:0 error:nil];
             self.movies = dict[@"movies"];
             self.allMovies = self.movies;
             [self.tableView reloadData];
             
            //End the refreshing
             NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
             [formatter setDateFormat:@"MMM d, h:mm a"];
             NSString *title = [NSString stringWithFormat:@"Last update: %@", [formatter stringFromDate:[NSDate date]]];
             NSDictionary *attrsDictionary = [NSDictionary dictionaryWithObject:[UIColor whiteColor]
                                                                         forKey:NSForegroundColorAttributeName];
             NSAttributedString *attributedTitle = [[NSAttributedString alloc] initWithString:title attributes:attrsDictionary];
             self.refreshControl.attributedTitle = attributedTitle;
             [self.refreshControl endRefreshing];
         }
     }];
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
 //  [tableView deselectRowAtIndexPath:indexPath animated:YES];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.movies.count;
}


-(void (^)(NSURLRequest *request, NSHTTPURLResponse *response, UIImage *image)) imgSuccess:(MovieCell*)movieCell {
    return ^(NSURLRequest *request, NSHTTPURLResponse *response, UIImage *image) {
        movieCell.posterView.image = image;
        
        CABasicAnimation *fade = [CABasicAnimation animationWithKeyPath:@"opacity"];
        fade.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut];
        fade.fromValue = [NSNumber numberWithFloat:0.0f];
        fade.toValue = [NSNumber numberWithFloat:1.0f];
        fade.duration = 0.5f;
        [movieCell.posterView.layer addAnimation:fade forKey:@"fade"];
        
    };
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    MovieCell *cell = [tableView dequeueReusableCellWithIdentifier:@"MyMovieCell" forIndexPath:indexPath];
    NSDictionary *movie = self.movies[indexPath.row];
    cell.titleLabel.text = movie[@"title"];
    cell.synopsisLabel.text = movie[@"synopsis"];
    NSString *posterUrl = [movie valueForKeyPath:@"posters.thumbnail"];
    [cell.posterView setImageWithURLRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:posterUrl]]
                           placeholderImage:nil success:[self imgSuccess:cell] failure:nil];
    
//    (void (^)(NSURLRequest *request, NSHTTPURLResponse *response, UIImage *image))success
//    ^(NSURLRequest *request, NSHTTPURLResponse *response, UIImage *image) {}
    
    
    [cell.synopsisLabel setHighlighted:YES];
    
//    cell.posterView.layer.cornerRadius = cell.posterView.frame.size.width / 2;
//    cell.posterView.clipsToBounds = YES;
//    cell.posterView.layer.borderWidth = 2.0f;
//    cell.posterView.layer.borderColor = CGColorRetain([UIColor colorWithRed:1 green:1 blue:1 alpha:1.0].CGColor);
    
//    cell.posterView.layer.cornerRadius = 10.0f;
      cell.posterView.clipsToBounds = YES;
//    cell.posterView.layer.borderWidth = 2.0f;
//    cell.posterView.layer.borderColor = CGColorRetain([UIColor colorWithRed:0.91 green:0.59 blue:0.16 alpha:1.0].CGColor);

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

#pragma mark - Search

- (void) searchBar:(UISearchBar *)searchBar textDidChange:(NSString *)searchText{
    if (searchText.length == 0){
        if (isFilter) {
            self.movies = self.allMovies;
            [self.tableView reloadData];
        }
        [self.view endEditing:YES];
        isFilter = NO;
    }else{
        isFilter = YES;
        self.filteredMovies = [[NSMutableArray alloc] init];
        for (NSDictionary *movie in self.allMovies) {
            // NSLog(@"%@", movie[@"title"]);
            NSString *movieTitle = movie[@"title"];
            NSRange movieTitleRange = [movieTitle rangeOfString:searchText options:NSCaseInsensitiveSearch];
            
            if (movieTitleRange.location != NSNotFound){
                [self.filteredMovies addObject:movie];
            }
        }
        
        self.movies  = self.filteredMovies;
        [self.tableView reloadData];
    }
}

- (IBAction)onPan:(id)sender {
    [self.view endEditing:YES];
    
}

-(BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldRecognizeSimultaneouslyWithGestureRecognizer:(UIGestureRecognizer *)otherGestureRecognizer
{
    return YES;
}

@end
