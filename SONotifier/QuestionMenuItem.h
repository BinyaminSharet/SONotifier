//
//  QuestionMenuItem.h
//  SONotifier
//
//  Created by Sharet, Binyamin on 4/13/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <AppKit/AppKit.h>

@interface QuestionMenuItem : NSMenuItem {
    
}

@property (nonatomic, retain) NSString * url;

- (id) initFromDictionary:(NSDictionary *) dict;
- (IBAction)openUrl:(id)sender;
@end
