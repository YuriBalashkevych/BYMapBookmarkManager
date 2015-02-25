//
//  BYDataManager.h
//  BYMapBookmarkManager
//
//  Created by George on 19.02.15.
//  Copyright (c) 2015 George. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>


@interface BYDataManager : NSObject


@property (readonly, strong, nonatomic) NSManagedObjectContext *managedObjectContext;
@property (readonly, strong, nonatomic) NSManagedObjectModel *managedObjectModel;
@property (readonly, strong, nonatomic) NSPersistentStoreCoordinator *persistentStoreCoordinator;

+ (BYDataManager*)sharedManager;

- (void)saveContext;
- (NSURL *)applicationDocumentsDirectory;



@end
