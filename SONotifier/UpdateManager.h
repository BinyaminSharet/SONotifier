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
#import "UserData.h"
#import "SiteData.h"

@protocol UpdateDelegate <NSObject>
typedef enum {
    UPDATE_PROBLEM_CONNECTION,
    UPDATE_PROBLEM_NOT_ONLINE_YET,
} UPDATE_PROBLEMS;
// the updater is of type UpdateManager, how do UpdateManager here? forward declaration?
- (void) updateFailedForProblem:(UPDATE_PROBLEMS)problem;
- (void) updateCompletedWithUpdater:(id)updater ;

@end

@interface UpdateManager : NSObject {
    NSTimeInterval updateInterval;
    NSTimer * updateTimer;
}

@property (nonatomic, retain) NSObject<UpdateDelegate> * updateDelegate;
@property (nonatomic, retain) UserData * userData;
@property (nonatomic, retain) SiteData * siteData;
@property (nonatomic, retain) NSNumber * userId;
@property (nonatomic, retain) NSString * siteName;

- (void) updateFromCommand;
- (void) setUpdateInterval:(NSTimeInterval)interval;
- (void) startRunning;
- (void) scheduleUpdate;
@end
