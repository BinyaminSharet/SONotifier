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
 *
 * The methods addAppAsLoginItem and deleteAppFromLoginItem were taken from
 * http://cocoatutorial.grapewave.com/tag/lssharedfilelist-h/
 */

#import <ServiceManagement/ServiceManagement.h>
#import "Utils.h"
#import "Globals.h"

@implementation Utils

+ (NSString *) string:(NSString*)string limitedToLength:(NSInteger)maxLength 
{
    if ([string length] > maxLength) 
    {
        string = [NSString stringWithFormat:@"%@...", [string substringToIndex:maxLength - 3]];
    }
    return string;
}

+ (void) addAppAsLoginItem 
{
    NSString * bundleIdentifier = [[NSBundle mainBundle] bundleIdentifier];
    if(!SMLoginItemSetEnabled((__bridge CFStringRef)bundleIdentifier, YES)) {
        NSLog(@"Failed to add app to login items");
    }
}

+ (void) deleteAppFromLoginItem 
{
    NSString * bundleIdentifier = [[NSBundle mainBundle] bundleIdentifier];
    if(!SMLoginItemSetEnabled((__bridge CFStringRef)bundleIdentifier, NO)) {
        NSLog(@"Failed to remove app from login items");
    }
}

+ (unsigned long) getBadgeColorForType:(NSString *) type
{
    if ([type isEqualToString:API_KEY_USER_BADGE_GOLD])
    {
        return 0xFFFF00;
    }
    else if ([type isEqualToString:API_KEY_USER_BADGE_SILVER])
    {
        return 0xC0C0C0;
    }
    else if ([type isEqualToString:API_KEY_USER_BADGE_BRONZE])
    {
        return 0xFFD700;
    }
    else
    {
        return 0;
    }
}

#define MINUTE_IN_SECONDS   (60)
#define HOUR_IN_SECONDS     (MINUTE_IN_SECONDS * 60)
#define DAY_IN_SECONDS      (HOUR_IN_SECONDS * 60)
#define WEEK_IN_SECONDS     (DAY_IN_SECONDS * 7)
#define MONTH_IN_SECONDS    (DAY_IN_SECONDS * 30)
#define YEAR_IN_SECONDS     (DAY_IN_SECONDS * 365)

+ (NSString *) getTimeStrForSeconds:(unsigned long)seconds
{
    int i;
    struct {
        NSString * title;
        unsigned int factor;
    } options[] = {
        {   @"year",    YEAR_IN_SECONDS     },
        {   @"month",   MONTH_IN_SECONDS    },
        {   @"week",    WEEK_IN_SECONDS     },
        {   @"day",     DAY_IN_SECONDS      },
        {   @"hour",    HOUR_IN_SECONDS     },
        {   @"minute",  MINUTE_IN_SECONDS   },
        {   @"second",  1                   },
    };
    NSString * result;
    unsigned long adjusted;

    for (i = 0; i < (sizeof(options) / sizeof(options[0])) - 1; ++i)
    {
        if (seconds > options[i].factor)
        {
            break;
        }
    }
    
    adjusted = seconds / options[i].factor;
    
    if (adjusted == 1)
    {
        if ([options[i].title isEqualToString:@"hour"])
        {
            result = @"an hour";
        }
        else 
        {
            result = [NSString stringWithFormat:@"a %@", options[i].title];
        }
    }
    else 
    {
        result = [NSString stringWithFormat:@"%lu %@s", adjusted, options[i].title];
    }
    return result;
}
@end
