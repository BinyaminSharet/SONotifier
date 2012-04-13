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

enum {
    SM_INDEX_NAME,
    SM_INDEX_REPUTATION,
    SM_INDEX_SEPARATOR_1,
    SM_INDEX_EXTENDED_INFO,
    SM_INDEX_REPUTATION_CHANGES,
    SM_INDEX_NEW_QUESTIONS,
    SM_INDEX_SEPARATOR_2,
    SM_INDEX_ONLINE_STATUS,
    SM_INDEX_SETTINGS,
    SM_INDEX_QUIT,
};

- (void) initStatusItem {
    NSString* imageName = [[NSBundle mainBundle] pathForResource:@"stackoverflow" ofType:@"png"];
    NSImage* imageObj = [[NSImage alloc] initWithContentsOfFile:imageName];
    [statusItem setImage:imageObj];
    [imageObj release];
    [statusItem setHighlightMode:YES];
    [statusItem setEnabled:YES];
    [statusItem setTarget:self];
}

- (void) showSettings {
    NSLog(@"Settings are shown");
}

- (void) quitApp {
    [NSApp terminate:nil];
}

- (void) initMenuItems {
    NSMenuItem * currentItem = nil;
    NSMenu * menu = [[[NSMenu alloc] init] autorelease];
    [menu setAutoenablesItems:NO];
    
    LinkMenuItem * nameItem = [[LinkMenuItem alloc] init];
    [menu addItem:nameItem];// name
    [nameItem release];
    
    currentItem = [[NSMenuItem alloc] init];
    [menu addItem:currentItem];// reputation
    [menu setSubmenu:[[[NSMenu alloc] initWithTitle:@""] autorelease] forItem:currentItem];    
    [currentItem release];
    
    [menu addItem:[NSMenuItem separatorItem]];
    
    currentItem = [[NSMenuItem alloc] initWithTitle:@"Extended Info" action:nil keyEquivalent:@""];
    [menu addItem:currentItem];
    [menu setSubmenu:[[[NSMenu alloc] initWithTitle:@""] autorelease] forItem:currentItem];
    [currentItem release];
    
    currentItem = [[NSMenuItem alloc] initWithTitle:@"Rep Changes" action:nil keyEquivalent:@""];
    [menu addItem:currentItem];
    [menu setSubmenu:[[[NSMenu alloc] initWithTitle:@""] autorelease] forItem:currentItem];
    [currentItem release];
    
    currentItem = [[NSMenuItem alloc] initWithTitle:@"New Questions" action:nil keyEquivalent:@""];
    [menu addItem:currentItem];
    [menu setSubmenu:[[[NSMenu alloc] initWithTitle:@""] autorelease] forItem:currentItem];
    [currentItem release];
    
    [menu addItem:[NSMenuItem separatorItem]];
    
    currentItem = [[NSMenuItem alloc] initWithTitle:@"Offline" action:nil keyEquivalent:@""];
    [currentItem setEnabled: NO];
    [menu addItem:currentItem];
    [currentItem release];
    
    currentItem = [[NSMenuItem alloc] initWithTitle:@"Settings" action:@selector(showSettings) keyEquivalent:@""];
    [currentItem setTarget:self];
    [currentItem setEnabled:YES];
    [menu addItem:currentItem];
    [currentItem release];
    
    currentItem = [[NSMenuItem alloc] initWithTitle:@"Quit" action:@selector(quitApp) keyEquivalent:@""];
    [currentItem setTarget:self];
    [currentItem setEnabled:YES];
    [menu addItem:currentItem];
    [currentItem release];
    
    [statusItem setMenu:menu];
}

- (void) updateUiForFailingWithProblem:(NSNumber *)number {
    UPDATE_PROBLEMS problem = (UPDATE_PROBLEMS)[number intValue];
    switch(problem) {
        case UPDATE_PROBLEM_CONNECTION:
            [[[statusItem menu] itemAtIndex:SM_INDEX_ONLINE_STATUS] setTitle:@"Offline"];
            break;
        case UPDATE_PROBLEM_NOT_ONLINE_YET:
            [[[statusItem menu] itemAtIndex:SM_INDEX_ONLINE_STATUS] setTitle:@"Connecting"];
            break;
    }
}

- (void) updateFailedForProblem:(UPDATE_PROBLEMS)problem {
    NSNumber * number = [NSNumber numberWithInt:problem];
    [self performSelectorOnMainThread:@selector(updateUiForFailingWithProblem:) withObject:number waitUntilDone:NO];
}

- (void) updateExtendedReputationInfoWithData:(UserData *) data {
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

- (void) updateExtendedInfoWithData:(UserData *) data {
    NSMenu * extendedInfoMenu = [[[statusItem menu] itemAtIndex:SM_INDEX_EXTENDED_INFO] submenu];
    NSString * currentTitle;
    [extendedInfoMenu setAutoenablesItems:NO];
    [extendedInfoMenu removeAllItems];
    currentTitle = [NSString stringWithFormat:@"Gold Badges:\t%@", [data badgesGold]];
    [extendedInfoMenu addItem:[[[NSMenuItem alloc] initWithTitle:currentTitle action:nil keyEquivalent:@""] autorelease]];
    currentTitle = [NSString stringWithFormat:@"Silver Badges:\t%@", [data badgesSilver]];
    [extendedInfoMenu addItem:[[[NSMenuItem alloc] initWithTitle:currentTitle action:nil keyEquivalent:@""] autorelease]];
    currentTitle = [NSString stringWithFormat:@"Bronze Badges:\t%@", [data badgesBronze]];
    [extendedInfoMenu addItem:[[[NSMenuItem alloc] initWithTitle:currentTitle action:nil keyEquivalent:@""] autorelease]];
}

- (void) updateUiWithUserData:(UserData *) data {
    NSMenu * menu = [statusItem menu];
    NSString * currentTitle;
    NSMenu * currentSubMenu;
    // username
    currentTitle = [data username];
    LinkMenuItem * nameItem = (LinkMenuItem*)[menu itemAtIndex:SM_INDEX_NAME];
    [nameItem setUrl:[NSString stringWithFormat:@"http://www.stackoverflow.com/users/%@", 
                      [PersistantData retrieveFromUserDefaults:DATA_KEY_USER_ID]]];
    [nameItem setAction:@selector(openUrl:)];
    [nameItem setEnabled:YES];
    [nameItem setTarget:nameItem];
    [nameItem setTitle:currentTitle];
    // reputation
    currentTitle = [NSString stringWithFormat:@"Rep: %@", [data reputation]];
    [[menu itemAtIndex:SM_INDEX_REPUTATION] setTitle:currentTitle];
    [self updateExtendedReputationInfoWithData:data];
    // connection status
    currentTitle = @"Online";
    [[menu itemAtIndex:SM_INDEX_ONLINE_STATUS] setTitle:currentTitle];
    // extended info
    [self updateExtendedInfoWithData:data];
    // reputation changes
    NSNumber * repOffset = [data reputationOffset];
    if ([repOffset intValue] != 0)
        currentTitle = [NSString stringWithFormat:@"(%@) Rep Changes", repOffset];
    else
        currentTitle = @"Rep Changes";
    [[menu itemAtIndex:SM_INDEX_REPUTATION_CHANGES] setTitle:currentTitle];
    
    currentSubMenu = [[menu itemAtIndex:SM_INDEX_REPUTATION_CHANGES] submenu];
    [currentSubMenu setAutoenablesItems:NO];
    [currentSubMenu removeAllItems];
    NSArray * reputationChangeArray = [data reputationFromAnswers];
    int counter = 0;
    for (NSDictionary * dict in reputationChangeArray) {
        if (counter++ == 7)
            break; // up to 7 results
        LinkMenuItem * currentLinkMenuItem = [[[LinkMenuItem alloc] initFromDictionary:dict] autorelease];
        [currentSubMenu addItem:currentLinkMenuItem];
    }
}

- (void) updateUiWithSiteData:(SiteData *) data {
    NSMenu * menu = [[[statusItem menu] itemAtIndex:SM_INDEX_NEW_QUESTIONS] submenu];
    [menu removeAllItems];
    NSArray * newestQuestionsArray = [data newestQuestions];
    int counter = 0;
    for (NSDictionary * dict in newestQuestionsArray) {
        if (counter++ == 7)
            break;
        QuestionMenuItem * currentQuestionItem = [[[QuestionMenuItem alloc] initFromDictionary:dict] autorelease];
        [menu addItem:currentQuestionItem];
    }
}
- (void) updateCompletedWithUpdater:(id)updater {
    [self performSelectorOnMainThread:@selector(updateUiWithUserData:) 
                           withObject:[(UpdateManager*)updater userData] waitUntilDone:NO];
    [self performSelectorOnMainThread:@selector(updateUiWithSiteData:) 
                           withObject:[(UpdateManager*)updater siteData] waitUntilDone:NO];
}

- (void) buildUi {
    [self initStatusItem];
    [self initMenuItems];
}

- (id) init {
    self = [super init];
    if (self) {
        statusItem = [[[NSStatusBar systemStatusBar]
                       statusItemWithLength:NSVariableStatusItemLength]
                      retain];
        
    }
    return self;
}

@end
