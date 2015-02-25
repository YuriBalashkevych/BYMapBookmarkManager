//
//  BYDetailsBookmarkTableViewController.m
//  BYMapBookmarkManager
//
//  Created by George on 21.02.15.
//  Copyright (c) 2015 George. All rights reserved.
//

#import "BYDetailsBookmarkTableViewController.h"
#import "BYServerManager.h"
#import "BYDataManager.h"
#import "BYMainViewController.h"

@interface BYDetailsBookmarkTableViewController ()

@property (assign, nonatomic) NSUInteger        numberOfRows;
@property (strong, nonatomic) UIButton*         loadPlacesButton;
@property (strong, nonatomic) UIButton*         centerBookmarkOnMapViewButton;
@property (strong, nonatomic) UIButton*         routeToBookmarkButton;
@property (strong, nonatomic) BYServerManager*  serverManager;
@property (strong, nonatomic) NSArray*          venues;
@property (strong, nonatomic) NSDictionary*     parameters;
@property (strong, nonatomic) BYDataManager*    dataManager;
@property (strong, nonatomic) CLGeocoder*       geocoder;



@end

@implementation BYDetailsBookmarkTableViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    if ([self.bookmark.title isEqualToString:@"Unnamed"]) {
        [self actionLoadNearbyPlaces:self.loadPlacesButton];
    }
    
    UIBarButtonItem* trashBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemTrash target:self action:@selector(actionDeleteBookmark:)];
    self.navigationItem.rightBarButtonItem = trashBarButtonItem;

}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    
    
    
    }

#pragma mark - UITableViewDataSource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {

    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {

    return self.numberOfRows + [self.venues count];
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    static NSString* identifier = @"Cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:identifier];
    
    if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:identifier];
    }
    
    if (indexPath.row == 0) {
        cell.textLabel.text = self.bookmark.title;
        cell.detailTextLabel.text = self.bookmark.subtitle;
        
    } else if (indexPath.row == 1) {
        
        [cell.contentView addSubview:self.loadPlacesButton];

    } else if (indexPath.row == 2) {
        
        [cell.contentView addSubview:self.centerBookmarkOnMapViewButton];
        
    } else if (indexPath.row == 3) {
        
        [cell.contentView addSubview:self.routeToBookmarkButton];

        
    } else if (indexPath.row >= 4) {
        
        cell.textLabel.text = [[self.venues objectAtIndex:indexPath.row - self.numberOfRows] title];
        cell.detailTextLabel.text = [[self.venues objectAtIndex:indexPath.row - self.numberOfRows] subtitle];
        
    }

    
    return cell;
}

#pragma mark - UITableViewDelegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {

    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    if (indexPath.row >= 2) {
        
        UITableViewCell* firstCell = [tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0]];
        UITableViewCell* selectedCell = [tableView cellForRowAtIndexPath:indexPath];
        
        firstCell.textLabel.text = selectedCell.textLabel.text;
        firstCell.detailTextLabel.text = selectedCell.detailTextLabel.text;
        
        self.bookmark.title = [[self.venues objectAtIndex:indexPath.row - 2] title];
        self.bookmark.subtitle = [[self.venues objectAtIndex:indexPath.row - 2] subtitle];
        [self.bookmark setCoordinate:[[self.venues objectAtIndex:indexPath.row - 2] coordinate]];
        [self.dataManager saveContext];
        [tableView reloadData];
    }
    
}


#pragma mark - Actions

- (void)actionLoadNearbyPlaces:(UIButton*)sender {
    
    [self getVenues];
    [sender setHidden:YES];
    
}

- (void)actionRouteTo:(UIButton*)sender {
    
    [self drawRoute:self.bookmark];
    
}

- (void)actionCenterBookmark:(UIButton*)sender {
    
    BYMainViewController* mainVC = [self.navigationController.viewControllers firstObject];
    
    [mainVC.mapView setCenterCoordinate:self.bookmark.coordinate animated:YES];
    
    [self.navigationController popToRootViewControllerAnimated:YES];
    
}

- (void)actionDeleteBookmark:(UIBarButtonItem*)sender {
    
    UIAlertController* ac = [UIAlertController alertControllerWithTitle:nil message:@"Are you sure?" preferredStyle:UIAlertControllerStyleActionSheet];
    UIAlertAction* alertAction = [UIAlertAction actionWithTitle:@"Delete" style:UIAlertActionStyleDestructive handler:^(UIAlertAction *action) {
        
        BYPlaceAnnotation* annotation = self.bookmark;
        BYBookmarkLocation* bookmarkObject = self.bookmark.bookmark;
        
        BYMainViewController* mainVC = [self.navigationController.viewControllers firstObject];
        [self.dataManager.managedObjectContext deleteObject:bookmarkObject];
        [self.dataManager saveContext];
        [mainVC.mapView removeAnnotation:annotation];
        [self.navigationController popToRootViewControllerAnimated:YES];
        
    }];
    
    [ac addAction:alertAction];
    [self presentViewController:ac animated:YES completion:nil];
    
}


#pragma mark - Private Methods

- (void)getVenues {
    
    [self.serverManager getVenuesWithParameters:self.parameters onSuccess:^(NSArray *venues) {
        self.venues = venues;
        [self.tableView reloadData];


    } andFailure:nil];
    
}

- (void)drawRoute:(id <MKAnnotation>)bookmark {
    
    BYMainViewController* mainVC = [self.navigationController.viewControllers firstObject];;
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
            mainVC.navigationItem.leftBarButtonItem.title = @"Clear Route";
            NSArray* routes = response.routes;
            for (MKRoute* route in routes) {
                MKPolyline* polyline = route.polyline;
                [mainVC.mapView addOverlay:polyline level:MKOverlayLevelAboveRoads];
            }
            
            [self.navigationController popToRootViewControllerAnimated:YES];
            
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

- (NSUInteger)numberOfRows {
    if (!_numberOfRows) {
        _numberOfRows = 4;
    }
    return _numberOfRows;
}


- (UIButton*)loadPlacesButton {
    
    if (!_loadPlacesButton) {
        
        _loadPlacesButton = [UIButton buttonWithType:UIButtonTypeSystem];
        [_loadPlacesButton setFrame:CGRectMake(50, 10, 200, 20)];
        [_loadPlacesButton setTitle:@"Load Nearby Places" forState:UIControlStateNormal];
        [_loadPlacesButton addTarget:self action:@selector(actionLoadNearbyPlaces:) forControlEvents:UIControlEventTouchUpInside];
        
    }
    return _loadPlacesButton;
}

- (UIButton*)routeToBookmarkButton {
    
    if (!_routeToBookmarkButton) {
        
        _routeToBookmarkButton = [UIButton buttonWithType:UIButtonTypeSystem];
        [_routeToBookmarkButton setFrame:CGRectMake(50, 10, 200, 20)];
        [_routeToBookmarkButton setTitle:@"Route to from current loc. " forState:UIControlStateNormal];
        [_routeToBookmarkButton addTarget:self action:@selector(actionRouteTo:) forControlEvents:UIControlEventTouchUpInside];
        
    }
    return _routeToBookmarkButton;
}

- (UIButton*)centerBookmarkOnMapViewButton {
    
    if (!_centerBookmarkOnMapViewButton) {
        
        _centerBookmarkOnMapViewButton = [UIButton buttonWithType:UIButtonTypeSystem];
        [_centerBookmarkOnMapViewButton setFrame:CGRectMake(50, 10, 200, 20)];
        [_centerBookmarkOnMapViewButton setTitle:@"Center On Map View" forState:UIControlStateNormal];
        [_centerBookmarkOnMapViewButton addTarget:self action:@selector(actionCenterBookmark:) forControlEvents:UIControlEventTouchUpInside];
        
    }
    return _centerBookmarkOnMapViewButton;
}

- (BYServerManager*)serverManager {
    if (!_serverManager) {
        _serverManager = [BYServerManager sharedManager];
    }
    return _serverManager;
}

- (NSDictionary*)parameters {
    if (!_parameters) {
        NSString* pair = [NSString stringWithFormat:@"%f,%f",self.bookmark.coordinate.latitude,self.bookmark.coordinate.longitude];
        _parameters = @{@"client_id":@"B43SFXRU34NWDGTL3S01YI0HXDEUM45BLYCSU5XJ4X3ELC44",
                        @"client_secret":@"PW53HCIVNOWJDA3NG0PV3TGBP2NMCTIKSHAJLCB2OKZNRRIB",
                        @"ll":pair,
                        @"v":@"20140806",
                        @"m":@"foursquare",
                        @"limit":@"10"};
    }
    return _parameters;
}

- (BYDataManager*)dataManager {
    if (!_dataManager) {
        _dataManager = [BYDataManager sharedManager];
    }
    return _dataManager;
}

@end



















