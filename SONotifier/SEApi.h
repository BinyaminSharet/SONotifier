//
//  SEApi.h
//  SONotifier
//
//  Created by Sharet, Binyamin on 10/2/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface SEApi : NSObject

+ (NSString *) getDataForUrl:(NSString *)urlString;
+ (NSString *) getDataForApiRequest:(NSString *) apiRequest;
@end
