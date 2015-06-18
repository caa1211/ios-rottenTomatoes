//
//  MoviesViewController.m
//  RottenTomatoes
//
//  Created by Carter Chang on 6/15/15.
//  Copyright (c) 2015 Carter Chang. All rights reserved.
//

#import "MoviesViewController.h"
#import "MovieCell.h"
#import "MovieGridCell.h"
#import <UIImageView+AFNetworking.h>
#import <SVProgressHUD.h>
#import <TSMessage.h>
#import "NIKFontAwesomeIconFactory.h"
#import "NIKFontAwesomeIconFactory+iOS.h"
#import "ViewController.h"

@interface MoviesViewController () <UITableViewDataSource, UITableViewDelegate, UISearchBarDelegate, UITabBarDelegate, UICollectionViewDelegate, UICollectionViewDataSource>
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (strong, nonatomic) NSMutableArray *movies;
@property (strong, nonatomic) NSMutableArray *allMovies;
@property (strong, nonatomic) NSMutableArray *filteredMovies;
@property (weak, nonatomic) IBOutlet UISearchBar *searchBar;
@property (strong, nonatomic) UIRefreshControl *refreshControl;
- (IBAction)onPan:(id)sender;
@property (weak, nonatomic) IBOutlet UITabBarItem *movieTab;
@property (weak, nonatomic) IBOutlet UITabBarItem *dvdTab;
@property (weak, nonatomic) IBOutlet UITabBar *tabBar;
@property (weak, nonatomic) IBOutlet UICollectionView *gridView;
@property (strong, nonatomic) UIBarButtonItem *switchModeBtn;
@end

@implementation MoviesViewController

Boolean isFilter;
typedef enum {
    MOVIE_MODE,
    DVD_MODE
} TabMode;

typedef enum {
    TableView,
    GridView
} ListMode;

TabMode displayMode = MOVIE_MODE;
ListMode listMode = TableView;
NIKFontAwesomeIconFactory *iocnFactory = nil;

- (void)viewDidLoad {
    [super viewDidLoad];

    iocnFactory = [NIKFontAwesomeIconFactory tabBarItemIconFactory];
    /*
    // Share Icon on Navigation Bar
    UIBarButtonItem *shareItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAction target:self action:@selector(shareAction)];
    */

    UIImage *tableModeIcon = [iocnFactory createImageForIcon:NIKFontAwesomeIconThList];
    self.switchModeBtn = [[UIBarButtonItem alloc] initWithImage:tableModeIcon style:UIBarButtonItemStyleDone target:self action:@selector(switchMode)];
    NSArray *actionButtonItems = @[self.switchModeBtn];
    self.navigationItem.rightBarButtonItems = actionButtonItems;

    // Customized navigation back button
    UIBarButtonItem *backButton = [[UIBarButtonItem alloc] initWithTitle:@"" style:UIBarButtonItemStyleDone target:nil action:nil];
    self.navigationItem.backBarButtonItem = backButton;
    
    self.tableView.dataSource = self;
    self.tableView.delegate = self;

    self.movieTab.image =  [iocnFactory createImageForIcon:NIKFontAwesomeIconFilm];
    self.dvdTab.image =  [iocnFactory createImageForIcon:NIKFontAwesomeIconCircleThin];
    [self.tabBar setSelectedItem:self.movieTab];
    
    [self initRefreshControl];
    [self setListMode:listMode];
    [self refreshData];
}

-(void) switchMode {
    ListMode newMode = 0;
    if (listMode == TableView){
        newMode = GridView;  
    }else if(listMode == GridView){
        newMode = TableView;
    }
    listMode=newMode;
    [self setListMode:listMode];
    
}

-(void) setListMode:(ListMode)listMode {
    if(listMode == TableView){
        [self.tableView setHidden:NO];
        [self.gridView setHidden:YES];
        
        self.switchModeBtn.image = [iocnFactory createImageForIcon:NIKFontAwesomeIconThLarge];
    }else if(listMode == GridView){
        [self.tableView setHidden:YES];
        [self.gridView setHidden:NO];
         self.switchModeBtn.image = [iocnFactory createImageForIcon:NIKFontAwesomeIconThList];
    }
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

-(NSURLRequest *) genApiRequest {
    // My Key: (Account Inactive)
    // NSString *url = @"http://api.rottentomatoes.com/api/public/v1.0/lists/movies/box_office.json?apikey=ekdwwnbkujx8padkhpqmfpdh&limit=20&country=us";
    
    NSString *dvdUrl = @"http://api.rottentomatoes.com/api/public/v1.0/lists/dvds/top_rentals.json?apikey=dagqdghwaq3e3mxyrp7kmmj5&limit=20&country=us";
    
    NSString *movieUrl = @"http://api.rottentomatoes.com/api/public/v1.0/lists/movies/box_office.json?apikey=dagqdghwaq3e3mxyrp7kmmj5&limit=20&country=us";
    
    NSURLRequest *request = nil;
    if(displayMode == MOVIE_MODE){
        request = [NSURLRequest requestWithURL:[NSURL URLWithString:movieUrl]
                                   cachePolicy:NSURLRequestReturnCacheDataElseLoad
                               timeoutInterval:3];
        
    }else if(displayMode == DVD_MODE){
        request = [NSURLRequest requestWithURL:[NSURL URLWithString:dvdUrl]
                                   cachePolicy:NSURLRequestReturnCacheDataElseLoad
                               timeoutInterval:3];
    }

    return request;
}

- (void)refreshData{
    
    //Exit search
    if (isFilter) {
        self.searchBar.text = @"";
        [self.view endEditing:YES];
        isFilter = NO;
    }
    
    NSURLRequest *request = [self genApiRequest];
    [SVProgressHUD showWithMaskType:SVProgressHUDMaskTypeBlack];
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
             
            //End the refreshing
             NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
             [formatter setDateFormat:@"MMM d, h:mm a"];
             NSString *title = [NSString stringWithFormat:@"Last update: %@", [formatter stringFromDate:[NSDate date]]];
             NSDictionary *attrsDictionary = [NSDictionary dictionaryWithObject:[UIColor whiteColor]
                                                                         forKey:NSForegroundColorAttributeName];
             NSAttributedString *attributedTitle = [[NSAttributedString alloc] initWithString:title attributes:attrsDictionary];
             self.refreshControl.attributedTitle = attributedTitle;
             [self.refreshControl endRefreshing];
             
             [self.tableView reloadData];
             [self.gridView reloadData];
         }
         [SVProgressHUD dismiss];
     }];
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
 //  [tableView deselectRowAtIndexPath:indexPath animated:YES];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.movies.count;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
   return self.movies.count;
}

-(void (^)(NSURLRequest *request, NSHTTPURLResponse *response, UIImage *image)) imgSuccess:(UIImageView*)imageView {
    return ^(NSURLRequest *request, NSHTTPURLResponse *response, UIImage *image) {
        imageView.image = image;
        
        CABasicAnimation *fade = [CABasicAnimation animationWithKeyPath:@"opacity"];
        fade.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut];
        fade.fromValue = [NSNumber numberWithFloat:0.0f];
        fade.toValue = [NSNumber numberWithFloat:1.0f];
        fade.duration = 0.5f;
        [imageView.layer addAnimation:fade forKey:@"fade"];
        
    };
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
     MovieGridCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"MyMovieGridCell" forIndexPath:indexPath];
    NSDictionary *movie = self.movies[indexPath.row];
    
    NSString *posterUrl = [movie valueForKeyPath:@"posters.thumbnail"];
    [cell.posterView setImageWithURLRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:posterUrl]
                                                             cachePolicy:NSURLRequestReturnCacheDataElseLoad
                                                         timeoutInterval:3]
                           placeholderImage:nil success:[self imgSuccess:cell.posterView] failure:nil];
    
//    // Circle Image Style
    cell.posterView.layer.cornerRadius = 20.0f;
    cell.posterView.clipsToBounds = YES;
    cell.posterView.layer.borderWidth = 2.0f;
    cell.posterView.layer.borderColor = CGColorRetain(UIColorFromRGB(0x1171a5).CGColor);
    
    cell.titleLabel.text = movie[@"title"];
    return cell;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    MovieCell *cell = [tableView dequeueReusableCellWithIdentifier:@"MyMovieCell" forIndexPath:indexPath];
    NSDictionary *movie = self.movies[indexPath.row];
    cell.titleLabel.text = movie[@"title"];
    cell.synopsisLabel.text = movie[@"synopsis"];
    NSString *posterUrl = [movie valueForKeyPath:@"posters.thumbnail"];
    [cell.posterView setImageWithURLRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:posterUrl]
                                                          cachePolicy:NSURLRequestReturnCacheDataElseLoad
                                                          timeoutInterval:3]
                           placeholderImage:nil success:[self imgSuccess:cell.posterView] failure:nil];
    
//    (void (^)(NSURLRequest *request, NSHTTPURLResponse *response, UIImage *image))success
//    ^(NSURLRequest *request, NSHTTPURLResponse *response, UIImage *image) {}
    
    
    [cell.synopsisLabel setHighlighted:YES];

// Circle Image Style
//cell.posterView.layer.cornerRadius = cell.posterView.frame.size.width / 2;
//cell.posterView.clipsToBounds = YES;
//cell.posterView.layer.borderWidth = 2.0f;
//cell.posterView.layer.borderColor = CGColorRetain([UIColor colorWithRed:1 green:1 blue:1 alpha:1.0].CGColor);
    
//cell.posterView.layer.cornerRadius = 10.0f;
//cell.posterView.clipsToBounds = YES;
//cell.posterView.layer.borderWidth = 2.0f;
//cell.posterView.layer.borderColor = CGColorRetain([UIColor colorWithRed:0.91 green:0.59 blue:0.16 alpha:1.0].CGColor);

    //Add shadow for poster image
    cell.posterView.layer.shadowOffset = CGSizeMake(2, 0);
    cell.posterView.layer.shadowColor = [[UIColor blackColor] CGColor];
    cell.posterView.layer.shadowRadius = 2;
    cell.posterView.layer.shadowOpacity = 0.5;
    
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
    
    if([sender isKindOfClass:[MovieCell class]]){
        MovieCell *mc = sender;
        NSIndexPath *indexPath = [self.tableView indexPathForCell:mc];
        NSDictionary *movie = self.movies[indexPath.row];
        destinationVC.movie = movie;
        destinationVC.placeholder = mc.posterView.image;
    }else if ([sender isKindOfClass:[MovieGridCell class]]){
        MovieGridCell *mc = sender;
        NSIndexPath *indexPath = [self.gridView indexPathForCell:mc];
        NSDictionary *movie = self.movies[indexPath.row];
        destinationVC.movie = movie;
        destinationVC.placeholder = mc.posterView.image;
    }
    
}

#pragma mark - Search

- (void) searchBar:(UISearchBar *)searchBar textDidChange:(NSString *)searchText{
    if (searchText.length == 0){
        if (isFilter) {
            self.movies = self.allMovies;
            [self.tableView reloadData];
            [self.gridView reloadData];
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
        [self.gridView reloadData];
    }
}

- (IBAction)onPan:(id)sender {
    [self.view endEditing:YES];
    
}

-(BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldRecognizeSimultaneouslyWithGestureRecognizer:(UIGestureRecognizer *)otherGestureRecognizer
{
    return YES;
}

#pragma mark - Tab Bar
- (void)tabBar:(UITabBar *)tabBar didSelectItem:(UITabBarItem *)item {
    if(item == self.dvdTab){
        displayMode = DVD_MODE;
    }else if (item == self.movieTab){
        displayMode = MOVIE_MODE;
    }

    [self refreshData];
}

@end
