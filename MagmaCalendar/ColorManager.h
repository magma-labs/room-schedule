//
//  ColorManager.h
//  MagmaCalendar
//
//  Created by Omar Guzman on 2/29/16.
//  Copyright © 2016 Omar Guzman. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@interface ColorManager : NSObject
+(UIColor*)availableColor;
+(UIColor*)busyColor;
+(UIColor*)fontAvailableColor;
+(UIColor*)fontAvailableColorComingUp;
+(UIColor*)fontAvailableColorLate;
+(UIColor*)fontBusyColor;
+(UIColor*)fontBusyColorComingUp;
+(UIColor*)fontBusyColorLate;
@end
