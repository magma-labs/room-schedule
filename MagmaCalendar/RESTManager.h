//
//  RESTManager.h
//  MagmaCalendar
//
//  Created by Omar Guzman on 2/9/16.
//  Copyright © 2016 Omar Guzman. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface RESTManager : NSObject
+(void)sendData:(NSMutableDictionary *)data toService:(NSString *)service withMethod:(NSString *)method toCallback:(void (^)(id))callback;
@end
