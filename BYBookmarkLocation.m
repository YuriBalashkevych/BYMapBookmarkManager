//
//  BYMapBookmarkManager.m
//  BYMapBookmarkManager
//
//  Created by George on 22.02.15.
//  Copyright (c) 2015 George. All rights reserved.
//

#import "BYBookmarkLocation.h"

@implementation BYBookmarkLocation

@dynamic location;
@dynamic subtitle;
@dynamic title;

@end


@implementation BYLocation

+ (Class)transformedValueClass {
    return [CLLocation class];
}

+ (BOOL)allowsReverseTransformation {
    return YES;
}

- (id)transformedValue:(id)value {
    return [NSKeyedArchiver archivedDataWithRootObject:value];
}

- (id)reverseTransformedValue:(id)value {
    return [NSKeyedUnarchiver unarchiveObjectWithData:value];
}

@end