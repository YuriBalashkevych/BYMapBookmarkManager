//
//  BYServerManager.h
//  BYMapBookmarkManager
//
//  Created by George on 23.02.15.
//  Copyright (c) 2015 George. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <AFNetworking/AFNetworking.h>

@interface BYServerManager : NSObject

@property (strong, nonatomic) AFHTTPRequestOperationManager* requestManager;


+ (BYServerManager*)sharedManager;


- (void)getVenuesWithParameters:(NSDictionary*)params onSuccess:(void(^)(NSArray* venues))success andFailure:(void(^)(NSError* error))failure;



@end
