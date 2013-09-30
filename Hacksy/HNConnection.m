//
//  HNConnection.m
//  Hacksy
//
//  Created by Nico Hämäläinen on 9/27/13.
//  Copyright (c) 2013 Nico Hämäläinen. All rights reserved.
//

#import <CoreData/CoreData.h>
#import "HNConnection.h"
#import "AppDelegate.h"

@implementation HNConnection

@synthesize categoryIdentifier;
@synthesize requestURL;
@synthesize requestMethod;
@synthesize requestParameters;
@synthesize requestOperation;

- (id)initWithCategoryIdentifier:(HNCategoryIdentifier)theCategoryId
{
    if (self = [super init]) {
        categoryIdentifier = theCategoryId;
    }
    return self;
}

+ (id)connectionWithCategory:(HNCategoryIdentifier)anIdentifier
{
    HNConnection* connection = [[HNConnection alloc] initWithCategoryIdentifier:anIdentifier];
    [connection startRequest];
    return connection;
}

+ (id)connectionWithCategory:(HNCategoryIdentifier)anIdentifier parameters:(NSDictionary*)theParams
{
    HNConnection* connection = [[HNConnection alloc] initWithCategoryIdentifier:anIdentifier];
    [connection setRequestParameters:theParams];
    [connection startRequest];
    return connection;
}

#pragma mark - Request route handling
- (void)determineRequestURL
{
    NSString *baseURL = @"http://news.ycombinator.com/";

    switch (categoryIdentifier)
    {
        case Top:
            requestURL = baseURL;
            break;
        case New:
            requestURL = [baseURL stringByAppendingPathComponent:@"newest"];
            break;
        case Ask:
            requestURL = [baseURL stringByAppendingPathComponent:@"ask"];
            break;
        case Best:
            requestURL = [baseURL stringByAppendingPathComponent:@"best"];
            break;
        case Active:
            requestURL = [baseURL stringByAppendingPathComponent:@"active"];
            break;
        case NoobStories:
            requestURL = [baseURL stringByAppendingPathComponent:@"noobstories"];
            break;
        case Comments:
            requestURL = [baseURL stringByAppendingPathComponent:@"item"];
            break;
        case Favorites:
            requestURL = nil;
            break;
    }

    requestMethod = @"GET";
}

- (void)startRequest
{
    [self determineRequestURL];

    if (categoryIdentifier == Favorites) {
        // Loading favorites from core data
        NSManagedObjectContext *objectContext = [[AppDelegate sharedAppDelegate] managedObjectContext];

        // Get favorite entity
        NSEntityDescription *entity = [NSEntityDescription entityForName:@"FavoriteStory"
                                                  inManagedObjectContext:objectContext];

        // Create a request to fetch it
        NSFetchRequest *request = [NSFetchRequest new];
        [request setEntity:entity];

        // Fetch and sort the results
        NSMutableArray *results = [[objectContext executeFetchRequest:request error:nil] mutableCopy];
        [results sortUsingDescriptors:@[[NSSortDescriptor sortDescriptorWithKey:@"createdAt" ascending:NO]]];

        // Notify delegate object with results
        if ([self.delegate respondsToSelector:@selector(connection:didLoadFavorites:)]) {
            [self.delegate connection:self didLoadFavorites:results];
        }

        return;
    }

    if (requestParameters) {
        if ([requestMethod isEqualToString:@"GET"]) {
            [self parseRequestParameters];
        }
    }

    // Create request object
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:requestURL]];
    requestOperation = [[AFHTTPRequestOperation alloc] initWithRequest:request];

    NSLog(@"Loading stories from %@", requestURL);

    __weak HNConnection *hnconn = self;
    [requestOperation setCompletionBlockWithSuccess:^(AFHTTPRequestOperation *operation, id responseObject) {
        if ([hnconn.delegate respondsToSelector:@selector(connection:didLoadStories:)]) {
            [hnconn.delegate connection:hnconn didLoadStories:responseObject];
        }
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        NSLog(@"Failed to get stories: %@", error.localizedDescription);
    }];

    [requestOperation start];
}

- (void)parseRequestParameters
{
    int i = 0;
    for (id key in requestParameters) {
        NSString *queryStringBegin = (i == 0) ? @"?" : @"&";
        NSString *queryParamValue  = [requestParameters valueForKey:key];
        NSString *queryString = [NSString stringWithFormat:@"%@%@=%@", queryStringBegin, key, queryParamValue];
        requestURL = [requestURL stringByAppendingString:queryString];

        i++;
    }
}

@end
