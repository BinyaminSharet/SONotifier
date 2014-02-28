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

#import "AppDelegate.h"
#import "BaseMenu.h"
#import "PersistantData.h"

@implementation AppDelegate

@synthesize settingWindow;
@synthesize window = _window;

- (void)dealloc
{
    [super dealloc];
}

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification
{
    // Insert code here to initialize your application
}

- (void) runUpdateManager 
{
    NSNumber * interval = [PersistantData retrieveFromUserDefaults:DATA_KEY_UPDATE_INTERVAL];
    if (interval == nil) 
    {
        interval = [NSNumber numberWithDouble:60. * 10];
        [PersistantData saveItemToPreferences:interval withKey:DATA_KEY_UPDATE_INTERVAL];
    }
    NSString * seSiteName = [PersistantData retrieveFromUserDefaults:DATA_KEY_SE_SITE_API_NAME];
    if (seSiteName == nil)
    {
        // show dialog to select SE site to follow
        // fo now only, we do:
        seSiteName = @"stackoverflow";
    }
    
    NSNumber * userid = [PersistantData retrieveFromUserDefaults:DATA_KEY_USER_ID];
    if (userid == nil)
    {
        // handle no userid
    }

    updateManager = [[UpdateManager alloc] init];
    [updateManager setUpdateDelegate:menus];
    [updateManager setSiteName:seSiteName];
    [updateManager setUpdateInterval:[interval doubleValue]];
    [updateManager setUserId:userid];
    [updateManager startRunning]; 
    [menus setUpdateManager:updateManager];
}

- (void) setUi 
{
    menus = [[BaseMenu alloc] init];
    [menus buildUi];
    [menus setDelegate:self];
}

- (NSString *)input: (NSString *)prompt defaultValue: (NSString *)defaultValue 
{
    NSAlert *alert = [NSAlert alertWithMessageText: prompt
                                     defaultButton:@"OK"
                                   alternateButton:@"Cancel"
                                       otherButton:nil
                         informativeTextWithFormat:@""];
    
    NSTextField *input = [[[NSTextField alloc] initWithFrame:NSMakeRect(0, 0, 200, 24)] autorelease];
    [input setStringValue:defaultValue];
    [alert setAccessoryView:input];
    NSInteger button = [alert runModal];
    if (button == NSAlertDefaultReturn) 
    {
        [input validateEditing];
        return [input stringValue];
    } 
    else if (button == NSAlertAlternateReturn) 
    {
        return nil;
    } 
    else 
    {
        NSAssert1(NO, @"Invalid input dialog button %lu", button);
        return nil;
    }
}

- (BOOL) getBasicConfiguration 
{
    NSString * input = [self input:@"Enter User ID" defaultValue:@""];
    if (input != nil ) 
    {
        NSNumberFormatter * f = [[[NSNumberFormatter alloc] init] autorelease];
        [f setNumberStyle:NSNumberFormatterDecimalStyle];
        NSNumber * uid = [f numberFromString:input];
        if (uid != nil) 
        {
            [PersistantData saveItemToPreferences:uid withKey:DATA_KEY_USER_ID];
            [PersistantData saveItemToPreferences:@"YES" withKey:DATA_KEY_CONFIGURED];
            return YES;
        }
    }
    return NO;
}

- (void) awakeFromNib 
{
    [self setUi];
    if ([PersistantData retrieveFromUserDefaults:DATA_KEY_CONFIGURED] == nil) 
    {
        if ([self getBasicConfiguration]) 
        {
            [self runUpdateManager];
        }
        else 
        {
            NSLog(@"DAMN");
        }
    }
    else 
    {
        [self runUpdateManager];   
    }
}

- (void) showSettings 
{
    SettingsWindowController * settings = [[[SettingsWindowController alloc] init] autorelease];
    [settings setDelegate:self];
    [settings showWindow:self];
    [self setSettingWindow:settings];
}

- (void) dataUpdated:(NSInteger)updateFlags
{
    if (updateFlags & SETTINGS_USER_ID_CHANGED) 
    {
        [updateManager setUserId:[PersistantData retrieveFromUserDefaults:DATA_KEY_USER_ID]];
    }
    if (updateFlags & SETTINGS_UPDATE_INTERVAL_CHANGED)
    {
        [updateManager setUpdateInterval:[[PersistantData retrieveFromUserDefaults:DATA_KEY_UPDATE_INTERVAL] doubleValue]];
    }
    [updateManager setSiteName:[PersistantData retrieveFromUserDefaults:DATA_KEY_SE_SITE_API_NAME]];
}
@end
