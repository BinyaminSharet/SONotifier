/*
 * Copyright (C) 2012 Binyamin Sharet
 *
 * This file is part of SONotifier.
 * 
 * SONotifier is free software: you can redistribute it and/or modify
 * it under the terms of the GNU General Public License as published by
 * the Free Software Foundation, either version 3 of the License, or
 * (at your option) any later version.
 * 
 * SONotifier is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU General Public License for more details.
 * 
 * You should have received a copy of the GNU General Public License
 * along with SONotifier. If not, see <http://www.gnu.org/licenses/>.
 */

#import "SettingsWindowController.h"
#import "PersistantData.h"
#import "Utils.h"

@implementation SettingsWindowController

@synthesize delegate;

- (id)init
{
    self = [super initWithWindowNibName:@"SettingsWindow"];
    if (self) 
    {
        
    }
    
    return self;
}

- (void)windowDidLoad
{
    [super windowDidLoad];
    NSLog(@"[self window]: %@", [self window]);
    [[self window] setDelegate:self];
    storedLaunchState = ([@"YES" compare:[PersistantData retrieveFromUserDefaults:DATA_KEY_LAUNCH_AT_STARTUP]] == NSOrderedSame) ? NSOnState : NSOffState;
    [launchAtStartUp setState:storedLaunchState];
    // Implement this method to handle any initialization after your window controller's window has been loaded from its nib file.
}

- (IBAction)showWindow:(id)sender
{
    [super showWindow:sender];
    [[self window] center];
    [[self window] setLevel:NSFloatingWindowLevel];
}

- (IBAction)saveAndClose:(id)sender 
{
    NSLog(@"[self window]: %@", [self window]);
    [[self window] performClose:self];
    [[self window] close];
}

- (BOOL) updateFromFields 
{
    NSString * str;
    str = [updateIntervals stringValue];
    if (str) 
    {
        int intVal = [str intValue];
        if (intVal > 0) 
        {
            NSLog(@"Setting update interval to: %d minutes, the string is: %@", intVal, str);
            [PersistantData saveItemToPreferences:[NSNumber numberWithDouble:intVal * 60.] withKey:DATA_KEY_UPDATE_INTERVAL];
        }
    }
    str = [userId stringValue];
    if (str) 
    {
        int intVal = [str intValue];
        if (intVal > 0) 
        {
            NSNumber * num = [NSNumber numberWithInt:intVal];
            NSLog(@"Setting user id to: %d , the string is: %@", intVal, str);
            [PersistantData saveItemToPreferences:num withKey:DATA_KEY_USER_ID];
        }
    }
    NSInteger choice = [launchAtStartUp state];
    if (choice != storedLaunchState) 
    {
        NSString * value;
        if (choice == NSOnState) 
        {
            [Utils addAppAsLoginItem];
            value = @"YES";
        }
        else
        {
            [Utils deleteAppFromLoginItem];
            value = @"NO";
        }
        [PersistantData saveItemToPreferences:value withKey:DATA_KEY_LAUNCH_AT_STARTUP];
        storedLaunchState = choice;
    }
    return YES;
}

- (BOOL)windowShouldClose:(id)sender 
{
    NSLog(@"Should close called");
    BOOL allGood;
    allGood = [self updateFromFields];
    if (allGood) 
    {
        [delegate dataUpdated];
    }
    return YES;
}
@end
