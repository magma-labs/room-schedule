//
//  ViewController.h
//  MagmaCalendar
//
//  Created by Omar Guzman on 2/5/16.
//  Copyright © 2016 Omar Guzman. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <GTMOAuth2ViewControllerTouch.h>
#import <GTLCalendar.h>
#import <GTLCalendarCalendarList.h>
#import <GTLQueryPlus.h>
#import <JGProgressHUD.h>
#import "RESTManager.h"

@interface ViewController : UIViewController <UIPickerViewDataSource, UIPickerViewDelegate>
@property (nonatomic, strong) GTLServiceCalendar *service;
@property (nonatomic, strong) IBOutlet UILabel * lblTimer;
@property (nonatomic, strong) IBOutlet UIView * viewBg;
@property (nonatomic, strong) IBOutlet UILabel * lblEvent;
@property (nonatomic, strong) IBOutlet UILabel * lblFrom;
@property (nonatomic, strong) IBOutlet UILabel * lblTo;
@property (nonatomic, strong) IBOutlet UITextView * txtDescription;
@property (nonatomic, strong) IBOutlet UIPickerView * pRooms;
@property (nonatomic, strong) NSMutableArray * arrEvents;
@property (nonatomic, strong) NSString * currentEvent;
@property (nonatomic, strong) JGProgressHUD * HUD;
@property (nonatomic, strong) NSString * currentRoom;
@property (nonatomic, strong) NSMutableDictionary * dictRooms;
@property (nonatomic, strong) NSMutableString * eventString;
@end

