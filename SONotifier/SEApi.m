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
    dispatch_semaphore_t semaphore = dispatch_semaphore_create(0);
    NSURLRequest *request;
    __block NSString * responseStr = nil;
    NSLog(@"[SEApi/getDataForUrl:] URL: %@", urlString);
    request = [NSURLRequest requestWithURL:[NSURL URLWithString:urlString]];
    NSURLSession * session = [NSURLSession sharedSession];
    NSURLSessionDataTask * task = [session dataTaskWithRequest:request completionHandler:^(NSData * data, NSURLResponse * response, NSError * error) {
        if (data != nil)
        {
            responseStr = [[[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding] autorelease];
            responseStr = [responseStr stringByReplacingOccurrencesOfString:@"&quot;" withString:@"\\\""];
            responseStr = [responseStr stringByReplacingOccurrencesOfString:@"&#39;" withString:@"'"];
            responseStr = [responseStr stringByReplacingOccurrencesOfString:@"&#180;" withString:@"`"];
            [responseStr retain];
//            NSLog(@"[SEApi/getDataForUrl:] Received data: %@", responseStr);
        }
        dispatch_semaphore_signal(semaphore);
    }];
    [task resume];
    dispatch_semaphore_wait(semaphore, DISPATCH_TIME_FOREVER);
    dispatch_release(semaphore);

//    NSLog(@"[SEApi/getDataForUrl:] leaving, with response string of length: %u", (unsigned int)(responseStr ? -1 : [responseStr length]));
    NSString * finalResponse = [NSString stringWithString:responseStr];
    [responseStr release];
    return finalResponse;
}

+ (NSString *) getDataForApiRequest:(NSString *) apiRequest 
{
    NSString * urlString = [NSString stringWithFormat:@"%@%@&client_id=%@&key=%@", API_20_BASE_URL, apiRequest, API_20_APP_ID, API_20_APP_KEY];
    NSString * result = [self getDataForUrl:urlString];
    result = [NSString stringWithString:result];
    return result;
}


@end
