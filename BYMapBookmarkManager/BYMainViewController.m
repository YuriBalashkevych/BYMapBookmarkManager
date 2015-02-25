//
//  ViewController.m
//  BYMapBookmarkManager
//
//  Created by George on 11.02.15.
//  Copyright (c) 2015 George. All rights reserved.
//

#import "BYMainViewController.h"
#import "BYPlaceAnnotation.h"
#import "BYBookmarksTableViewController.h"
#import <WYPopoverController/WYPopoverController.h>
#import "BYBookmarkListTableViewController.h"
#import "BYDataManager.h"
#import "BYBookmarkLocation.h"
#import "BYDetailsBookmarkTableViewController.h"



@interface BYMainViewController () <MKMapViewDelegate, CLLocationManagerDelegate>

@property (strong, nonatomic) CLLocationManager*    locationManager;
@property (strong, nonatomic) WYPopoverController*  popover;
@property (strong, nonatomic) BYDataManager*        dataManager;

@end

@implementation BYMainViewController

#pragma mark - View Cycle

- (void)viewDidLoad {
    [super viewDidLoad];

    self.locationManager.delegate = self;
    
    [self.locationManager requestAlwaysAuthorization];
    [self.locationManager startUpdatingLocation];
    UILongPressGestureRecognizer* longTapRecognizer = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(actionAddBookmark:)];
    
    longTapRecognizer.numberOfTouchesRequired       = 1;
    longTapRecognizer.minimumPressDuration          = 0.5;
    longTapRecognizer.delaysTouchesBegan            = YES;
    
    [self.mapView addGestureRecognizer:longTapRecognizer];
    self.mapView.delegate                           = self;
    self.mapView.showsUserLocation                  = YES;
    
    [self.mapView setUserTrackingMode:MKUserTrackingModeFollow animated:YES];
    [self loadAnnotationsFromCoreData];
    
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Actions

- (void)actionAddBookmark:(UILongPressGestureRecognizer*)gesture {
    
    if (gesture.state == UIGestureRecognizerStateBegan) {
        CGPoint pointInView                 = [gesture locationInView:self.mapView];
        CLLocationCoordinate2D coordinate   = [self.mapView convertPoint:pointInView toCoordinateFromView:self.mapView];
        
        BYBookmarkLocation* newBookmark     = [self newBookmark:coordinate];
        BYPlaceAnnotation* newAnnotation    = [self newPlaceAnnotation:newBookmark];
        
        [self.mapView addAnnotation:newAnnotation];
        
        
        
    }
}

- (IBAction)actionShowBookmarkList:(UIBarButtonItem *)sender {
    
    
    if ([sender.title isEqualToString:@"Route"]) {
        BYBookmarksTableViewController* vc = [[BYBookmarksTableViewController alloc] initWithStyle:UITableViewStyleGrouped andCompletionBlock:^(NSArray *routes) {
            
            sender.title = @"Clear Route";
            for (MKRoute* route in routes) {
                MKPolyline* polyline = route.polyline;
                [self.mapView addOverlay:polyline level:MKOverlayLevelAboveRoads];
            }
            
            
        }];
        
        WYPopoverController* popover = [[WYPopoverController alloc] initWithContentViewController:vc];
        NSMutableArray* bookmarks = [NSMutableArray arrayWithArray:self.mapView.annotations];
        [bookmarks removeObject:self.mapView.userLocation];
        self.popover    = popover;
        vc.bookmarks    = bookmarks;
        vc.userLocation = self.mapView.userLocation;
        vc.delegate = self;
        vc.parentPopover = popover;
        [self.popover presentPopoverFromBarButtonItem:self.routeBarButton permittedArrowDirections:WYPopoverArrowDirectionAny animated:YES options:WYPopoverAnimationOptionFadeWithScale];
    
    } else if ([sender.title isEqualToString:@"Clear Route"]) {
        [self.mapView removeOverlays:self.mapView.overlays];
        sender.title = @"Route";
        
        NSArray *annotations = [self.mapView annotations];
        for (BYPlaceAnnotation *annotation in annotations)
        {
            [[self.mapView viewForAnnotation:annotation] setHidden:NO];
        }
    
    
    
    }
}

#pragma mark - <MKMapViewDelegate>

- (MKAnnotationView *)mapView:(MKMapView *)mapView viewForAnnotation:(id <MKAnnotation>)annotation {
    
    NSString* identifier = @"annotationIdentifier";
    MKPinAnnotationView* pin = (MKPinAnnotationView*)[mapView dequeueReusableAnnotationViewWithIdentifier:identifier];
    
    if ([annotation isKindOfClass:[MKUserLocation class]]) {
        return nil;
        
    } else if (!pin) {
        pin = [[MKPinAnnotationView alloc] initWithAnnotation:annotation reuseIdentifier:identifier];
    }
    pin.animatesDrop = YES;
    pin.draggable = YES;
    pin.canShowCallout = YES;
    
    UIButton* rightCalloutButton = [UIButton buttonWithType:UIButtonTypeDetailDisclosure];
    pin.rightCalloutAccessoryView = rightCalloutButton;
    return pin;
    
}

- (void)mapView:(MKMapView *)mapView didAddOverlayRenderers:(NSArray *)renderers {
    
    NSArray *annotations = [mapView annotations];
    BYPlaceAnnotation *annotation = nil;
    for (int i=0; i<[annotations count]; i++)
    {
        annotation = (BYPlaceAnnotation*)[annotations objectAtIndex:i];
        if (![self.destinationAnnotation isEqual:annotation] && ![annotation isKindOfClass:[MKUserLocation class]])
        {
            [[mapView viewForAnnotation:annotation] setHidden:YES];
        }
        else {
            [[mapView viewForAnnotation:annotation] setHidden:NO];
        }
    }

}

- (MKOverlayRenderer *)mapView:(MKMapView *)mapView rendererForOverlay:(id <MKOverlay>)overlay {
    
    
    if ([overlay isKindOfClass:[MKPolyline class]]) {
        MKPolylineRenderer* renderer    = [[MKPolylineRenderer alloc] initWithPolyline:overlay];
        renderer.strokeColor            = [UIColor redColor];
        renderer.lineWidth              = 6;
        renderer.lineCap                = kCGLineCapRound;
        
        return renderer;
    }
    
    return nil;
    
}


- (void)mapView:(MKMapView *)mapView annotationView:(MKAnnotationView *)view calloutAccessoryControlTapped:(UIControl *)control {
    
    BYDetailsBookmarkTableViewController* vc = [[BYDetailsBookmarkTableViewController alloc] initWithStyle:UITableViewStyleGrouped];
    vc.bookmark = view.annotation;
    [self.navigationController pushViewController:vc animated:YES];
  
}

#pragma mark - Segue

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    
    if ([segue.destinationViewController isKindOfClass:[BYBookmarkListTableViewController class]]) {
        
    }
    
}

#pragma mark - Private Methods

- (void)loadAnnotationsFromCoreData {
    
    NSFetchRequest* request = [[NSFetchRequest alloc] initWithEntityName:@"BYBookmarkLocation"];
    NSSortDescriptor* descriptor = [[NSSortDescriptor alloc] initWithKey:@"title" ascending:YES];
    [request setSortDescriptors:@[descriptor]];
    
    NSManagedObjectContext* moc = self.dataManager.managedObjectContext;
    NSArray* bookmarks = nil;
    NSError* error = nil;
    bookmarks = [moc executeFetchRequest:request error:&error];
    
    if (error) {
        NSLog(@"%@",[error localizedDescription]);

    } else {
        
        for (BYBookmarkLocation* bookmark in bookmarks) {
            BYPlaceAnnotation* placeAnnotation = [self newPlaceAnnotation:bookmark];
            [self.mapView addAnnotation:placeAnnotation];
        }
        
    }
    
}

- (BYBookmarkLocation*)newBookmark:(CLLocationCoordinate2D)coordinate {
    
    NSManagedObjectContext* moc = self.dataManager.managedObjectContext;
    BYBookmarkLocation* bookmark = [NSEntityDescription insertNewObjectForEntityForName:@"BYBookmarkLocation" inManagedObjectContext:moc];
    bookmark.location = [[CLLocation alloc] initWithLatitude:coordinate.latitude longitude:coordinate.longitude];
    bookmark.title = @"Unnamed";
    bookmark.subtitle = @"Unnamed";
    [self.dataManager saveContext];
    return bookmark;
    
}

- (BYPlaceAnnotation*)newPlaceAnnotation:(BYBookmarkLocation*)bookmark {
    
    CLLocation* location = bookmark.location;
    BYPlaceAnnotation* placeAnnotation  = [[BYPlaceAnnotation alloc] initWithCoordinate:location.coordinate];
    placeAnnotation.bookmark = bookmark;
    placeAnnotation.title = bookmark.title;
    placeAnnotation.subtitle = bookmark.subtitle;
    
    return placeAnnotation;
}


#pragma mark - Getters and Setters

- (CLLocationManager*)locationManager {
    if (!_locationManager) {
        _locationManager = [[CLLocationManager alloc] init];
    }
    return _locationManager;
}


- (BYDataManager*)dataManager {
    if (!_dataManager) {
        _dataManager = [BYDataManager sharedManager];
    }
    return _dataManager;
}

@end
















