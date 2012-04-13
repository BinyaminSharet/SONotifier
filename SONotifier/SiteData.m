//
//  SiteData.m
//  SONotifier
//
//  Created by Sharet, Binyamin on 4/13/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "SiteData.h"
#import "Globals.h"

@implementation SiteData

@synthesize newestQuestions;

- (id) init {
    self = [super init];
    if (self) {
        newestQuestions = [[NSMutableArray alloc] init];
    }
    return self;
}

- (BOOL) updateNewsetQuestionsFromJsonString:(NSString *) jsonString {
    NSError *jsonParsingError = nil;
    NSDictionary *data = [NSJSONSerialization JSONObjectWithData:[jsonString dataUsingEncoding:NSUTF8StringEncoding] 
                                                         options:0 error:&jsonParsingError];
    if (data) {
        NSArray * qArray = [data objectForKey:@"items"];
        [newestQuestions removeAllObjects];
        [newestQuestions addObjectsFromArray:qArray];
        return YES;
    }
    return NO;
}

@end
