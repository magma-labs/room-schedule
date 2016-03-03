//
//  RightMenuViewController.h
//  MagmaCalendar
//
//  Created by Omar Guzman on 3/1/16.
//  Copyright © 2016 Omar Guzman. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <JASidePanelController.h>


@interface RightMenuViewController : UIViewController <UIPickerViewDataSource, UIPickerViewDelegate>
@property (nonatomic, strong) NSMutableDictionary * dictRooms;
@property (nonatomic, strong) IBOutlet UIPickerView * pRooms;
@end
