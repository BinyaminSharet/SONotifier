//
//  Utils.m
//  SONotifier
//
//  Created by Sharet, Binyamin on 4/14/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "Utils.h"

@implementation Utils

+ (NSString *) decorateStringWithThreeDots: (NSString *)string limitedForLength:(NSInteger)maxLength {
    if ([string length] > maxLength) {
        string = [NSString stringWithFormat:@"%@...", [string substringToIndex:maxLength - 3]];
    }
    return string;
}
@end
