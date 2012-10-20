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

#import "UpdateManager.h"
#import "PersistantData.h"
#import "SEApi.h"

@implementation UpdateManager

@synthesize updateDelegate;
@synthesize userData;
@synthesize siteData;
@synthesize userId;
@synthesize siteName;

- (id) init 
{
    self = [super init];
    if (self) 
    {
        updateTimer = nil;
        self.userData = [[[UserData alloc] init] autorelease];
        self.siteData = [[[SiteData alloc] init] autorelease];
    }
    return self;
}

- (void) dealloc 
{
    [updateTimer invalidate];
    updateTimer = nil;
    self.userData = nil;
    self.siteData = nil;
    [super dealloc];
}

- (NSString *) buildNewQuestionQuery 
{
    NSString * res = [NSString stringWithFormat:@"/questions?page=1&pagesize=10&order=desc&sort=activity&site=%@&filter=%@", 
                      siteName, API_20_FILTER_QUESTIONS];
    return res;
}

- (BOOL) fetchUserInfoFromServer
{
    NSString * apiRequest;
    NSString * responseStr;    
    NSLog(@"[UpdateManager/bgUpdate] Getting user info");    
    apiRequest = [NSString stringWithFormat:@"/users/%@?site=%@", userId, siteName];
    responseStr = [SEApi getDataForApiRequest:apiRequest];
    if (responseStr != nil)
    {
        if ([userData updateInfoFromJsonString:responseStr]) 
        {
            [PersistantData saveItemToPreferences:responseStr withKey:DATA_KEY_USER_INFO];
            return NO;
        }
    } 
    return YES;
}

- (BOOL) fetchLatestBadgesFromServer
{
    NSString * apiRequest;
    NSString * responseStr;    
    NSLog(@"[UpdateManager/bgUpdate] Getting user latest badges");    
    //badges for the last week
    NSTimeInterval interval = [[NSDate date ]timeIntervalSince1970];
    interval = interval - (7 * 24 * 60 * 60);    
    apiRequest = [NSString stringWithFormat:@"/users/%@/badges?order=desc&min=%.0f&sort=awarded&site=%@", userId, interval, siteName];
    responseStr = [SEApi getDataForApiRequest:apiRequest];
    if (responseStr != nil)
    {
        if ([userData updateBadgesFromJsonString:responseStr]) 
        {
            [PersistantData saveItemToPreferences:responseStr withKey:DATA_KEY_BADGES_INFO];
            return NO;
        }
    } 
    return YES;
}

- (BOOL) fetchReputationChangesFromServer
{
    NSString * apiRequest;
    NSString * responseStr;
    NSLog(@"[UpdateManager/bgUpdate] Getting reputation changes");    
    apiRequest = [NSString stringWithFormat:@"/users/%@/reputation?page=1&pagesize=14&site=%@&filter=!amIOctbmUQ-Bx0", userId, siteName];
    responseStr = [SEApi getDataForApiRequest:apiRequest];
    
    if (responseStr != nil)
    {
        if ([userData updateLastChangesFromJsonString:responseStr])
        {
            [PersistantData saveItemToPreferences:responseStr withKey:DATA_KEY_REPUTATION_CHANGE];
            return NO;            
        }
    } 
    return YES;
}

- (BOOL) fetchNewQuestionsFromServer
{
    NSString * responseStr;
    NSLog(@"[UpdateManager/bgUpdate] Getting new questions");
    responseStr = [SEApi getDataForApiRequest:[self buildNewQuestionQuery]];
    if (responseStr != nil)
    {
        [siteData updateNewsetQuestionsFromJsonString:responseStr];
        return NO;
    } 
    return YES;
}

- (void) bgUpdate 
{
    BOOL problem = NO;
    
    problem |= [self fetchUserInfoFromServer];
    problem |= [self fetchLatestBadgesFromServer];
    problem |= [self fetchReputationChangesFromServer];
    problem |= [self fetchNewQuestionsFromServer];
    
    [updateDelegate updateCompletedWithUpdater:self];
    if (problem == YES)
    {
        [updateDelegate updateFailedForProblem:UPDATE_PROBLEM_CONNECTION];
    }
}

- (void) update 
{
    [self performSelectorInBackground:@selector(bgUpdate) withObject:nil];
    [self scheduleUpdate];
}

- (void) updateFromCommand
{
    NSLog(@"updateFromCommand called");
    [self update];
}

- (void) scheduleUpdate 
{
    [updateTimer invalidate];
    updateTimer = [NSTimer scheduledTimerWithTimeInterval:updateInterval target:self selector:@selector(update) userInfo:nil repeats:NO];
}

- (void) startRunning 
{
    NSString * savedData = [PersistantData retrieveFromUserDefaults:DATA_KEY_USER_INFO];
    if (savedData != nil) 
    {
        [userData updateInfoFromJsonString:savedData];
    }
    savedData = [PersistantData retrieveFromUserDefaults:DATA_KEY_REPUTATION_CHANGE];
    if (savedData != nil) 
    {
        [userData updateLastChangesFromJsonString:savedData];
    }
    [updateDelegate updateCompletedWithUpdater:self];
    [updateDelegate updateFailedForProblem:UPDATE_PROBLEM_NOT_ONLINE_YET]; 
    [self update];
}

- (void) setUpdateInterval:(NSTimeInterval)interval 
{
    //NSLog(@"[UpdateManager/setUpdateInterval] %f", interval);
    BOOL reschedule = updateInterval > interval;
    updateInterval = interval;
    if (reschedule) 
    {
        [self scheduleUpdate];
    }
}

@end
