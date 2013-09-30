//
//  HNStory.m
//  Hacksy
//
//  Created by Nico Hämäläinen on 9/27/13.
//  Copyright (c) 2013 Nico Hämäläinen. All rights reserved.
//

#import "HNStory.h"

@implementation HNStory

@synthesize storyId;
@synthesize title;
@synthesize points;
@synthesize createdAt;
@synthesize comments;
@synthesize url;
@synthesize isRead;
@synthesize isFavorite;

- (HNStory *)initWithDictionary:(NSMutableDictionary *)theDictionary
{
    if (self = [super init]) {
        storyId   = [theDictionary valueForKey:@"id"];
        title     = [theDictionary valueForKey:@"title"];
        points    = [theDictionary valueForKey:@"points"];
        comments  = [theDictionary valueForKey:@"comments"];
        createdAt = [theDictionary valueForKey:@"createdAt"];
        url       = [theDictionary valueForKey:@"url"];
    }

    return self;
}

- (BOOL)hasURL
{
    return [url hasPrefix:@"http://news.ycombinator.com"];
}

@end
