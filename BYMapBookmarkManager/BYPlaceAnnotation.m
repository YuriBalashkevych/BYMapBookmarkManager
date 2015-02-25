//
//  BYPlaceAnnotation.m
//  BYMapBookmarkManager
//
//  Created by George on 19.02.15.
//  Copyright (c) 2015 George. All rights reserved.
//

#import "BYPlaceAnnotation.h"

@implementation BYPlaceAnnotation

#pragma mark - Designated Initializer

- (instancetype)initWithCoordinate:(CLLocationCoordinate2D)coordinate {
    
    self = [super init];
    
    if (self) {
        self.coordinate = coordinate;
        [self addObserver:self forKeyPath:@"title" options:0 context:nil];
        [self addObserver:self forKeyPath:@"coordinate" options:0 context:nil];
        [self addObserver:self forKeyPath:@"subtitle" options:0 context:nil];
    }
    return self;
    
}

- (void)setCoordinate:(CLLocationCoordinate2D)newCoordinate {
    _coordinate = newCoordinate;
}

- (void)dealloc {
    [self removeObserver:self forKeyPath:@"title"];
    [self removeObserver:self forKeyPath:@"subtitle"];
    [self removeObserver:self forKeyPath:@"coordinate"];
}


#pragma mark - Observer

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context {
    
    if ([keyPath isEqualToString:@"title"]) {
        self.bookmark.title = self.title;
    } else if ([keyPath isEqualToString:@"subtitle"]) {
        self.bookmark.subtitle = self.subtitle;
    } else if ([keyPath isEqualToString:@"coordinate"]) {
        self.bookmark.location = [[CLLocation alloc] initWithLatitude:self.coordinate.latitude longitude:self.coordinate.longitude];
    }
    
}

#pragma mark - Getters and Setters

- (NSString*)title {
    
    if (!_title) {
        _title = @"Unnamed";
    }
    return _title;
}


- (NSString*)subtitle {
    if (!_subtitle) {
        _subtitle = @"Unnamed";
    }
    return _subtitle;
}



@end










