//
//  Utils.m
//  InitialDesign
//
//  Created by Basem Elazzabi on 2/23/14.
//  Copyright (c) 2014 Capstone Team B. All rights reserved.
//

#import "Utils.h"

@implementation Utils

+ (UIImage*)scaleAndPreserveRatioForImage:(UIImage*)image
                      toWidth:(float)width andHeight:(float) height;
{
    float actualHeight = image.size.height;
    float actualWidth = image.size.width;

    if(actualWidth > actualHeight){
        actualHeight = actualHeight * width / actualWidth;
        actualWidth = width;
    }
    else{
        actualWidth = actualWidth * height / actualHeight;
        actualHeight = height;
    }
    
    CGRect rect = CGRectMake(0.0, 0.0, actualWidth, actualHeight);
    UIGraphicsBeginImageContext(rect.size);
    [image drawInRect:rect];
    UIImage *img = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
                    
    return img;
}


@end
