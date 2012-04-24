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

#import "Utils.h"

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
	NSString * appPath = [[NSBundle mainBundle] bundlePath];
    CFURLRef url = (CFURLRef)[NSURL fileURLWithPath:appPath]; 
    LSSharedFileListRef loginItems = LSSharedFileListCreate(NULL,
                                                            kLSSharedFileListSessionLoginItems, NULL);
	if (loginItems) 
    {
		LSSharedFileListItemRef item = LSSharedFileListInsertItemURL(loginItems,
                                                                     kLSSharedFileListItemLast, NULL, NULL,
                                                                     url, NULL, NULL);
		if (item)
        {
			CFRelease(item);
        }
        CFRelease(loginItems);
	}	
}

+ (void) deleteAppFromLoginItem 
{
	NSString * appPath = [[NSBundle mainBundle] bundlePath];
    CFURLRef url = (CFURLRef)[NSURL fileURLWithPath:appPath]; 
	LSSharedFileListRef loginItems = LSSharedFileListCreate(NULL,
                                                            kLSSharedFileListSessionLoginItems, NULL);
	if (loginItems) 
    {
		UInt32 seedValue;
		NSArray  *loginItemsArray = (NSArray *)LSSharedFileListCopySnapshot(loginItems, &seedValue);
		int i;
		for(i = 0 ; i< [loginItemsArray count]; i++)
        {
			LSSharedFileListItemRef itemRef = (LSSharedFileListItemRef)[loginItemsArray
                                                                        objectAtIndex:i];
			if (LSSharedFileListItemResolve(itemRef, 0, (CFURLRef*) &url, NULL) == noErr) 
            {
				NSString * urlPath = [(NSURL*)url path];
				if ([urlPath compare:appPath] == NSOrderedSame)
                {
					LSSharedFileListItemRemove(loginItems,itemRef);
				}
			}
		}
		[loginItemsArray release];
	}
}
@end
