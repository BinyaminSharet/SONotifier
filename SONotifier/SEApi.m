//
//  SEApi.m
//  SONotifier
//
//  Created by Sharet, Binyamin on 10/2/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "SEApi.h"
#import "Globals.h"

@implementation SEApi

+ (NSString *) getDataForUrl:(NSString *)urlString 
{
    NSURLRequest *request;
    NSData * response;
    NSString *responseStr = nil;
    NSLog(@"[UpdateManager/getDataForUrl:] URL: %@", urlString);
    request = [NSURLRequest requestWithURL:[NSURL URLWithString:urlString]];    
    response = [NSURLConnection sendSynchronousRequest:request returningResponse:nil error:nil];
    if (response != nil) 
    {
        responseStr = [[[NSString alloc] initWithData:response encoding:NSUTF8StringEncoding] autorelease];
        responseStr = [responseStr stringByReplacingOccurrencesOfString:@"&quot;" withString:@"\\\""];
        responseStr = [responseStr stringByReplacingOccurrencesOfString:@"&#39;" withString:@"'"];
        responseStr = [responseStr stringByReplacingOccurrencesOfString:@"&#180;" withString:@"`"];
        //NSLog(@"Received data: %@", responseStr);
    }
    return responseStr;
}

+ (NSString *) getDataForApiRequest:(NSString *) apiRequest 
{
    NSString * urlString = [NSString stringWithFormat:@"%@%@&client_id=%@&key=%@", API_20_BASE_URL, apiRequest, API_20_APP_ID, API_20_APP_KEY];
    return [self getDataForUrl:urlString];
}


@end
