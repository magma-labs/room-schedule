//
//  MainViewController.m
//  MagmaCalendar
//
//  Created by Omar Guzman on 3/1/16.
//  Copyright © 2016 Omar Guzman. All rights reserved.
//

#import "MainViewController.h"

@interface MainViewController ()

@end

@implementation MainViewController
@synthesize viewController, rightMenuViewController;

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)awakeFromNib
{
    viewController = [self.storyboard instantiateViewControllerWithIdentifier:@"ViewController"];
    rightMenuViewController = [self.storyboard instantiateViewControllerWithIdentifier:@"RightMenuViewController"];    
    [self setCenterPanel:viewController];
    [self setRightPanel:rightMenuViewController];
    self.rightFixedWidth = 281.0f;
}

-(BOOL)prefersStatusBarHidden
{
    return YES;
}

-(void)stylePanel:(UIView *)panel
{
    panel.layer.cornerRadius = 0.0f;
    panel.clipsToBounds = YES;
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
