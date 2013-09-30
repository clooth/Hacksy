//
//  HNStory.h
//  Hacksy
//
//  Created by Nico Hämäläinen on 9/27/13.
//  Copyright (c) 2013 Nico Hämäläinen. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface HNStory : NSObject

@property (nonatomic, retain) NSString* storyId;
@property (nonatomic, retain) NSString* title;
@property (nonatomic, retain) NSString* points;
@property (nonatomic, retain) NSString* createdAt;
@property (nonatomic, retain) NSString* comments;
@property (nonatomic, retain) NSString* url;

@property (nonatomic, assign) BOOL isRead;
@property (nonatomic, assign) BOOL isFavorite;

- (HNStory *)initWithDictionary:(NSMutableDictionary *)theDictionary;

- (BOOL)hasURL;

@end
