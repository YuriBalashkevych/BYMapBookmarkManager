//
//  BYBookmarksTableViewController.h
//  BYMapBookmarkManager
//
//  Created by George on 20.02.15.
//  Copyright (c) 2015 George. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MapKit/MKAnnotation.h>
#import "BYMainViewController.h"

@class WYPopoverController;

typedef void(^CompletionBlock)(NSArray* routes);

@interface BYBookmarksTableViewController : UITableViewController

@property (strong, nonatomic) NSArray*              bookmarks;
@property (strong, nonatomic) MKUserLocation*       userLocation;
@property (strong, nonatomic) WYPopoverController*  parentPopover;
@property (weak, nonatomic)   id                    delegate;

- (instancetype)initWithStyle:(UITableViewStyle)style andCompletionBlock:(CompletionBlock)completion;

@end
