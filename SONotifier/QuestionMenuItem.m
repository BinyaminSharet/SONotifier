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

#import "QuestionMenuItem.h"
#import "Globals.h"
#import "Utils.h"

@implementation QuestionMenuItem
@synthesize url;

- (NSString *) createTitleFromDictionary:(NSDictionary *) dict 
{
    return [Utils string:[dict objectForKey:API_KEY_QUESTION_TITLE] limitedToLength:60];
}

- (id) initFromDictionary:(NSDictionary *) dict 
{
    self = [super init];
    if (self) 
    {
        NSString * title = [self createTitleFromDictionary:dict];
        [self setTitle:title];
        [self setUrl:[dict objectForKey:API_KEY_QUESTION_LINK]];
        [self setEnabled:YES];
        [self setTarget:self];
        [self setAction:@selector(openUrl:)];
    }
    return self;
}

- (IBAction)openUrl:(id)sender
{
    [[NSWorkspace sharedWorkspace] openURL:[NSURL URLWithString:[self url]]];
}
@end
