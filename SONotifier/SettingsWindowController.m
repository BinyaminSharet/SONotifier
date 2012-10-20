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
#import "SEApi.h"

#define API_KEY_API_SITE_PARAMETER  @"api_site_parameter"
#define API_KEY_SITE_NAME           @"name"
#define API_KEY_SITE_URL            @"site_url"
#define API_KEY_LOGO_URL            @"logo_url"
#define API_KEY_SITE_TYPE           @"site_type"
#define API_VALUE_SITE_TYPE_MAIN    @"main_site"



@implementation SettingsWindowController

@synthesize delegate;
@synthesize sitesArray = _siteArray;

- (NSString *) getSitesListFromUserDefaults
{
    NSNumber * lastupdate = [PersistantData retrieveFromUserDefaults:DATA_KEY_SE_SITE_LAST_UPDATE];
    if (lastupdate) 
    {
        NSTimeInterval current = [[NSDate date] timeIntervalSince1970];
        double offset = [lastupdate doubleValue] - current;
        // if updated in last 24 hours
        if (offset < ( 60 * 60 * 24))
        {
            return [PersistantData retrieveFromUserDefaults:DATA_KEY_SE_SITE_FULL_JSON];
        }
    }
    return nil;
}

- (void) setCurrentSiteIndexInArray
{
    NSString * siteName = [PersistantData retrieveFromUserDefaults:DATA_KEY_SE_SITE_API_NAME];
    selectedSiteIndex = 0;
    if (siteName)
    {
        for (int i = 0; i < [[self sitesArray] count]; ++i)
        {
            if ([siteName isEqualToString:[[[self sitesArray] objectAtIndex:i] objectForKey:API_KEY_API_SITE_PARAMETER]])
            {
                selectedSiteIndex = i;
                break;
            }
        }
    }
}

-(void) removeNonMainEntriesFromSitesArray
{
    for (int i = [[self sitesArray] count] - 1; i >= 0; --i)
    {
        NSDictionary * dict = [[self sitesArray] objectAtIndex:i];
        if ([API_VALUE_SITE_TYPE_MAIN isEqualToString:[dict objectForKey:API_KEY_SITE_TYPE]] == NO)
        {
            [[self sitesArray] removeObjectAtIndex:i];
        }
    }
}

- (BOOL) populateSitesArray
{
    BOOL downloaded = NO;
    selectedSiteIndex = 0;
    NSString * jsonString = nil;
    // check if already populated in the last day
    jsonString = [self getSitesListFromUserDefaults];
    if (jsonString == nil)
    {
        downloaded = YES;
        jsonString = [SEApi getDataForApiRequest:@"/sites?page=1&pagesize=999"];
    }    
    NSError *jsonParsingError = nil;
    NSDictionary *data = [[NSJSONSerialization JSONObjectWithData:[jsonString dataUsingEncoding:NSUTF8StringEncoding] 
                                                         options:0 error:&jsonParsingError] retain];
    if (jsonParsingError)
    {
        [jsonParsingError release];
    }
    if (data) 
    {
        NSArray * arr = [data objectForKey:@"items"];
        if (arr)
        {
            //_siteArray = [NSMutableArray arrayWithArray:arr];
            self.sitesArray = [[arr mutableCopy] autorelease];
            [self removeNonMainEntriesFromSitesArray];
            if (downloaded)
            {
                [PersistantData saveItemToPreferences:jsonString withKey:DATA_KEY_SE_SITE_FULL_JSON];
                NSTimeInterval interval = [[NSDate date] timeIntervalSince1970];
                [PersistantData saveItemToPreferences:[NSNumber numberWithDouble:interval] withKey:DATA_KEY_SE_SITE_LAST_UPDATE];

            }
            [self setCurrentSiteIndexInArray];
            [data release];
            return YES;
        }
        [data release];
    }
    return NO;
}

- (id)init
{
    self = [super initWithWindowNibName:@"SettingsWindow"];
    if (self) 
    {
        [self populateSitesArray];
        [[self window] setDelegate:self];
        NSString * temp = [PersistantData retrieveFromUserDefaults:DATA_KEY_LAUNCH_AT_STARTUP];
        storedLaunchState = ([@"YES" compare:temp] == NSOrderedSame) ? NSOnState : NSOffState;
        [launchAtStartUp setState:storedLaunchState];
        intervals = [PersistantData retrieveFromUserDefaults:DATA_KEY_UPDATE_INTERVAL];
        intervals = [NSNumber numberWithInt:[intervals intValue] / 60];
        [updateIntervals setStringValue:[intervals stringValue]];
        storedUserId = [PersistantData retrieveFromUserDefaults:DATA_KEY_USER_ID];
        [[self window] center];
        [[self window] setLevel:NSFloatingWindowLevel];
    }
    
    return self;
}

- (void)windowDidLoad
{
    // Implement this method to handle any initialization after your window controller's window has been loaded from its nib file.
    [super windowDidLoad];
}

- (IBAction)showWindow:(id)sender
{
    [super showWindow:sender];
}

- (IBAction)saveAndClose:(id)sender 
{
    [[self window] performClose:self];
    [[self window] close];
}

- (NSInteger) updateFromFields 
{
    NSInteger flags = 0;
    NSString * str;
    str = [updateIntervals stringValue];
    if (str) 
    {
        int intVal = [str intValue];
        // avoid access to persistant data when no change happens
        if (intVal > 0)
        {
            if (intVal != [intervals intValue]) 
            {
                NSLog(@"Setting update interval to: %d minutes, the string is: %@", intVal, str);
                NSNumber * num = [NSNumber numberWithDouble:intVal * 60.];
                [PersistantData saveItemToPreferences:num withKey:DATA_KEY_UPDATE_INTERVAL];
                flags |= SETTINGS_UPDATE_INTERVAL_CHANGED;
            }
        }
    }
    str = [userId stringValue];
    if (str) 
    {
        int intVal = [str intValue];
        // avoid access to persistant data when no change happens
        if (intVal > 0) 
        {
            if (intVal != [storedUserId intValue])
            {
                NSNumber * num = [NSNumber numberWithInt:intVal];
                NSLog(@"Setting user id to: %d , the string is: %@", intVal, str);
                [PersistantData saveItemToPreferences:num withKey:DATA_KEY_USER_ID];
                flags |= SETTINGS_USER_ID_CHANGED;
            }
        }
    }
    NSInteger choice = [launchAtStartUp state];
    // avoid access to persistant data when no change happens
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
        flags |= SETTINGS_LAUNCH_ONSTART_CHANGED;
    }
    // Save site data
    NSDictionary * dict = [[self sitesArray] objectAtIndex:selectedSiteIndex];
    [PersistantData saveItemToPreferences:[dict objectForKey:API_KEY_API_SITE_PARAMETER] withKey:DATA_KEY_SE_SITE_API_NAME];
    [PersistantData saveItemToPreferences:[dict objectForKey:API_KEY_SITE_NAME] withKey:DATA_KEY_SE_SITE_NAME];
    [PersistantData saveItemToPreferences:[dict objectForKey:API_KEY_SITE_URL] withKey:DATA_KEY_SE_SITE_URL];
    return flags;
}

- (BOOL)windowShouldClose:(id)sender 
{
    [delegate dataUpdated:[self updateFromFields]];
    return YES;
}

// Table of sites.
- (id)tableView:(NSTableView *)aTableView objectValueForTableColumn:(NSTableColumn *)aTableColumn row:(NSInteger)rowIndex
{
    NSDictionary * dict = [[self sitesArray] objectAtIndex:rowIndex];
    NSString * str = [NSString stringWithString:[dict objectForKey:API_KEY_SITE_NAME]];
    [[aTableColumn dataCell] setEditable:NO];
    return str;
}

- (IBAction)columnChangeSelected:(id)sender
{
    selectedSiteIndex = [sitesTable selectedRow];
}

- (NSInteger)numberOfRowsInTableView:(NSTableView *)tableView {
    NSIndexSet *indexSet = [NSIndexSet indexSetWithIndex:selectedSiteIndex];
    [tableView selectRowIndexes:indexSet byExtendingSelection:NO];
    return [[self sitesArray] count];
}

- (void) dealloc
{
    [self setSitesArray:nil];
    [super dealloc];
    
}
@end
