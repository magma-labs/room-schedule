//
//  ViewController.m
//  MagmaCalendar
//
//  Created by Omar Guzman on 2/5/16.
//  Copyright © 2016 Omar Guzman. All rights reserved.
//

#import "ViewController.h"
#import "ColorManager.h"

static NSString *const kKeychainItemName = @"Google Calendar API";
static NSString *const kClientID = @"769354150819-pll3a1p7c9i3o5l682b6stullgr815fv.apps.googleusercontent.com";

@implementation ViewController

@synthesize service = _service;
@synthesize lblTimer, viewBg, arrEvents, currentEvent, lblEvent, HUD, currentRoom, dictRooms, lblCurrentRoom, isThereEvent, lblCurrentEventTitle, lblFromTo, imgClockNow, currentNextEvent, currentPrevEvent, currentLateEvent, lblCommingUpNext, lblLateToday, lblPreviousEvent, lblCommingUpNextEventTime, lblLateTodayEventTime, imgCommingUpClock, imgLateClock, viewCommingLate;

// When the view loads, create necessary subviews, and initialize the Google Calendar API service.
- (void)viewDidLoad {
    [super viewDidLoad];
    
    // Initialize the Google Calendar API service & load existing credentials from the keychain if available.
    self.service = [[GTLServiceCalendar alloc] init];
    self.service.authorizer = [GTMOAuth2ViewControllerTouch authForGoogleFromKeychainForName:kKeychainItemName clientID:kClientID clientSecret:nil];
    HUD = [JGProgressHUD progressHUDWithStyle:JGProgressHUDStyleLight];
    HUD.textLabel.text = @"Loading Calendars...";
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(calendarOptionDidChange:) name:@"calendarOptionDidChange" object:nil];
}

-(void)calendarOptionDidChange:(NSNotification*)notification
{
    NSLog(@"notification... %@", notification.object);
    //NSInteger * row = (NSInteger*)[notification.object integerValue];
    int row = [notification.object intValue];
    HUD.textLabel.text = @"Loading Events...";
    [HUD showInView:self.viewBg];
    NSArray * allKeys = dictRooms.allKeys;
    currentRoom = [dictRooms objectForKey:[allKeys objectAtIndex:row]];
    NSString * strRoom = [allKeys objectAtIndex:row];
    lblCurrentRoom.text = [NSString stringWithFormat:@"%@ %@", strRoom, ([strRoom isEqual:@"Personal"])?@"Calendar":@"Room"];
    lblLateTodayEventTime.text = lblLateToday.text = lblPreviousEvent.text = lblCommingUpNextEventTime.text = lblCommingUpNext.text = @"";
    dispatch_async(dispatch_get_main_queue(), ^{
        currentLateEvent = currentNextEvent = currentPrevEvent = nil;
        lblLateToday.hidden = lblLateTodayEventTime.hidden = lblPreviousEvent.hidden = lblCommingUpNext.hidden = lblCommingUpNextEventTime.hidden = imgCommingUpClock.hidden = imgLateClock.hidden = imgClockNow.hidden = viewCommingLate.hidden = YES;
        [self queryTodaysEvents];
    });
}

// When the view appears, ensure that the Google Calendar API service is authorized, and perform API calls.
- (void)viewDidAppear:(BOOL)animated {
    lblLateToday.hidden = lblLateTodayEventTime.hidden = lblPreviousEvent.hidden = lblCommingUpNext.hidden = lblCommingUpNextEventTime.hidden = imgCommingUpClock.hidden = imgLateClock.hidden = imgClockNow.hidden = viewCommingLate.hidden = YES;
    if (!self.service.authorizer.canAuthorize) {
        // Not yet authorized, request authorization by pushing the login UI onto the UI stack.
        [self presentViewController:[self createAuthController] animated:YES completion:nil];
    } else {
        [self loadCalendars];
    }
}

-(void)loadCalendars
{
    [HUD showInView:self.view];
    [RESTManager sendData:nil toService:@"rooms" withMethod:@"GET" toCallback:^(id result) {
        if(result)
        {
            dictRooms = [NSMutableDictionary new];
            dictRooms = result;
            [dictRooms setObject:@"primary" forKey:@"Personal"];
            NSArray * allKeys = dictRooms.allKeys;
            currentRoom = [dictRooms objectForKey:[allKeys objectAtIndex:0]];
            NSString * strRoom = [allKeys objectAtIndex:0];
            lblCurrentRoom.text = [NSString stringWithFormat:@"%@ Room", strRoom];
            NSUserDefaults * defaults = [NSUserDefaults standardUserDefaults];
            [defaults setObject:dictRooms forKey:@"dictRooms"];
            [defaults synchronize];
            [self startLoadingCurrentCalendarInfo];
        }
    }];
}

-(NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component
{
    return [dictRooms count];
}

-(NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView
{
    return 1;
}

-(NSString *)pickerView:(UIPickerView *)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component
{
    NSArray * arrKeys = dictRooms.allKeys;
    NSString * strTitle = [arrKeys objectAtIndex:row];
    return strTitle;
}

-(void)pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component
{
    HUD.textLabel.text = @"Loading Events...";
    [HUD showInView:self.viewBg];
    NSArray * allKeys = dictRooms.allKeys;
    currentRoom = [dictRooms objectForKey:[allKeys objectAtIndex:row]];
    NSString * strRoom = [allKeys objectAtIndex:row];
    lblCurrentRoom.text = [NSString stringWithFormat:@"%@ %@", strRoom, ([strRoom isEqual:@"Personal"])?@"Calendar":@"Room"];
    lblLateTodayEventTime.text = lblLateToday.text = lblPreviousEvent.text = lblCommingUpNextEventTime.text = lblCommingUpNext.text = @"";
    lblLateToday.hidden = lblLateTodayEventTime.hidden = lblPreviousEvent.hidden = lblCommingUpNext.hidden = lblCommingUpNextEventTime.hidden = YES;
    //currentLateEvent = currentNextEvent = currentPrevEvent = nil;
    [self startLoadingCurrentCalendarInfo];
}

-(void)startLoadingCurrentCalendarInfo
{
    NSTimer *timer = [NSTimer scheduledTimerWithTimeInterval:1.0 target:self selector:@selector(timerTick:) userInfo:nil repeats:YES];
    [timer fire];
    [self queryTodaysEvents];
}

- (void)timerTick:(NSTimer *)timer {
    dispatch_async(dispatch_get_main_queue(), ^{
        NSDate *now = [NSDate date];
        static NSDateFormatter *dateFormatter;
        if (!dateFormatter) {
            dateFormatter = [[NSDateFormatter alloc] init];
            dateFormatter.dateFormat = @"HH:mm:ss";
        }
        lblTimer.text = [NSString stringWithFormat:@"Time: %@", [dateFormatter stringFromDate:now]];
        [self.view bringSubviewToFront:viewBg];
        [self.view bringSubviewToFront:lblTimer];
        currentEvent = @"";
        [self setThisBackgroundColor];
    });
}

-(void)setThisBackgroundColor
{
    UIColor * colorBG = [ColorManager availableColor];
    NSDateFormatter * df = [[NSDateFormatter alloc] init];
    df.timeZone = [NSTimeZone localTimeZone];
    df.dateFormat = @"HH:mm";
    BOOL hasEvent = NO;
    id cEvent;
    id pEvent;
    id nEvent;
    id lEvent; // late event
    if([arrEvents count] != 0)
    {
        currentPrevEvent = currentNextEvent = currentLateEvent = nil;
        for(NSDictionary * event in arrEvents)
        {
            NSLog(@"event.summary: %@", [event objectForKey:@"summary"]);
            NSDate * st = [event objectForKey:@"startTime"];
            NSDate * et = [event objectForKey:@"endTime"];
            NSDate * ct = [NSDate date];
            if([st compare:ct] == NSOrderedAscending && [et compare:ct] == NSOrderedDescending)
            {
                cEvent = event;
            }
            else if([st compare:ct] == NSOrderedDescending && [et compare:ct] == NSOrderedDescending) //next event
            {
                nEvent = event;
            }
            else if([st compare:ct] == NSOrderedAscending && [et compare:ct] == NSOrderedAscending) //previous event
            {
                pEvent = event;
            }
            if([st compare:ct] == NSOrderedAscending && [et compare:ct] == NSOrderedDescending)
            {
                colorBG = [ColorManager busyColor];
                if(![currentEvent isEqual:[event objectForKey:@"summary"]])
                {
                    currentEvent = [event objectForKey:@"summary"];
                    [UIView animateWithDuration:.500 animations:^{
                        lblFromTo.hidden = NO;
                        lblEvent.textColor = [ColorManager fontBusyColor];
                        lblEvent.text = [event objectForKey:@"summary"];
                        lblFromTo.text = [NSString stringWithFormat:@"%@ - %@", [df stringFromDate:st], [df stringFromDate:et]];
                    }];
                    hasEvent = YES;
                    lblCurrentEventTitle.hidden = NO;
                    imgClockNow.hidden = NO;
                    colorBG = [ColorManager busyColor];
                    if(pEvent)
                    {
                        lblPreviousEvent.hidden = NO;
                        lblPreviousEvent.text = [NSString stringWithFormat:@"Previous event: %@", [pEvent objectForKey:@"summary"]];
                        lblPreviousEvent.textColor = [ColorManager fontBusyColor];
                    }
                    else if (!pEvent)
                    {
                        lblPreviousEvent.hidden = YES;
                    }
                    if(nEvent)
                    {
                        NSDate * cSt = [nEvent objectForKey:@"startTime"];
                        NSDate * cEt = [nEvent objectForKey:@"endTime"];
                        lblCommingUpNext.hidden = lblCommingUpNextEventTime.hidden = imgCommingUpClock.hidden = NO;
                        lblCommingUpNext.text = [NSString stringWithFormat:@"Comming up next: %@", [nEvent objectForKey:@"summary"]];
                        lblCommingUpNextEventTime.text = [NSString stringWithFormat:@"%@ - %@", [df stringFromDate:cSt], [df stringFromDate:cEt]];
                    }
                    else if (!nEvent)
                    {
                        lblCommingUpNext.hidden = lblCommingUpNextEventTime.hidden = imgCommingUpClock.hidden = YES;
                    }
                }
            }
        }
        if(!hasEvent)
        {
            if(pEvent)
            {
                lblPreviousEvent.hidden = NO;
                lblPreviousEvent.text = [NSString stringWithFormat:@"Previous event: %@", [pEvent objectForKey:@"summary"]];
            }
            if(nEvent)
            {
                NSDate * cSt = [nEvent objectForKey:@"startTime"];
                NSDate * cEt = [nEvent objectForKey:@"endTime"];
                lblCommingUpNext.hidden = lblCommingUpNextEventTime.hidden = imgCommingUpClock.hidden = NO;
                lblCommingUpNext.text = [NSString stringWithFormat:@"Comming up next: %@", [nEvent objectForKey:@"summary"]];
                lblCommingUpNextEventTime.text = [NSString stringWithFormat:@"%@ - %@", [df stringFromDate:cSt], [df stringFromDate:cEt]];
            }
            lblCurrentEventTitle.hidden = YES;
            if([currentRoom isEqual:@"primary"])
            {
                lblEvent.textColor = [ColorManager fontAvailableColor];
                lblEvent.text = @"Calendar Available";
            }
            else
            {
                lblEvent.textColor = [ColorManager fontAvailableColor];
                lblEvent.text = @"Room Available";
            }
            lblFromTo.hidden = YES;
            imgClockNow.hidden = YES;
            currentEvent = @"";
            colorBG = [ColorManager availableColor];
        }
    }
    [UIView animateWithDuration:.300 animations:^{
        [viewBg setBackgroundColor:colorBG];
    }];
}

- (void)queryTodaysEvents {
    NSString *calendarID = currentRoom;//@"magmalabs.io_3731333535303737383630@resource.calendar.google.com";
    GTLDateTime *startOfDay = [self dateTimeForTodayAtHour:0 minute:0 second:1];
    GTLDateTime *endOfDay = [self dateTimeForTodayAtHour:23 minute:59 second:59];
    GTLQueryCalendar *query = [GTLQueryCalendar queryForEventsListWithCalendarId:calendarID];
    query.timeMin = startOfDay;
    query.timeMax = endOfDay;
    query.singleEvents = YES;
    query.orderBy = kGTLCalendarOrderByStartTime;
    [self.service executeQuery:query delegate:self didFinishSelector:@selector(displayResultWithTicket:finishedWithObject:error:)];
}

#pragma mark Query Events
// Utility routine to make a GTLDateTime object for sometime today
- (GTLDateTime *)dateTimeForTodayAtHour:(int)hour minute:(int)minute second:(int)second {
    NSUInteger const kComponentBits = (NSCalendarUnitYear | NSCalendarUnitMonth | NSCalendarUnitDay | NSCalendarUnitHour | NSCalendarUnitMinute | NSCalendarUnitSecond);
    NSCalendar *cal = [[NSCalendar alloc] initWithCalendarIdentifier:NSCalendarIdentifierGregorian];
    NSDateComponents *dateComponents = [cal components:kComponentBits fromDate:[NSDate date]];
    [dateComponents setHour:hour];
    [dateComponents setMinute:minute];
    [dateComponents setSecond:second];
    [dateComponents setTimeZone:[NSTimeZone localTimeZone]];
    GTLDateTime *dateTime = [GTLDateTime dateTimeWithDateComponents:dateComponents];
    return dateTime;
}

- (void)displayResultWithTicket:(GTLServiceTicket *)ticket finishedWithObject:(GTLCalendarEvents *)events error:(NSError *)error {
    if (error == nil) {
        arrEvents = [NSMutableArray new];
        if (events.items.count > 0) {
            for (GTLCalendarEvent *event in events) {
                GTLDateTime *start = event.start.dateTime ?: event.start.date;
                GTLDateTime * end = event.end.dateTime ?: event.end.date;
                NSString *startString = [NSDateFormatter localizedStringFromDate:[start date] dateStyle:NSDateFormatterShortStyle timeStyle:NSDateFormatterShortStyle];
                NSString *endString = [NSDateFormatter localizedStringFromDate:[end date] dateStyle:NSDateFormatterShortStyle timeStyle:NSDateFormatterShortStyle];
                if(![event.visibility isEqual:@"private"])
                {
                    NSMutableDictionary * dictEvent = [NSMutableDictionary new];
                    NSDateFormatter * df = [[NSDateFormatter alloc] init];
                    df.timeZone = [NSTimeZone localTimeZone];
                    df.dateFormat = @"HH:mm";
                    [dictEvent setObject:[start date] forKey:@"startTime"];
                    [dictEvent setObject:[end date] forKey:@"endTime"];
                    [dictEvent setObject:event.summary?event.summary:@"N/A" forKey:@"summary"];
                    [dictEvent setObject:event.descriptionProperty?event.descriptionProperty:@"N/A" forKey:@"description"];
                    [arrEvents addObject:dictEvent];
                }
            }
        } else {
            //no events found
        }
    } else {
        [self showAlert:@"Error" message:error.localizedDescription];
    }
    dispatch_async(dispatch_get_main_queue(), ^{
        if([HUD isVisible])
            [HUD dismiss];
    });
}

// Creates the auth controller for authorizing access to Google Calendar API.
- (GTMOAuth2ViewControllerTouch *)createAuthController {
    GTMOAuth2ViewControllerTouch *authController;
    NSArray *scopes = [NSArray arrayWithObjects:kGTLAuthScopeCalendarReadonly, nil];
    authController = [[GTMOAuth2ViewControllerTouch alloc]
                      initWithScope:[scopes componentsJoinedByString:@" "]
                      clientID:kClientID
                      clientSecret:nil
                      keychainItemName:kKeychainItemName
                      delegate:self
                      finishedSelector:@selector(viewController:finishedWithAuth:error:)];
    return authController;
}

// Handle completion of the authorization process, and update the Google Calendar API
// with the new credentials.
- (void)viewController:(GTMOAuth2ViewControllerTouch *)viewController finishedWithAuth:(GTMOAuth2Authentication *)authResult error:(NSError *)error {
    if (error != nil) {
        [self showAlert:@"Authentication Error" message:error.localizedDescription];
        self.service.authorizer = nil;
    }
    else {
        self.service.authorizer = authResult;
        [self dismissViewControllerAnimated:YES completion:nil];
    }
}

// Helper for showing an alert
- (void)showAlert:(NSString *)title message:(NSString *)message {
    UIAlertController* alertController = [UIAlertController alertControllerWithTitle:title message:message preferredStyle:UIAlertControllerStyleActionSheet];
    UIAlertAction* dismissAlertController = [UIAlertAction actionWithTitle:@"Dismiss" style:UIAlertActionStyleDefault handler:nil];
    [alertController addAction:dismissAlertController];
    [self presentViewController:alertController animated:YES completion:nil];
}
@end