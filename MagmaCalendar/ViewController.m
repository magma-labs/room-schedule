//
//  ViewController.m
//  MagmaCalendar
//
//  Created by Omar Guzman on 2/5/16.
//  Copyright © 2016 Omar Guzman. All rights reserved.
//

#import "ViewController.h"

static NSString *const kKeychainItemName = @"Google Calendar API";
static NSString *const kClientID = @"769354150819-pll3a1p7c9i3o5l682b6stullgr815fv.apps.googleusercontent.com";

@implementation ViewController

@synthesize service = _service;
@synthesize lblTimer, viewBg, arrEvents, currentEvent, lblEvent, lblFrom, lblTo, txtDescription, HUD, currentRoom, pRooms, dictRooms, eventString;

// When the view loads, create necessary subviews, and initialize the Google Calendar API service.
- (void)viewDidLoad {
    [super viewDidLoad];
    
    // Initialize the Google Calendar API service & load existing credentials from the keychain if available.
    self.service = [[GTLServiceCalendar alloc] init];
    self.service.authorizer = [GTMOAuth2ViewControllerTouch authForGoogleFromKeychainForName:kKeychainItemName clientID:kClientID clientSecret:nil];
    HUD = [JGProgressHUD progressHUDWithStyle:JGProgressHUDStyleLight];
    HUD.textLabel.text = @"Loading Calendars...";
}

// When the view appears, ensure that the Google Calendar API service is authorized, and perform API calls.
- (void)viewDidAppear:(BOOL)animated {
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
            [pRooms setDelegate:self];
            [pRooms setDataSource:self];
            [pRooms reloadAllComponents];
            [self startLoadingCurrentCalendarInfo];
        }
        [HUD dismissAnimated:YES];
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
    NSArray * allKeys = dictRooms.allKeys;
    currentRoom = [dictRooms objectForKey:[allKeys objectAtIndex:row]];
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
            dateFormatter.dateFormat = @"h:mm:ss a";
        }
        lblTimer.text = [dateFormatter stringFromDate:now];
        [self.view bringSubviewToFront:viewBg];
        [self.view bringSubviewToFront:lblTimer];
        currentEvent = @"";
        [self setThisBackgroundColor];
    });
}

-(void)setThisBackgroundColor
{
    UIColor * colorBG = [UIColor yellowColor];
    NSDateFormatter * df = [[NSDateFormatter alloc] init];
    df.timeZone = [NSTimeZone localTimeZone];
    df.dateFormat = @"h:mm a";
    BOOL hasEvent = NO;
    if([arrEvents count] != 0)
    {
        for(NSDictionary * event in arrEvents)
        {
            NSDate * st = [event objectForKey:@"startTime"];
            NSDate * et = [event objectForKey:@"endTime"];
            NSDate * ct = [NSDate date];
            if([st compare:ct] == NSOrderedAscending && [et compare:ct] == NSOrderedDescending)
            {
                colorBG = [UIColor redColor];
                if(![currentEvent isEqual:[event objectForKey:@"summary"]])
                {
                    currentEvent = [event objectForKey:@"summary"];
                    [UIView animateWithDuration:.500 animations:^{
                        lblFrom.hidden = NO;
                        lblTo.hidden = NO;
                        txtDescription.hidden = NO;
                        lblEvent.text = [NSString stringWithFormat:@"Current Event: %@", [event objectForKey:@"summary"]];
                        lblFrom.text = [NSString stringWithFormat:@"From: %@", [df stringFromDate:st]];
                        lblTo.text = [NSString stringWithFormat:@"To: %@", [df stringFromDate:et]];
                        txtDescription.text = [event objectForKey:@"description"];
                    }];
                    hasEvent = YES;
                    colorBG = [UIColor redColor];
                    break;
                }
            }
        }
        if(!hasEvent)
        {
            lblEvent.text = @"Free room";
            lblFrom.hidden = YES;
            lblTo.hidden = YES;
            txtDescription.text = [NSString stringWithFormat:@"Today scheduled events:\n\n%@",eventString];
            currentEvent = @"";
            colorBG = [UIColor greenColor];
        }
    }
    [UIView animateWithDuration:.300 animations:^{
        [viewBg setBackgroundColor:colorBG];
    }];
    [self.view bringSubviewToFront:pRooms];
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

// Construct a query and get a list of upcoming events from the user calendar. Display the
// start dates and event summaries in the UITextView.
// unused
- (void)fetchEvents {
    GTLQueryCalendar *query = [GTLQueryCalendar queryForEventsListWithCalendarId:@"magmalabs.io_3731333535303737383630@resource.calendar.google.com"];
    query.maxResults = 30;
    query.timeMin = [GTLDateTime dateTimeWithDate:[NSDate date] timeZone:[NSTimeZone localTimeZone]];
    query.singleEvents = YES;
    query.orderBy = kGTLCalendarOrderByStartTime;
    [self.service executeQuery:query delegate:self didFinishSelector:@selector(displayResultWithTicket:finishedWithObject:error:)];
}

- (void)displayResultWithTicket:(GTLServiceTicket *)ticket finishedWithObject:(GTLCalendarEvents *)events error:(NSError *)error {
    if (error == nil) {
        eventString = [[NSMutableString alloc] init];
        if (events.items.count > 0) {
            arrEvents = [NSMutableArray new];
            for (GTLCalendarEvent *event in events) {
                GTLDateTime *start = event.start.dateTime ?: event.start.date;
                GTLDateTime * end = event.end.dateTime ?: event.end.date;
                NSString *startString = [NSDateFormatter localizedStringFromDate:[start date] dateStyle:NSDateFormatterShortStyle timeStyle:NSDateFormatterShortStyle];
                NSString *endString = [NSDateFormatter localizedStringFromDate:[end date] dateStyle:NSDateFormatterShortStyle timeStyle:NSDateFormatterShortStyle];
                if(![event.visibility isEqual:@"private"])
                {
                    
                    [eventString appendFormat:@"Event: %@ - From: %@ To: %@\n", event.summary, startString, endString];
                    NSMutableDictionary * dictEvent = [NSMutableDictionary new];
                    NSDateFormatter * df = [[NSDateFormatter alloc] init];
                    df.timeZone = [NSTimeZone localTimeZone];
                    df.dateFormat = @"h:mm a";
                    [dictEvent setObject:[start date] forKey:@"startTime"];
                    [dictEvent setObject:[end date] forKey:@"endTime"];
                    [dictEvent setObject:event.summary forKey:@"summary"];
                    [dictEvent setObject:event.descriptionProperty?event.descriptionProperty:@"N/A" forKey:@"description"];
                    [arrEvents addObject:dictEvent];
                }
            }
            NSLog(@"events: %@", eventString);
        } else {
            [eventString appendString:@"No upcoming events found."];
        }
    } else {
        [self showAlert:@"Error" message:error.localizedDescription];
    }
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
    UIAlertView *alert;
    alert = [[UIAlertView alloc] initWithTitle:title message:message delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
    [alert show];
}

@end