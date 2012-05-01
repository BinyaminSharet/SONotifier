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

#import "BaseMenu.h"
#import "UserData.h"
#import "LinkMenuItem.h"
#import "QuestionMenuItem.h"
#import "PersistantData.h"

@implementation BaseMenu

enum CONNECTION_STATUS {
    CONNECTION_STATUS_OFFLINE,
    CONNECTION_STATUS_ONLINE
};

enum {
    SM_INDEX_NAME,
    SM_INDEX_REPUTATION,
    SM_INDEX_BADGES,
    SM_INDEX_SEPARATOR_1,
    SM_INDEX_REPUTATION_CHANGES,
    SM_INDEX_NEW_QUESTIONS,
    SM_INDEX_SEPARATOR_2,
    SM_INDEX_CONNECTION_STATUS,
    SM_INDEX_SETTINGS,
    SM_INDEX_QUIT,
};


@synthesize delegate;
@synthesize updateManager;

- (void) setUpdateManager:(UpdateManager *)manager
{
    updateManager = manager;
    [[[statusItem menu] itemAtIndex:SM_INDEX_CONNECTION_STATUS] setTarget:updateManager];
}

- (void) setStatusIconWithImagePath:(NSString *) image_name 
{
    NSString* imageName = [[NSBundle mainBundle] pathForResource:image_name ofType:@"png"];
    NSImage* imageObj = [[[NSImage alloc] initWithContentsOfFile:imageName] autorelease];
    [statusItem setImage:imageObj];
}

- (NSAttributedString *) createConnectionStatusString
{
    NSString * status;
    NSMutableAttributedString * basicConnectionStatus;
    NSAttributedString * extendedConnectionStatus;
    NSMutableDictionary * attributes = [[[NSMutableDictionary alloc] initWithCapacity:2] autorelease];
    if (connect_status == CONNECTION_STATUS_ONLINE) 
    {
        [self setStatusIconWithImagePath:RESOURCE_NAME_ICON_ONLINE];
        status = @"Connected";
    }
    else 
    {
        [self setStatusIconWithImagePath:RESOURCE_NAME_ICON_OFFLINE];
        status = @"Disconnected";
    }
    [attributes setValue:[NSFont fontWithName:@"Helvetica" size:14] forKey:NSFontAttributeName];
    [attributes setValue:[NSColor blackColor] forKey:NSForegroundColorAttributeName];
    basicConnectionStatus = [[[NSMutableAttributedString alloc] 
                              initWithString:status 
                              attributes:attributes ] autorelease];
    
    if (lastConnectionAttempt == 0) 
    {
        status = @"no connection yet";
    }
    else
    {
        unsigned long  seconds;
        seconds = time(NULL) - lastConnectionAttempt;
        status = [NSString stringWithFormat:@" - checked %d min. ago", seconds / 60];
    }
    [attributes removeAllObjects];
    [attributes setValue:[NSFont fontWithName:@"Helvetica" size:12] forKey:NSFontAttributeName];
    [attributes setValue:[NSColor grayColor] forKey:NSForegroundColorAttributeName];    
    extendedConnectionStatus = [[[NSMutableAttributedString alloc] 
                                 initWithString:status
                                 attributes:attributes] autorelease];
    [basicConnectionStatus appendAttributedString:extendedConnectionStatus];
    return basicConnectionStatus;
}

- (void)menuWillOpen:(NSMenu *)menu
{
    NSAttributedString * connectionStatusString = [self createConnectionStatusString];
    NSMenuItem * item = [[statusItem menu] itemAtIndex:SM_INDEX_CONNECTION_STATUS];
    [item setAttributedTitle:connectionStatusString];
}

- (void) initStatusItem 
{
    [self setStatusIconWithImagePath:RESOURCE_NAME_ICON_OFFLINE];
    connect_status = CONNECTION_STATUS_OFFLINE;
    [statusItem setHighlightMode:YES];
    [statusItem setEnabled:YES];
    [statusItem setTarget:self];
}

- (void) quitApp 
{
    [NSApp terminate:nil];
}

- (void) initMenuItems 
{
    NSMenuItem * currentItem = nil;
    NSMenu * menu = [[[NSMenu alloc] init] autorelease];
    [menu setAutoenablesItems:NO];
    [menu setDelegate:self];
    
    LinkMenuItem * nameItem = [[[LinkMenuItem alloc] init] autorelease];
    [menu addItem:nameItem];// name
    
    currentItem = [[[NSMenuItem alloc] init] autorelease];
    [menu addItem:currentItem];// reputation
    [menu setSubmenu:[[[NSMenu alloc] initWithTitle:@""] autorelease] forItem:currentItem];    
    
    currentItem = [[[NSMenuItem alloc] initWithTitle:@"Extended Info" action:nil keyEquivalent:@""] autorelease];
    [menu addItem:currentItem];

    [menu addItem:[NSMenuItem separatorItem]];
        
    currentItem = [[[NSMenuItem alloc] initWithTitle:@"Rep Changes" action:nil keyEquivalent:@""] autorelease];
    [menu addItem:currentItem];
    [menu setSubmenu:[[[NSMenu alloc] initWithTitle:@""] autorelease] forItem:currentItem];
    
    currentItem = [[[NSMenuItem alloc] initWithTitle:@"New Questions" action:nil keyEquivalent:@""] autorelease];
    [menu addItem:currentItem];
    [menu setSubmenu:[[[NSMenu alloc] initWithTitle:@""] autorelease] forItem:currentItem];
    
    [menu addItem:[NSMenuItem separatorItem]];
    
    currentItem = [[[NSMenuItem alloc] initWithTitle:CONNECTION_OFFLINE action:@selector(updateFromCommand) keyEquivalent:@""] autorelease];
    [currentItem setTarget:updateManager];
    [currentItem setEnabled: YES];
    [menu addItem:currentItem];
    
    currentItem = [[[NSMenuItem alloc] initWithTitle:@"Settings" action:@selector(showSettings) keyEquivalent:@""] autorelease];
    [currentItem setTarget:delegate];
    [currentItem setEnabled:YES];
    [menu addItem:currentItem];
    
    currentItem = [[[NSMenuItem alloc] initWithTitle:@"Quit" action:@selector(quitApp) keyEquivalent:@""] autorelease];
    [currentItem setTarget:self];
    [currentItem setEnabled:YES];
    [menu addItem:currentItem];
    
    [statusItem setMenu:menu];
}

- (void) updateUiForFailingWithProblem:(NSNumber *)number 
{
    UPDATE_PROBLEMS problem = (UPDATE_PROBLEMS)[number intValue];
    switch(problem) 
    {
        case UPDATE_PROBLEM_CONNECTION:
            [[[statusItem menu] itemAtIndex:SM_INDEX_CONNECTION_STATUS] setTitle:CONNECTION_OFFLINE];
            break;
        case UPDATE_PROBLEM_NOT_ONLINE_YET:
            [[[statusItem menu] itemAtIndex:SM_INDEX_CONNECTION_STATUS] setTitle:CONNECTION_CONNECTING];
            break;
    }
    [self setStatusIconWithImagePath:RESOURCE_NAME_ICON_OFFLINE];
    connect_status = CONNECTION_STATUS_OFFLINE;
}

- (void) updateFailedForProblem:(UPDATE_PROBLEMS)problem 
{
    NSNumber * number = [NSNumber numberWithInt:problem];
    lastConnectionAttempt = time(NULL);
    [self performSelectorOnMainThread:@selector(updateUiForFailingWithProblem:) withObject:number waitUntilDone:NO];
}

- (void) updateExtendedReputationInfoWithData:(UserData *) data 
{
    NSMenu * extendedInfoMenu = [[[statusItem menu] itemAtIndex:SM_INDEX_REPUTATION] submenu]; 
    NSString * currentTitle;
    [extendedInfoMenu setAutoenablesItems:NO];
    [extendedInfoMenu removeAllItems];
    currentTitle = [NSString stringWithFormat:@"Day     \t%10d", [[data reputationDay] intValue]];
    [extendedInfoMenu addItem:[[[NSMenuItem alloc] initWithTitle:currentTitle action:nil keyEquivalent:@""] autorelease]];
    currentTitle = [NSString stringWithFormat:@"Week    \t%10d", [[data reputationWeek] intValue]];
    [extendedInfoMenu addItem:[[[NSMenuItem alloc] initWithTitle:currentTitle action:nil keyEquivalent:@""] autorelease]];
    currentTitle = [NSString stringWithFormat:@"Month  \t%10d", [[data reputationMonth] intValue]];
    [extendedInfoMenu addItem:[[[NSMenuItem alloc] initWithTitle:currentTitle action:nil keyEquivalent:@""] autorelease]];
    currentTitle = [NSString stringWithFormat:@"Quarter\t%10d", [[data reputationQuarter] intValue]];
    [extendedInfoMenu addItem:[[[NSMenuItem alloc] initWithTitle:currentTitle action:nil keyEquivalent:@""] autorelease]];
    currentTitle = [NSString stringWithFormat:@"Year    \t%10d", [[data reputationYear] intValue]];
    [extendedInfoMenu addItem:[[[NSMenuItem alloc] initWithTitle:currentTitle action:nil keyEquivalent:@""] autorelease]];
}

- (NSMutableAttributedString *) makeBadgeWithRgbColor:(unsigned long)rgb forValue:(NSNumber *)value 
{
    NSMutableAttributedString * nas;
    NSString * title;
    NSColor * color = [NSColor colorWithDeviceRed:((rgb >> 16) & 0xFF) / 255.0 
                                            green:((rgb >> 8) & 0xFF) / 255.0
                                             blue:(rgb & 0xFF) / 255.0
                                            alpha:1.0];
    title = [NSString stringWithUTF8String:TEXT_SHAPE_CSTRING_UTF8_CIRCLE_MED];
    title = [NSString stringWithFormat:@"%@ %@   ", title, [value stringValue]];
    nas = [[NSMutableAttributedString alloc] initWithString:title];
    [nas setAttributes:[NSDictionary dictionaryWithObjectsAndKeys:
                        [NSFont fontWithName:@"Helvetica" size:14], NSFontAttributeName, 
                        color, NSForegroundColorAttributeName,
                        nil]
                 range:NSMakeRange(0, 1)];
    [nas setAttributes:[NSDictionary dictionaryWithObjectsAndKeys:
                        [NSFont fontWithName:@"Helvetica" size:15], NSFontAttributeName, 
                        [NSColor blackColor], NSForegroundColorAttributeName,
                        nil]
                 range:NSMakeRange(1, [nas length]-1)];

    return [nas autorelease];
}

- (void) updateExtendedInfoWithData:(UserData *) data {
    NSMenuItem * item = [[statusItem menu] itemAtIndex:SM_INDEX_BADGES];
    NSMutableAttributedString * result = [[[NSMutableAttributedString alloc] init] autorelease];

    [result appendAttributedString:[self makeBadgeWithRgbColor:0xFFFF00 forValue:[data badgesGold]]];
    [result appendAttributedString:[self makeBadgeWithRgbColor:0xC0C0C0 forValue:[data badgesSilver]]];
    [result appendAttributedString:[self makeBadgeWithRgbColor:0xFFD700 forValue:[data badgesBronze]]];
    [item setAttributedTitle:result];    
}

- (void) updateReputationChangesWithData:(UserData *) data 
{
    NSMenu * menu = [[[statusItem menu] itemAtIndex:SM_INDEX_REPUTATION_CHANGES] submenu];
    [menu setAutoenablesItems:NO];
    [menu removeAllItems];
    NSArray * reputationChangeArray = [data reputationFromAnswers];
    int counter = 0;
    for (NSDictionary * dict in reputationChangeArray) 
    {
        if (counter++ == 7)
            break; // up to 7 results
        [menu addItem:[[[LinkMenuItem alloc] initFromDictionary:dict] autorelease]];
    }    
}

- (void) updateReputationInfoWithData:(UserData *) data 
{
    NSMenuItem * menuItem = [[statusItem menu] itemAtIndex:SM_INDEX_REPUTATION];
    NSNumber * offset;
    lastSetRep = [data reputation];
    offset = [NSNumber numberWithInt:[lastSetRep intValue] - [lastViewedRep intValue]];
    if (([offset intValue] == 0) || ([lastViewedRep intValue] == 0)) 
    {
        [menuItem setTitle:[NSString stringWithFormat:@"Rep: %@", [data reputation]]];
    }
    else 
    {
        [self setStatusIconWithImagePath:RESOURCE_NAME_ICON_UPDATE];
        [menuItem setTitle:[NSString stringWithFormat:@"Rep: %@ (%@)", [data reputation], offset]];
    }

    [self updateExtendedReputationInfoWithData:data];
}

- (void) updateUiWithUserData:(UserData *) data 
{
    NSMenu * menu = [statusItem menu];
    NSString * currentTitle;
    // username
    currentTitle = [data username];
    LinkMenuItem * nameItem = (LinkMenuItem*)[menu itemAtIndex:SM_INDEX_NAME];
    [nameItem setUrl:[NSString stringWithFormat:@"http://www.stackoverflow.com/users/%@", 
                      [PersistantData retrieveFromUserDefaults:DATA_KEY_USER_ID]]];
    [nameItem setAction:@selector(openUrl:)];
    [nameItem setEnabled:YES];
    [nameItem setTarget:nameItem];
    [nameItem setTitle:currentTitle];
    [self updateReputationInfoWithData:data];
    [[menu itemAtIndex:SM_INDEX_CONNECTION_STATUS] setTitle:CONNECTION_CONNECTED];
    [self updateExtendedInfoWithData:data];    
    [self updateReputationChangesWithData:data];
}

- (void) updateUiWithSiteData:(SiteData *) data 
{
    NSMenu * menu = [[[statusItem menu] itemAtIndex:SM_INDEX_NEW_QUESTIONS] submenu];
    [menu removeAllItems];
    NSArray * newestQuestionsArray = [data newestQuestions];
    int counter = 0;
    for (NSDictionary * dict in newestQuestionsArray) 
    {
        if (counter++ == 7)
            break;
        QuestionMenuItem * currentQuestionItem = [[[QuestionMenuItem alloc] initFromDictionary:dict] autorelease];
        [menu addItem:currentQuestionItem];
    }
}

- (void) setStatusItemOnline 
{
    [self setStatusIconWithImagePath:RESOURCE_NAME_ICON_ONLINE];
    connect_status = CONNECTION_STATUS_ONLINE;
}

- (void) performUpdateComletedOnUi:(UpdateManager*)updater 
{
    [self setStatusItemOnline];
    [self updateUiWithUserData:[updater userData]];
    [self updateUiWithSiteData:[updater siteData]];
}

- (void) updateCompletedWithUpdater:(id)updater 
{
    lastConnectionAttempt = time(NULL);
    [self performSelectorOnMainThread:@selector(performUpdateComletedOnUi:) withObject:updater waitUntilDone:NO];
}

- (void) buildUi 
{
    [self initStatusItem];
    [self initMenuItems];
}

- (id) init 
{
    self = [super init];
    if (self) 
    {
        statusItem = [[[NSStatusBar systemStatusBar] statusItemWithLength:NSVariableStatusItemLength] retain];
        lastConnectionAttempt = 0;
    }
    return self;
}

- (void)menu:(NSMenu *)menu willHighlightItem:(NSMenuItem *)item 
{
    NSInteger index = [menu indexOfItem:item];
    switch(index) 
    {
        case SM_INDEX_REPUTATION:
            [item setTitle:[NSString stringWithFormat:@"Rep: %@", lastSetRep]];
            lastViewedRep = lastSetRep;
            break;
        case SM_INDEX_REPUTATION_CHANGES:
        case SM_INDEX_NAME:
        case SM_INDEX_BADGES:
        case SM_INDEX_NEW_QUESTIONS:
        case SM_INDEX_CONNECTION_STATUS:
        case SM_INDEX_SETTINGS:
        case SM_INDEX_QUIT:
        default:
            break;
    }
}

@end
