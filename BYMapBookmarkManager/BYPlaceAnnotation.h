//
//  BYPlaceAnnotation.h
//  BYMapBookmarkManager
//
//  Created by George on 19.02.15.
//  Copyright (c) 2015 George. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <MapKit/MKAnnotation.h>
#import "BYBookmarkLocation.h"

@interface BYPlaceAnnotation : NSObject <MKAnnotation>

@property (nonatomic, readonly) CLLocationCoordinate2D coordinate;

@property (nonatomic, copy) NSString *title;
@property (nonatomic, copy) NSString *subtitle;
@property (nonatomic, strong) BYBookmarkLocation* bookmark;

- (void)setCoordinate:(CLLocationCoordinate2D)newCoordinate;

- (instancetype)initWithCoordinate:(CLLocationCoordinate2D)coordinate;

@end
