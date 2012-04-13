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

#import "LinkMenuItem.h"
#import "Globals.h"

@implementation LinkMenuItem
@synthesize url;

- (NSAttributedString *) createTitleFromDictionary:(NSDictionary *)dict {
    NSString * simpleString;
    NSMutableAttributedString * finalStr;
    NSDictionary * attributes;
    NSColor * repColor;
    NSNumber * reputation = [dict objectForKey:API_KEY_REPUTATION_CHANGE];
    repColor = ([reputation intValue] > 0) ? [NSColor greenColor] : [NSColor redColor];
    attributes = [[NSDictionary alloc] initWithObjectsAndKeys:
                  [NSFont fontWithName:@"Helvetica" size:12], NSFontAttributeName, 
                  repColor, NSForegroundColorAttributeName,
                  nil];
    simpleString = [NSString stringWithFormat:@"%@  \t%@", reputation, [dict objectForKey:API_KEY_REPUTATION_TITLE]];
    if ([simpleString length] > 60) {
        simpleString = [NSString stringWithFormat:@"%@...", 
                        [simpleString substringToIndex:57]];
    }
    finalStr = [[NSMutableAttributedString alloc] initWithString:simpleString];
    [finalStr setAttributes:attributes range:NSMakeRange(0, 4)];
    [attributes release];
    [finalStr autorelease];
    return finalStr;
}

- (id) initFromDictionary:(NSDictionary *) dict {
    self = [super init];
    if (self) {
        NSAttributedString * ftitle = [self createTitleFromDictionary:dict];
        [self setAttributedTitle:ftitle];
        [self setUrl:[NSString stringWithFormat:@"http://www.stackoverflow.com/questions/%@",
                      [dict objectForKey:@"post_id"]]];
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
