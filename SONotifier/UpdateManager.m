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

@implementation UpdateManager

@synthesize updateDelegate;
@synthesize userData;
@synthesize siteData;
@synthesize userId;

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
}

- (NSString *) getDataForUrl:(NSString *)urlString 
{
    NSURLRequest *request;
    NSData * response;
    NSString *responseStr = nil;
    NSLog(@"[UpdateManager/getDataForUrl:] URL: %@", urlString);
    request = [NSURLRequest requestWithURL:[NSURL URLWithString:urlString]];    
    response = [NSURLConnection sendSynchronousRequest:request returningResponse:nil error:nil];
    if (response != nil) 
    {
        responseStr = [[[NSString alloc] initWithData:response encoding:NSUTF8StringEncoding] autorelease];
        responseStr = [responseStr stringByReplacingOccurrencesOfString:@"&quot;" withString:@"\\\""];
        responseStr = [responseStr stringByReplacingOccurrencesOfString:@"&#39;" withString:@"'"];
        NSLog(@"Received data: %@", responseStr);
    }
    return responseStr;
}

- (NSString *) getDataForApiRequest:(NSString *) apiRequest 
{
    NSString * urlString = [NSString stringWithFormat:@"%@%@%@%@", API_20_BASE_URL, apiRequest, API_20_APP_ID, API_20_APP_KEY];
    return [self getDataForUrl:urlString];
}

- (NSString *) buildNewQuestionQuery 
{
    return [@"/questions?page=1&pagesize=10&order=desc&sort=activity&site=stackoverflow&filter=" stringByAppendingString:API_20_FILTER_QUESTIONS];
}

- (void) bgUpdate 
{
    NSString * apiRequest;
    NSString *responseStr;
    BOOL problem = NO;
    
    NSLog(@"[UpdateManager/bgUpdate] Getting user info");    
    apiRequest = [NSString stringWithFormat:@"/users/%@?site=stackoverflow", userId];
    responseStr = [self getDataForApiRequest:apiRequest];
    if (responseStr != nil)
    {
        if ([userData updateInfoFromJsonString:responseStr]) 
        {
            [PersistantData saveItemToPreferences:responseStr withKey:DATA_KEY_USER_INFO];
        }
        else 
        {
            problem = YES;
        }
    } 
    else 
    {
        problem = YES;
    }
    
    NSLog(@"[UpdateManager/bgUpdate] Getting reputation changes");    
    apiRequest = [NSString stringWithFormat:@"/users/%@/reputation?page=1&pagesize=14&site=stackoverflow&filter=!amIOctbmUQ-Bx0", userId];
    responseStr = [self getDataForApiRequest:apiRequest];

    if (responseStr != nil)
    {
        [userData updateLastChangesFromJsonString:responseStr];
        [PersistantData saveItemToPreferences:responseStr withKey:DATA_KEY_REPUTATION_CHANGE];
    } 
    else 
    {
        problem = YES;
    }
    
    NSLog(@"[UpdateManager/bgUpdate] Getting new questions");
    responseStr = [self getDataForApiRequest:[self buildNewQuestionQuery]];
    if (responseStr != nil)
    {
        [siteData updateNewsetQuestionsFromJsonString:responseStr];
    } 
    else
    {
        problem = YES;
    }
    
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
    NSLog(@"[UpdateManager/setUpdateInterval] %f", interval);
    BOOL reschedule = updateInterval > interval;
    updateInterval = interval;
    if (reschedule) 
    {
        [self scheduleUpdate];
    }
}

@end
