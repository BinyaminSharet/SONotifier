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

- (id) init {
    self = [super init];
    if (self) {
        reputationFromAnswers = [[NSMutableArray alloc] init];
        reputationFromQuestions = [[NSMutableArray alloc] init];
        username = @"--";
        reputation = [NSNumber numberWithInt:0];
    }
    return self;
}

- (BOOL) updateLastChangesFromJsonString:(NSString *)jsonString {
    NSError *jsonParsingError = nil;
    NSDictionary *data = [NSJSONSerialization JSONObjectWithData:[jsonString dataUsingEncoding:NSUTF8StringEncoding] 
                                                         options:0 error:&jsonParsingError];
    if (data) {
        NSArray * repArray = [data objectForKey:@"items"];
        [reputationFromAnswers removeAllObjects];
        [reputationFromQuestions removeAllObjects];
        for (NSDictionary * dict in repArray) {
            if ([(NSNumber*)[dict objectForKey:API_KEY_REPUTATION_CHANGE] compare:[NSNumber numberWithInt:0]] != NSOrderedSame) {
                if ([(NSString*)[dict objectForKey:@"post_type"] compare:@"answer"] == NSOrderedSame) {
                    [reputationFromAnswers addObject:dict];
                }
                else if ([(NSString*)[dict objectForKey:@"post_type"] compare:@"question"] == NSOrderedSame) {
                    [reputationFromQuestions addObject:dict];
                }
            }
        }
        return YES;
    }
    return NO;
}

- (BOOL) updateInfoFromJsonString:(NSString *)jsonString {
    NSError *jsonParsingError = nil;
    NSDictionary *data = [NSJSONSerialization JSONObjectWithData:[jsonString dataUsingEncoding:NSUTF8StringEncoding] 
                                                         options:0 error:&jsonParsingError];
    if (data) {
        NSNumber * prevReputation = reputation;
        data = [[data objectForKey:@"items"] objectAtIndex:0];

        [self setUsername:[data objectForKey:API_KEY_USER_NAME]];
        [self setReputation:[data objectForKey:API_KEY_USER_REPUTATION]];
        [self setReputationDay:[data objectForKey:API_KEY_USER_REP_DAY]];
        [self setReputationWeek:[data objectForKey:API_KEY_USER_REP_WEEK]];
        [self setReputationMonth:[data objectForKey:API_KEY_USER_REP_MONTH]];
        [self setReputationQuarter:[data objectForKey:API_KEY_USER_REP_QUARTER]];
        [self setReputationYear:[data objectForKey:API_KEY_USER_REP_YEAR]];
        [self setReputationOffset:[NSNumber numberWithInt:[reputation intValue] - [prevReputation intValue]]];
        
        // badge count
        data = [data objectForKey:API_KEY_USER_BADGES_DICT];
        [self setBadgesGold:[data objectForKey:API_KEY_USER_BADGE_GOLD]];
        [self setBadgesSilver:[data objectForKey:API_KEY_USER_BADGE_SILVER]];
        [self setBadgesBronze:[data objectForKey:API_KEY_USER_BADGE_BRONZE]];
        return YES;
    }
    return NO;
}

@end
