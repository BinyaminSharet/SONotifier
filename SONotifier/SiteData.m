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

#import "SiteData.h"
#import "Globals.h"

@implementation SiteData

@synthesize newestQuestions;

- (id) init 
{
    self = [super init];
    if (self) 
    {
        newestQuestions = [[NSMutableArray alloc] init];
    }
    return self;
}

- (BOOL) updateNewsetQuestionsFromJsonString:(NSString *) jsonString 
{
    NSError *jsonParsingError = nil;
    NSDictionary *data = [NSJSONSerialization JSONObjectWithData:[jsonString dataUsingEncoding:NSUTF8StringEncoding] 
                                                         options:0 error:&jsonParsingError];
    if (data) 
    {
        NSArray * qArray = [data objectForKey:@"items"];
        [newestQuestions removeAllObjects];
        [newestQuestions addObjectsFromArray:qArray];
        return YES;
    }
    return NO;
}

@end
