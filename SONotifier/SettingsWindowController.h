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

#import <Cocoa/Cocoa.h>

enum SETTING_UPDATE_FLAGS 
{
    SETTINGS_USER_ID_CHANGED            = 0x00000001,
    SETTINGS_UPDATE_INTERVAL_CHANGED    = 0x00000002,
    SETTINGS_LAUNCH_ONSTART_CHANGED     = 0x00000004,
};
@protocol SettingsWindowDelegate <NSObject>

- (void) dataUpdated:(NSInteger)updateFlags;

@end
@interface SettingsWindowController : NSWindowController <NSWindowDelegate, NSTableViewDelegate, NSTableViewDataSource>{
    IBOutlet NSButton *launchAtStartUp;
    IBOutlet NSTextField *favoriteTags;
    IBOutlet NSTextField *userId;
    IBOutlet NSTextField *updateIntervals;
    IBOutlet NSWindow *window;
    IBOutlet NSTableView *sitesTable;
    NSInteger storedLaunchState;
    NSNumber * intervals;
    NSNumber * storedUserId;
    NSInteger selectedSiteIndex;
    NSMutableArray * _siteArray;
}

@property (nonatomic, retain) NSObject<SettingsWindowDelegate> * delegate;
@property (nonatomic, retain) NSMutableArray * sitesArray;

- (BOOL)windowShouldClose:(id)sender;
- (id)tableView:(NSTableView *)aTableView objectValueForTableColumn:(NSTableColumn *)aTableColumn row:(NSInteger)rowIndex;
- (NSInteger)numberOfRowsInTableView:(NSTableView *)tableView;
- (IBAction)columnChangeSelected:(id)sender;

@end
