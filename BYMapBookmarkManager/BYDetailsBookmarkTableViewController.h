//
//  BYDetailsBookmarkTableViewController.h
//  BYMapBookmarkManager
//
//  Created by George on 21.02.15.
//  Copyright (c) 2015 George. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MapKit/MKAnnotation.h>
#import "BYPlaceAnnotation.h"

@interface BYDetailsBookmarkTableViewController : UITableViewController

@property (strong, nonatomic) BYPlaceAnnotation* bookmark;

@end
