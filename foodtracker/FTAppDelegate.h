//
//  FTAppDelegate.h
//  foodtracker
//
//  Created by Benjamin de Jager on 7/30/13.
//  Copyright (c) 2013 Benjamin de Jager. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@interface FTAppDelegate : NSObject <NSApplicationDelegate>

@property (assign) IBOutlet NSWindow *window;
@property (weak) IBOutlet NSMenu *menu;
@property (unsafe_unretained) IBOutlet NSPanel *foodTrackerPanel;
@property (weak) IBOutlet NSTextField *foodTrackerTextField;

@end
