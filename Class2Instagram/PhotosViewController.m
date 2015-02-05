//
//  PhotosViewController.m
//  Class2Instagram
//
//  Created by AP Fritts on 2/4/15.
//  Copyright (c) 2015 AP Fritts. All rights reserved.
//

#import "PhotosViewController.h"
#import "PhotoCell.h"
#import "PhotoDetailsViewController.h"
#import <AFNetworking/UIImageView+AFNetworking.h>

@interface PhotosViewController () <UITableViewDelegate,UITableViewDataSource>

@property (nonatomic, strong) NSArray *media;
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (nonatomic, strong) UIRefreshControl *refreshControl;
@property (nonatomic, strong) UIActivityIndicatorView *loadingView;

@property (nonatomic, strong) NSURL *instaUrl;

@end

@implementation PhotosViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.refreshControl = [[UIRefreshControl alloc] init];
    [self.refreshControl addTarget:self action:@selector(loadTheData) forControlEvents:UIControlEventValueChanged];
    [self.tableView insertSubview:self.refreshControl atIndex:0];
    
    UIView *tableFooterView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 320, 50)];
    self.loadingView = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
    [self.loadingView startAnimating];
    self.loadingView.center = tableFooterView.center;
    [tableFooterView addSubview:self.loadingView];
    self.tableView.tableFooterView = tableFooterView;
    
    self.instaUrl = [NSURL URLWithString:@"https://api.instagram.com/v1/media/popular?client_id=14acd6ec00814300ac5fcf82566cc64a"];
    
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    self.tableView.rowHeight = 320;
    
    [self.tableView registerNib:[UINib nibWithNibName:@"PhotoCell" bundle:nil] forCellReuseIdentifier:@"PhotoCell"];
    
    [self loadTheData];
}

-(void)loadTheData {
    NSURLRequest *request = [[NSURLRequest alloc] initWithURL:self.instaUrl];
    [NSURLConnection sendAsynchronousRequest:request queue:[NSOperationQueue mainQueue] completionHandler:^(NSURLResponse *response, NSData *data, NSError *connectionError) {
        NSDictionary *instaData = [NSJSONSerialization JSONObjectWithData:data options:0 error:nil];
        self.media = instaData[@"data"];
        [self.tableView reloadData];
        [self.refreshControl endRefreshing];
        [self.loadingView stopAnimating];
    }];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    PhotoCell *cell = [self.tableView dequeueReusableCellWithIdentifier:@"PhotoCell" forIndexPath:indexPath];
    NSDictionary *post = self.media[indexPath.section];
    NSDictionary *images = post[@"images"];
    NSDictionary *thumbnail = images[@"thumbnail"];
    NSURL *url = [NSURL URLWithString:thumbnail[@"url"]];
    [cell.photoView setImageWithURL:url];

    if (self.media.count - 1 == indexPath.section) {
        [self loadMoreData];
    }
    
    return cell;
}

- (void) loadMoreData {
    [self.loadingView startAnimating];
    NSURLRequest *request = [[NSURLRequest alloc] initWithURL:self.instaUrl];
    [NSURLConnection sendAsynchronousRequest:request queue:[NSOperationQueue mainQueue] completionHandler:^(NSURLResponse *response, NSData *data, NSError *connectionError) {
        NSDictionary *newData = [NSJSONSerialization JSONObjectWithData:data options:0 error:nil];
        NSArray *newMedia = newData[@"data"];
        NSArray *nextMedia = [self.media arrayByAddingObjectsFromArray:newMedia];
        self.media = nextMedia;
        [self.tableView reloadData];
        [self.refreshControl endRefreshing];
        [self.loadingView stopAnimating];
    }];
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    UIView *header = [[UIView alloc] initWithFrame:CGRectMake(0, 0, [[UIScreen mainScreen]bounds].size.width, 50)];
    NSDictionary *post = self.media[section];
    NSDictionary *images = post[@"images"];
    NSDictionary *user = images[@"user"];
    NSURL *url = [NSURL URLWithString:user[@"profile_picture"]];
    
    UIImageView *image = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 50, 50)];
    [image setImageWithURL:url];
    
    UILabel *name = [[UILabel alloc] initWithFrame:CGRectMake(60, 10, 200, 30)];
    name.text = user[@"username"];
    
    [header addSubview:image];
    [header addSubview:name];
    
    return header;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    return 50;
}

- (NSInteger) tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return 1;
}

- (NSInteger) numberOfSectionsInTableView:(UITableView *)tableView {
    return self.media.count;
}

- (void) tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    PhotoDetailsViewController *pdvc = [[PhotoDetailsViewController alloc] init];
    pdvc.photo = self.media[indexPath.row];
    
    [self.navigationController pushViewController:pdvc animated:YES];
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
