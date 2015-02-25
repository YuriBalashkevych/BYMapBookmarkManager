//
//  BYMapBookmarkManager.h
//  BYMapBookmarkManager
//
//  Created by George on 22.02.15.
//  Copyright (c) 2015 George. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>
#import <MapKit/MapKit.h>


@interface BYBookmarkLocation : NSManagedObject

@property (nonatomic, retain) id       location;
@property (nonatomic, copy) NSString * subtitle;
@property (nonatomic, copy) NSString * title;

@end


@interface BYLocation : NSValueTransformer

@end