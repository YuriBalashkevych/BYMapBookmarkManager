//
//  BYBookmarksTableViewController.m
//  BYMapBookmarkManager
//
//  Created by George on 20.02.15.
//  Copyright (c) 2015 George. All rights reserved.
//

#import "BYBookmarksTableViewController.h"
#import <WYPopoverController/WYPopoverController.h>
#import "BYMainViewController.h"

@interface BYBookmarksTableViewController ()

@property (copy, nonatomic) CompletionBlock     completion;
@property (strong, nonatomic) CLGeocoder*       geocoder;
@property (strong, nonatomic) NSOperationQueue* queue;


@end

@implementation BYBookmarksTableViewController


#pragma mark - Designated Iniializer

- (instancetype)initWithStyle:(UITableViewStyle)style andCompletionBlock:(CompletionBlock)completion {
    self = [super initWithStyle:style];
    if (self) {
        self.completion = completion;
    }
    return self;
}


#pragma mark - View Cycle

- (void)viewDidLoad {
    [super viewDidLoad];

    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - UITableViewDataSource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    // Return the number of sections.
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    // Return the number of rows in the section.
    return [self.bookmarks count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    static NSString* identifier = @"Cell";
    
    UITableViewCell* cell = [tableView dequeueReusableCellWithIdentifier:identifier];
    
    if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:identifier];
    }
    
    id <MKAnnotation> annotation = [self.bookmarks objectAtIndex:indexPath.row];
    cell.textLabel.text = [annotation title];
    cell.detailTextLabel.text = [annotation subtitle];
    
    return cell;
}


#pragma mark - UITableViewDelegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
    [tableView deselectRowAtIndexPath:indexPath animated:NO];
    
    [self actionDrawRouteInDelegate:[self.bookmarks objectAtIndex:indexPath.row]];
    
}


#pragma mark - Actions for delegate

- (void)actionDrawRouteInDelegate:(id <MKAnnotation>)bookmark {
    
    BYMainViewController* mainVC = self.delegate;
    mainVC.destinationAnnotation = bookmark;
    CLLocation* location = [[CLLocation alloc] initWithLatitude:bookmark.coordinate.latitude longitude:bookmark.coordinate.longitude];
    [self.geocoder reverseGeocodeLocation:location completionHandler:^(NSArray *placemarks, NSError *error) {
        
        if (error) {
            NSLog(@"%@",[error localizedDescription]);
        }
        
        MKDirectionsRequest* request = [[MKDirectionsRequest alloc] init];
        MKPlacemark* mkPlacemark = [[MKPlacemark alloc] initWithPlacemark:[placemarks firstObject]];
        MKMapItem* mapItemDestination = [[MKMapItem alloc] initWithPlacemark:mkPlacemark];
        [request setSource:[MKMapItem mapItemForCurrentLocation]];
        [request setDestination:mapItemDestination];
        MKDirections* directions = [[MKDirections alloc] initWithRequest:request];
        
        [directions calculateDirectionsWithCompletionHandler:^(MKDirectionsResponse *response, NSError *error) {
            
            if (error) {
                NSLog(@"%@",[error localizedDescription]);
            }
            
            if (self.completion) {
                self.completion(response.routes);
            }
            
            [self.parentPopover dismissPopoverAnimated:YES options:WYPopoverAnimationOptionFade];
            
        }];
    }];
    
}




#pragma mark - Getters and Setters

- (CLGeocoder*)geocoder {
    
    if (!_geocoder) {
        _geocoder = [[CLGeocoder alloc] init];
    }
    return _geocoder;
}

- (NSOperationQueue*)queue {
    if (!_queue) {
        _queue = [[NSOperationQueue alloc] init];
    }
    return _queue;
}



@end




















