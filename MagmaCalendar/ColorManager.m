//
//  ColorManager.m
//  MagmaCalendar
//
//  Created by Omar Guzman on 2/29/16.
//  Copyright © 2016 Omar Guzman. All rights reserved.
//

#import "ColorManager.h"

@implementation ColorManager
+(UIColor *)availableColor
{
    return [UIColor colorWithRed:149.0f/255.0f green:213.0f/255.0f blue:84.0f/255.0f alpha:1];
}

+(UIColor *)busyColor
{
    return [UIColor colorWithRed:240.0f/255.0f green:92.0f/255.0f blue:93.0f/255.0f alpha:1];
}

+(UIColor *)fontBusyColor
{
    return [UIColor colorWithRed:89.0f/255.0f green:2.0f/255.0f blue:12.0f/255.0f alpha:1];
}

+(UIColor *)fontBusyColorComingUp
{
    return [UIColor colorWithRed:89.0f/255.0f green:2.0f/255.0f blue:12.0f/255.0f alpha:.5f];
}

+(UIColor *)fontBusyColorLate
{
    return [UIColor colorWithRed:89.0f/255.0f green:2.0f/255.0f blue:12.0f/255.0f alpha:.3f];
}

+(UIColor *)fontAvailableColor
{
    return [UIColor colorWithRed:70.0f/255.0f green:93.0f/255.0f blue:46.0f/255.0f alpha:1];
}

+(UIColor *)fontAvailableColorComingUp
{
    return [UIColor colorWithRed:70.0f/255.0f green:93.0f/255.0f blue:46.0f/255.0f alpha:.5f];
}

+(UIColor *)fontAvailableColorLate
{
    return [UIColor colorWithRed:70.0f/255.0f green:93.0f/255.0f blue:46.0f alpha:.3f];
}

@end
