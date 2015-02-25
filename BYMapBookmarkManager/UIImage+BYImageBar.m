//
//  UIImage+BYImageBar.m
//  BYMapBookmarkManager
//
//  Created by George on 24.02.15.
//  Copyright (c) 2015 George. All rights reserved.
//

#import "UIImage+BYImageBar.h"

@implementation UIImage (BYImageBar)

+ (UIImage *)imageWithColor:(UIColor *)color
{
    CGRect rect = CGRectMake(0.0f, 0.0f, 1.0f, 1.0f);
    UIGraphicsBeginImageContext(rect.size);
    CGContextRef context = UIGraphicsGetCurrentContext();
    
    CGContextSetFillColorWithColor(context, [color CGColor]);
    CGContextFillRect(context, rect);
    
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    return image;
}

@end
