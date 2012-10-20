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

#import <Foundation/Foundation.h>

@interface UserData : NSObject {
}

@property (nonatomic, retain) NSString * username;
@property (nonatomic, retain) NSNumber * reputation;
@property (nonatomic, retain) NSNumber * reputationOffset;
@property (nonatomic, retain) NSNumber * reputationDay;
@property (nonatomic, retain) NSNumber * reputationWeek;
@property (nonatomic, retain) NSNumber * reputationMonth;
@property (nonatomic, retain) NSNumber * reputationQuarter;
@property (nonatomic, retain) NSNumber * reputationYear;
@property (nonatomic, retain) NSImage * userProfileImage;
@property (nonatomic, retain) NSString * userProgileImageUrl;

@property (nonatomic, retain) NSNumber * badgesGold;
@property (nonatomic, retain) NSNumber * badgesSilver;
@property (nonatomic, retain) NSNumber * badgesBronze;
@property (nonatomic, readonly) NSMutableArray * reputationFromQuestions;
@property (nonatomic, readonly) NSMutableArray * reputationFromAnswers;
@property (nonatomic, readonly) NSMutableArray * latestBadges;


- (BOOL) updateLastChangesFromJsonString:(NSString *)jsonString;
- (BOOL) updateBadgesFromJsonString:(NSString *)jsonString;
- (BOOL) updateInfoFromJsonString:(NSString *)jsonString;

@end
