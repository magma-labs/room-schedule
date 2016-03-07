//
//  RightMenuViewController.m
//  MagmaCalendar
//
//  Created by Omar Guzman on 3/1/16.
//  Copyright © 2016 Omar Guzman. All rights reserved.
//

#import "RightMenuViewController.h"

@interface RightMenuViewController ()

@end

@implementation RightMenuViewController
@synthesize pRooms, dictRooms;

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    dispatch_async(dispatch_get_main_queue(), ^{
        NSUserDefaults * defaults = [NSUserDefaults standardUserDefaults];
        if([defaults objectForKey:@"dictRooms"])
        {
            [pRooms setDelegate:self];
            [pRooms setDataSource:self];
            dictRooms = [defaults objectForKey:@"dictRooms"];
            [pRooms reloadAllComponents];
        }
    });
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


- (UIView *)pickerView:(UIPickerView *)pickerView viewForRow:(NSInteger)row forComponent:(NSInteger)component reusingView:(UIView *)view{
    UILabel* tView = (UILabel*)view;
    if (!tView){
        tView = [[UILabel alloc] init];
        [tView setFont:[UIFont fontWithName:@"Lato-Regular" size:24]];
        tView.textColor = [UIColor whiteColor];
        [tView setTextAlignment:NSTextAlignmentCenter];
    }
    // Fill the label text here
    NSArray * arrKeys = dictRooms.allKeys;
    NSString * strTitle = [arrKeys objectAtIndex:row];
    [tView setText:strTitle];
    [[pickerView.subviews objectAtIndex:1] setBackgroundColor:[UIColor whiteColor]];
    [[pickerView.subviews objectAtIndex:2] setBackgroundColor:[UIColor whiteColor]];
    return tView;
}

-(NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component
{
    return [dictRooms count];
}

-(NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView
{
    return 1;
}

-(void)pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component
{
    NSString * strRoom = [NSString stringWithFormat:@"%ld", (long)row];
    [((JASidePanelController*)self.parentViewController) showCenterPanelAnimated:YES];
    [[NSNotificationCenter defaultCenter] postNotificationName:@"calendarOptionDidChange" object:strRoom];
}


-(void)doLogout:(id)sender
{
    [((JASidePanelController*)self.parentViewController) showCenterPanelAnimated:YES];
    [[NSNotificationCenter defaultCenter] postNotificationName:@"userDidLogout" object:nil];
}
/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
