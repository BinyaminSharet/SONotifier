//
//  QuestionMenuItem.m
//  SONotifier
//
//  Created by Sharet, Binyamin on 4/13/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "QuestionMenuItem.h"
#import "Globals.h"

@implementation QuestionMenuItem
@synthesize url;

- (NSString *) createTitleFromDictionary:(NSDictionary *) dict {
    NSString * title = [dict objectForKey:API_KEY_QUESTION_TITLE];
    if ([title length] > 60) {
        title = [NSString stringWithFormat:@"%@...", 
                        [title substringToIndex:57]];
    }
    return title;
}

- (id) initFromDictionary:(NSDictionary *) dict {
    self = [super init];
    if (self) {
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
