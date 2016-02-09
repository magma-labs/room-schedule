//
//  RESTManager.m
//  MagmaCalendar
//
//  Created by Omar Guzman on 2/9/16.
//  Copyright © 2016 Omar Guzman. All rights reserved.
//

#import "RESTManager.h"

#define SERVER_URL @"https://gist.githubusercontent.com/softr8/6517688d4bbcf146238f/raw/33b831ad2dfe478e561908afd439f416568950a8"

@implementation RESTManager
+(void)sendData:(NSMutableDictionary *)data toService:(NSString *)service withMethod:(NSString *)method toCallback:(void (^)(id))callback
{
    /// Create an URL variable.
    NSURL *url = nil;
    /// Create a Request variable.
    NSMutableURLRequest *request;
    url = [NSURL URLWithString:[NSString stringWithFormat:@"%@/%@.json", SERVER_URL, service]];
    /// Set the request variable.
    request = [NSMutableURLRequest requestWithURL:url cachePolicy:NSURLRequestReloadIgnoringCacheData timeoutInterval:25];
    /// Set the request.
    [request setValue:@"text/html,application/xhtml+xml,application/xml" forHTTPHeaderField:@"Accept"];
    [request setValue:@"text/html,application/xhtml+xml,application/xml" forHTTPHeaderField:@"Content-Type"];
    [request setValue:@"text/html" forHTTPHeaderField:@"Data-Type"];
    /// Send the request.
    [NSURLConnection sendAsynchronousRequest:request queue:[NSOperationQueue mainQueue] completionHandler:^(NSURLResponse *response, NSData *data, NSError *error) {
        NSHTTPURLResponse *httpResponse = (NSHTTPURLResponse *)response;
        NSLog(@"httpResponse: %@", httpResponse);
        /// Check for the status of the response.
        if (httpResponse.statusCode == 204) {
            callback(@{@"success": @YES});
        }
        else if(!error && response != nil) {
            /// Create a dictionary based on the JSON of the response.
            NSDictionary *responseJson = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableContainers error:nil];
            if ([responseJson objectForKey:@"exception"]) {
                /// Set the dictionary with the values of the error message.
                NSMutableDictionary * dictErrorDetails = [NSMutableDictionary new];
                [dictErrorDetails setObject:@NO forKey:@"success"];
                NSString * strErr;
                strErr = @"Something went wrong, Please try in a while!";
                [dictErrorDetails setObject:strErr forKey:@"message"];
                callback(dictErrorDetails);
            } else {
                callback(responseJson);
            }
        } else {
            /// Check for the message error.
            if(error) {
                /// Set the dictionary with the values of the error message.
                NSMutableDictionary * dictErrorDetails = [NSMutableDictionary new];
                [dictErrorDetails setObject:@NO forKey:@"success"];
                NSString * strErr;
                if([error.userInfo objectForKey:@"NSLocalizedDescription"]) {
                    NSLog(@"%@",[error.userInfo objectForKey:@"NSLocalizedDescription"]);
                    strErr = [error.userInfo objectForKey:@"NSLocalizedDescription"];
                } else {
                    strErr = @"No Info Available!";
                }
                [dictErrorDetails setObject:[NSString stringWithFormat:@"%ld", (long)error.code] forKey:@"code"];
                [dictErrorDetails setObject:strErr forKey:@"message"];
                callback(dictErrorDetails);
            } else {
                callback(nil);
            }
        }
    }];
}
@end
