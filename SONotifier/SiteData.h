//
//  SiteData.h
//  SONotifier
//
//  Created by Sharet, Binyamin on 4/13/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface SiteData : NSObject {
    
}

@property (nonatomic, readonly) NSMutableArray * newestQuestions;

- (BOOL) updateNewsetQuestionsFromJsonString:(NSString *) jsonString;
@end
