//
//  MainViewController.h
//  MagmaCalendar
//
//  Created by Omar Guzman on 3/1/16.
//  Copyright © 2016 Omar Guzman. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <JASidePanelController.h>
#import "ViewController.h"
#import "RightMenuViewController.h"

@interface MainViewController : JASidePanelController
@property (nonatomic, strong) UIViewController * viewController;
@property (nonatomic, strong) UIViewController * rightMenuViewController;
@end
