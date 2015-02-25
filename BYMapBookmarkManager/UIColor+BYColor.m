//
//  UIColor+BYColor.m
//  BYMapBookmarkManager
//
//  Created by George on 24.02.15.
//  Copyright (c) 2015 George. All rights reserved.
//

#import "UIColor+BYColor.h"

@implementation UIColor (BYColor)

+ (UIColor *)colorFromHexString:(NSString *)hexString alpha:(float)alpha
{
    // Hex strings may optionally start with a #
    NSString *strippedString = [hexString stringByReplacingOccurrencesOfString:@"#" withString:@""];
    NSScanner *scanner = [NSScanner scannerWithString:strippedString];
    unsigned int rgbValue = 0;
    [scanner scanHexInt:&rgbValue];
    
    return [UIColor colorWithRed:((rgbValue & 0xFF0000) >> 16)/255.0 green:((rgbValue & 0xFF00) >> 8)/255.0 blue:(rgbValue & 0xFF)/255.0 alpha:alpha];
}

@end
