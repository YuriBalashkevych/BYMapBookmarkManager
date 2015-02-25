//
//  BYBookmarkListTableViewController.m
//  BYMapBookmarkManager
//
//  Created by George on 21.02.15.
//  Copyright (c) 2015 George. All rights reserved.
//

#import "BYBookmarkListTableViewController.h"
#import <MapKit/MKAnnotation.h>
#import "BYMainViewController.h"
#import "BYDataManager.h"
#import "BYPlaceAnnotation.h"
#import "BYDetailsBookmarkTableViewController.h"

@interface BYBookmarkListTableViewController () <NSFetchedResultsControllerDelegate>

@property (strong, nonatomic) BYDataManager*                dataManager;
@property (strong, nonatomic) NSFetchedResultsController*   fetchResultController;

@end

@implementation BYBookmarkListTableViewController

#pragma mark - View Cycle

- (void)viewDidLoad {
    [super viewDidLoad];
    UIBarButtonItem* rightBarButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemEdit target:self action:@selector(actionEditBookmarkTable:)];
    self.navigationItem.rightBarButtonItem = rightBarButton;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    self.fetchResultController = nil;
    [self.tableView reloadData];

}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];

}

- (void)dealloc {
    
    
}

#pragma mark - UITableViewDataSource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {

    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {

    return [self.fetchResultController.fetchedObjects count];
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    static NSString* identifier = @"Cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:identifier];
    
    if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:identifier];
    }
    
    BYBookmarkLocation* bookmark = [self.fetchResultController objectAtIndexPath:indexPath];
    
    cell.textLabel.text = bookmark.title;
    cell.detailTextLabel.text = bookmark.subtitle;
    
    return cell;
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        NSManagedObjectContext* moc = self.dataManager.managedObjectContext;
        
        BYBookmarkLocation* bookmark = [self.fetchResultController objectAtIndexPath:indexPath];
        BYMainViewController* mainVC = [self.navigationController.viewControllers firstObject];
        NSArray* annotations = [mainVC.mapView annotations];
        
        for (id item in annotations) {
            if ([item isKindOfClass:[MKUserLocation class]]) {
                continue;
                
            } else if ([[item valueForKeyPath:@"bookmark"] isEqual:bookmark]) {
                [mainVC.mapView removeAnnotation:item];
            }
        }
        [moc deleteObject:bookmark];
        [self.dataManager saveContext];
    }
    
}


#pragma mark - UITableViewDelegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
}



#pragma mark - NSFetchedResultsControllerDelegate

- (void)controller:(NSFetchedResultsController *)controller didChangeObject:(id)anObject atIndexPath:(NSIndexPath *)indexPath forChangeType:(NSFetchedResultsChangeType)type newIndexPath:(NSIndexPath *)newIndexPath {
    if (type == NSFetchedResultsChangeDelete) {
        [self.tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationAutomatic];
    }
}


#pragma mark - Segues

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    
    if ([segue.destinationViewController isKindOfClass:[BYDetailsBookmarkTableViewController class]]) {
        
        BYDetailsBookmarkTableViewController* vc = segue.destinationViewController;
        NSIndexPath* indexPath = [self.tableView indexPathForCell:(UITableViewCell*)sender];
        BYBookmarkLocation* bookmark = [self.fetchResultController objectAtIndexPath:indexPath];
        BYMainViewController* mainVC = [self.navigationController.viewControllers firstObject];
        NSArray* annotations = [mainVC.mapView annotations];
        
        for (BYPlaceAnnotation* item in annotations) {
            if (![item isKindOfClass:[MKUserLocation class]]) {
                if ([item.bookmark isEqual:bookmark]) {
                    vc.bookmark = item;
                }
            }
        }
    }
    
}


#pragma mark - Actions

- (void)actionEditBookmarkTable:(UIBarButtonItem*)sender {
    
    if (sender.style == UIBarButtonItemStylePlain) {
        UIBarButtonItem* rigthBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone target:self action:@selector(actionEditBookmarkTable:)];
        self.navigationItem.rightBarButtonItem = rigthBarButtonItem;
        [self.tableView setEditing:YES animated:YES];
        
    } else if (sender.style == UIBarButtonItemStyleDone) {
        UIBarButtonItem* rigthBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemEdit target:self action:@selector(actionEditBookmarkTable:)];
        self.navigationItem.rightBarButtonItem = rigthBarButtonItem;
        [self.tableView setEditing:NO animated:YES];
        
    }
}

#pragma mark - Getters and Setters 

- (BYDataManager*)dataManager {
    if (!_dataManager) {
        _dataManager = [BYDataManager sharedManager];
    }
    return _dataManager;
}


- (NSFetchedResultsController*)fetchResultController {
    
    if (!_fetchResultController) {
        NSFetchRequest* request = [[NSFetchRequest alloc] initWithEntityName:@"BYBookmarkLocation"];
        NSSortDescriptor* descriptor = [[NSSortDescriptor alloc] initWithKey:@"title" ascending:YES];
        [request setSortDescriptors:@[descriptor]];
        NSManagedObjectContext* moc = self.dataManager.managedObjectContext;
        _fetchResultController = [[NSFetchedResultsController alloc] initWithFetchRequest:request managedObjectContext:moc sectionNameKeyPath:nil cacheName:nil];
        _fetchResultController.delegate = self;
        NSError* error = nil;
        [_fetchResultController performFetch:&error];
        
        if (error) {
            NSLog(@"%@",[error localizedDescription]);
        }
    }
    return _fetchResultController;
    
}


@end























