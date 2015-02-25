//
//  BYServerManager.m
//  BYMapBookmarkManager
//
//  Created by George on 23.02.15.
//  Copyright (c) 2015 George. All rights reserved.
//

#import "BYServerManager.h"
#import "BYPlaceAnnotation.h"
#import "BYDataManager.h"
#import "BYBookmarkLocation.h"

@interface BYServerManager ()

@property (strong, nonatomic) NSString* baseURLString;
@property (strong, nonatomic) BYDataManager* dataManager;

@end

@implementation BYServerManager


#pragma mark - Singleton Shared Manager

+ (BYServerManager*)sharedManager {
    
    static BYServerManager* manager = nil;
    
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        manager = [[BYServerManager alloc] init];
    });
    
    return manager;
    
}


#pragma mark - API requests

- (void)getVenuesWithParameters:(NSDictionary *)params onSuccess:(void (^)(NSArray *venues))success andFailure:(void (^)(NSError * error))failure {
    
        [self.requestManager GET:@"venues/search" parameters:params success:^(AFHTTPRequestOperation *operation, id responseObject) {
            
            NSArray* venues = [[responseObject valueForKey:@"response"] valueForKey:@"venues"];
            NSMutableArray* annotationVenues = [NSMutableArray array];
            
            for (NSDictionary* venue in venues) {
                NSString* lat = [[venue valueForKey:@"location"] valueForKey:@"lat"];
                NSString* lng = [[venue valueForKey:@"location"] valueForKey:@"lng"];
                
                CLLocationCoordinate2D coordinate = CLLocationCoordinate2DMake([lat floatValue], [lng floatValue]);
                //BYBookmarkLocation* bookmark = [self newBookmark:coordinate];
                BYPlaceAnnotation* annotation = [[BYPlaceAnnotation alloc] initWithCoordinate:coordinate];
                
                annotation.title = [[venue objectForKey:@"name"] copy];
                annotation.subtitle = [[[venue objectForKey:@"location"] objectForKey:@"address"] copy];
                
                NSLog(@"%@", annotation.title);
                NSLog(@"%@", annotation.subtitle);

                
                
                [annotationVenues addObject:annotation];
                
            }
            
            NSLog(@"%@",annotationVenues);
            
            if (success) {
                success(annotationVenues);
            }
            
        } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
            
            
            NSLog(@"%@",[error localizedDescription]);
            if (failure) {
                failure(error);
            }
        }];
    
}

#pragma mark - Private Methods

- (BYBookmarkLocation*)newBookmark:(CLLocationCoordinate2D)coordinate {
    
    NSManagedObjectContext* moc = self.dataManager.managedObjectContext;
    BYBookmarkLocation* bookmark = [NSEntityDescription insertNewObjectForEntityForName:@"BYBookmarkLocation" inManagedObjectContext:moc];
    bookmark.location = [[CLLocation alloc] initWithLatitude:coordinate.latitude longitude:coordinate.longitude];
    bookmark.title = @"Unnamed";
    bookmark.subtitle = @"Unnamed";
    return bookmark;
    
}

- (BYPlaceAnnotation*)newPlaceAnnotation:(BYBookmarkLocation*)bookmark {
    
    CLLocation* location = bookmark.location;
    BYPlaceAnnotation* placeAnnotation  = [[BYPlaceAnnotation alloc] initWithCoordinate:location.coordinate];
    placeAnnotation.bookmark = bookmark;
    
    return placeAnnotation;
}



#pragma mark - Getters and Setters

- (NSString*)baseURLString {
    
    if (!_baseURLString) {
        _baseURLString = @"https://api.foursquare.com/v2/";
    }
    
    return _baseURLString;
}

- (AFHTTPRequestOperationManager*)requestManager {
    if (!_requestManager) {
        _requestManager = [[AFHTTPRequestOperationManager alloc] initWithBaseURL:[NSURL URLWithString:self.baseURLString]];
    }
    return _requestManager;
}

- (BYDataManager*)dataManager {
    if (!_dataManager) {
        _dataManager = [BYDataManager sharedManager];
    }
    return _dataManager;
}


@end
















