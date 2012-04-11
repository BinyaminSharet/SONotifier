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

@synthesize window = _window;

- (void)dealloc
{
    [super dealloc];
}

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification
{
    // Insert code here to initialize your application
}

- (void) runUpdateManager {
    updateManager = [[UpdateManager alloc] init];
    [updateManager setUpdateDelegate:menus];
    NSNumber * interval = [PersistantData retrieveFromUserDefaults:DATA_KEY_UPDATE_INTERVAL];
    if (interval == nil) {
        interval = [NSNumber numberWithDouble:60. * 10];
        [PersistantData saveItemToPreferences:interval withKey:DATA_KEY_UPDATE_INTERVAL];
    }
    [updateManager setUpdateInterval:[interval doubleValue]];
    NSNumber * userid = [PersistantData retrieveFromUserDefaults:DATA_KEY_USER_ID];
    [updateManager setUserId:userid];
    [updateManager startRunning]; 
}

- (void) setUi {
    menus = [[BaseMenu alloc] init];
    [menus buildUi];
}

- (NSString *)input: (NSString *)prompt defaultValue: (NSString *)defaultValue {
    NSAlert *alert = [NSAlert alertWithMessageText: prompt
                                     defaultButton:@"OK"
                                   alternateButton:@"Cancel"
                                       otherButton:nil
                         informativeTextWithFormat:@""];
    
    NSTextField *input = [[NSTextField alloc] initWithFrame:NSMakeRect(0, 0, 200, 24)];
    [input setStringValue:defaultValue];
    [alert setAccessoryView:input];
    NSInteger button = [alert runModal];
    if (button == NSAlertDefaultReturn) {
        [input validateEditing];
        return [input stringValue];
    } else if (button == NSAlertAlternateReturn) {
        return nil;
    } else {
        NSAssert1(NO, @"Invalid input dialog button %d", button);
        return nil;
    }
}

- (BOOL) getBasicConfiguration {
    NSString * input = [self input:@"Enter User ID" defaultValue:@""];
    if (input != nil ) {
        NSNumberFormatter * f = [[NSNumberFormatter alloc] init];
        [f setNumberStyle:NSNumberFormatterDecimalStyle];
        NSNumber * uid = [f numberFromString:input];
        [f release];
        if (uid != nil) {
            [PersistantData saveItemToPreferences:uid withKey:DATA_KEY_USER_ID];
            [PersistantData saveItemToPreferences:@"YES" withKey:DATA_KEY_CONFIGURED];
            return YES;
        }
    }
    return NO;
}

- (void) awakeFromNib {
    [self setUi];
    if ([PersistantData retrieveFromUserDefaults:DATA_KEY_CONFIGURED] == nil) {
        if ([self getBasicConfiguration]) {
            [self runUpdateManager];
        }
        else {
            NSLog(@"DAMN");
        }
    }
    [self runUpdateManager];
}

@end
