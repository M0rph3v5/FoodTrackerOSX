//
//  FTAppDelegate.m
//  foodtracker
//
//  Created by Benjamin de Jager on 7/30/13.
//  Copyright (c) 2013 Benjamin de Jager. All rights reserved.
//

#import "FTAppDelegate.h"

@implementation FTAppDelegate {
  NSStatusItem *_statusItem;
  NSDateFormatter *_dateFormatter;
  
  NSArray *_latestData;
  NSString *_trackingId;
}

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification {
  
  _dateFormatter = [[NSDateFormatter alloc] init];
  _dateFormatter.dateFormat = @"mm:ss";
  
  _statusItem = [[NSStatusBar systemStatusBar] statusItemWithLength:NSVariableStatusItemLength];
  _statusItem.title = @"FoodTracker";
  _statusItem.menu = _menu;
  
  [NSTimer scheduledTimerWithTimeInterval:5 target:self selector:@selector(pollTracker) userInfo:nil repeats:YES];
  [NSTimer scheduledTimerWithTimeInterval:1 target:self selector:@selector(updateStatusItem) userInfo:nil repeats:YES];
  
  [self pollTracker];
}

- (void)pollTracker {
  if (!_trackingId)
    return;
  
  NSMutableURLRequest *urlRequest = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:@"http://www.thuisbezorgd.nl/getFoodTrackerstatus.php"]];
  [urlRequest setHTTPMethod:@"POST"];
  NSString *formdata = [@"trackingid=" stringByAppendingString:_trackingId];
  [urlRequest setHTTPBody:[formdata dataUsingEncoding:NSUTF8StringEncoding]];
    
  __weak FTAppDelegate *appDelegate = self;
  [NSURLConnection sendAsynchronousRequest:urlRequest queue:[[NSOperationQueue alloc] init] completionHandler:^(NSURLResponse *response, NSData *data, NSError *error) {
    if (error) {
      NSLog(@"error %@", error.localizedDescription);
      return;
    }
    
    NSArray *responseData =[NSJSONSerialization JSONObjectWithData:data options:0 error:&error];
    if ([[[responseData objectAtIndex:0] objectForKey:@"type"] isEqualToString:@"EX"])
      return;
    
    __strong FTAppDelegate *strongAppDelegate = appDelegate;
    if (strongAppDelegate)
      strongAppDelegate->_latestData = responseData;
    
  }];
}

- (void)updateStatusItem {
  if (!_latestData)
    return;

  NSTimeInterval etaTimeInterval = [[[_latestData objectAtIndex:0] objectForKey:@"timestamp"] intValue]/1000;
  NSTimeInterval eta = etaTimeInterval - [[NSDate date] timeIntervalSince1970];
  
  NSString *etastring = [_dateFormatter stringFromDate:[NSDate dateWithTimeIntervalSince1970:eta]];
  NSString *status = [[_latestData lastObject] objectForKey:@"status"];
  if ([status isEqualToString:@"Afgeleverd"]) {
    _statusItem.title = status;
  } else {
    _statusItem.title = [NSString stringWithFormat:@"%@ ETA %@", status, etastring];
  }
  
}

- (IBAction)setFoodTrackerId:(id)sender {
  NSRegularExpression *regex = [NSRegularExpression regularExpressionWithPattern:@"[0-9]*" options:NSRegularExpressionCaseInsensitive error:nil];
  NSArray *matches = [regex matchesInString:[_foodTrackerTextField stringValue] options:0 range:NSMakeRange(0, [_foodTrackerTextField stringValue].length)];
  if ([matches count] > 0) {
    NSTextCheckingResult *match = [matches objectAtIndex:0];
    _trackingId = [[_foodTrackerTextField stringValue] substringWithRange:match.range];
  }
  
  [_foodTrackerPanel close];
}

- (IBAction)wakeUpWindow:(id)sender {
  [_foodTrackerPanel makeKeyAndOrderFront:sender];
  [NSApp unhide];
}

@end
