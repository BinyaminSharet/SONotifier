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

#import "UserData.h"
#import "Globals.h"

@implementation UserData

@synthesize username;
@synthesize reputation;
@synthesize reputationOffset;
@synthesize badgesGold;
@synthesize badgesBronze;
@synthesize badgesSilver;
@synthesize reputationFromAnswers;
@synthesize reputationFromQuestions;
@synthesize reputationDay;
@synthesize reputationWeek;
@synthesize reputationMonth;
@synthesize reputationQuarter;
@synthesize reputationYear;
@synthesize latestBadges;
@synthesize userProfileImage;
@synthesize userProgileImageUrl;

- (id) init 
{
    self = [super init];
    if (self) 
    {
        reputationFromAnswers = [[NSMutableArray alloc] init];
        reputationFromQuestions = [[NSMutableArray alloc] init];
        latestBadges = [[NSMutableArray alloc] init];
        username = @"--";
        reputation = [NSNumber numberWithInt:0];
    }
    return self;
}

- (void) dealloc
{
    [reputationFromAnswers release];
    [reputationFromQuestions release];
    [latestBadges release];
    [super dealloc];
}

- (BOOL) updateLastChangesFromJsonString:(NSString *)jsonString 
{
    NSError *jsonParsingError = nil;
    NSDictionary *data = [NSJSONSerialization JSONObjectWithData:[jsonString dataUsingEncoding:NSUTF8StringEncoding] 
                                                         options:0 error:&jsonParsingError];
    if (data) 
    {
        NSArray * repArray = [data objectForKey:@"items"];
        [reputationFromQuestions removeAllObjects];
        [reputationFromAnswers removeAllObjects];
        for (NSDictionary * origDict in repArray) 
        {
            NSMutableDictionary * dict = [NSMutableDictionary dictionaryWithDictionary:origDict];
            BOOL found = NO;
            NSNumber * post_id = [dict objectForKey:API_KEY_REPUTATION_POST_ID];
            for (NSMutableDictionary * addedDict in reputationFromAnswers)
            {
                if ([post_id compare:[addedDict objectForKey:API_KEY_REPUTATION_POST_ID]] == NSOrderedSame)
                {
                    NSNumber * new_val = [NSNumber numberWithInt:
                                          [[dict objectForKey:API_KEY_REPUTATION_CHANGE] intValue] +
                                          [[addedDict objectForKey:API_KEY_REPUTATION_CHANGE] intValue]];
                    [addedDict setValue:new_val forKey:API_KEY_REPUTATION_CHANGE];
                    found = YES;
                    break;
                }
            }
            if (found == NO)
//            if ([(NSNumber*)[dict objectForKey:API_KEY_REPUTATION_CHANGE] compare:[NSNumber numberWithInt:0]] != NSOrderedSame) 
            {
                [reputationFromAnswers addObject:dict];
            }
        }
        return YES;
    }
    return NO;
}

- (BOOL) updateBadgesFromJsonString:(NSString *)jsonString 
{
    NSError *jsonParsingError = nil;
    NSDictionary *data = [NSJSONSerialization JSONObjectWithData:[jsonString dataUsingEncoding:NSUTF8StringEncoding] 
                                                         options:0 error:&jsonParsingError];
    if (data) 
    {
        NSArray * badgesArray;
        [latestBadges removeAllObjects];
        badgesArray = [data objectForKey:@"items"];
        for (NSDictionary * badgeInfo in badgesArray)
        {
            NSMutableDictionary * mDataInfo = [NSMutableDictionary dictionaryWithDictionary:badgeInfo];
            [mDataInfo removeObjectForKey:API_KEY_BADGES_USER_INFO];
            [latestBadges addObject:mDataInfo];
        }     
        return YES;
    }
    return NO;
}

- (BOOL) updateInfoFromJsonString:(NSString *)jsonString 
{
    NSError *jsonParsingError = nil;
    NSArray * userArray;
    NSDictionary *data = [NSJSONSerialization JSONObjectWithData:[jsonString dataUsingEncoding:NSUTF8StringEncoding] 
                                                         options:0 error:&jsonParsingError];
    if (data) 
    {
        NSNumber * prevReputation = reputation;
        userArray = [data objectForKey:@"items"];
        NSLog(@"%lu", [userArray count]);
        if ([userArray count] > 0) 
        {
            data = [userArray objectAtIndex:0];
            
            [self setUsername:[data objectForKey:API_KEY_USER_NAME]];
            [self setReputation:[data objectForKey:API_KEY_USER_REPUTATION]];
            [self setReputationDay:[data objectForKey:API_KEY_USER_REP_DAY]];
            [self setReputationWeek:[data objectForKey:API_KEY_USER_REP_WEEK]];
            [self setReputationMonth:[data objectForKey:API_KEY_USER_REP_MONTH]];
            [self setReputationQuarter:[data objectForKey:API_KEY_USER_REP_QUARTER]];
            [self setReputationYear:[data objectForKey:API_KEY_USER_REP_YEAR]];
            [self setReputationOffset:[NSNumber numberWithInt:[reputation intValue] - [prevReputation intValue]]];
            
            NSString * newUserProfileImageUrl = [data objectForKey:API_KEY_USER_PROFILE_PIC];
            if ([[self userProgileImageUrl] isEqualToString:newUserProfileImageUrl]==NO)
            {
                NSImage * profileImage = [[[NSImage alloc] initWithContentsOfURL:[NSURL URLWithString:newUserProfileImageUrl]] autorelease];
                [profileImage setSize:NSMakeSize(25, 25)];
                [self setUserProfileImage:profileImage];
                [self setUserProgileImageUrl:newUserProfileImageUrl];
            }
            // badge count
            data = [data objectForKey:API_KEY_USER_BADGES_DICT];
            [self setBadgesGold:[data objectForKey:API_KEY_USER_BADGE_GOLD]];
            [self setBadgesSilver:[data objectForKey:API_KEY_USER_BADGE_SILVER]];
            [self setBadgesBronze:[data objectForKey:API_KEY_USER_BADGE_BRONZE]];
            return YES;
        }
    }
    return NO;
}

@end
