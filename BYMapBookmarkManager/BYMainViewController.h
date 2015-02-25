//
//  ViewController.h
//  BYMapBookmarkManager
//
//  Created by George on 11.02.15.
//  Copyright (c) 2015 George. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MapKit/MapKit.h>

@interface BYMainViewController : UIViewController

@property (weak, nonatomic) IBOutlet MKMapView*         mapView;
@property (weak, nonatomic) IBOutlet UIBarButtonItem*   routeBarButton;
@property (strong, nonatomic) id <MKAnnotation>     destinationAnnotation;


- (IBAction)actionShowBookmarkList:(UIBarButtonItem*)sender;

@end

