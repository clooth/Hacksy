//
//  HNConnection.h
//  Hacksy
//
//  Created by Nico Hämäläinen on 9/27/13.
//  Copyright (c) 2013 Nico Hämäläinen. All rights reserved.
//

#import <AFNetworking/AFNetworking.h>
#import "HNConnectionDelegate.h"

typedef enum {
    Top,
    Comments,
    New,
    Ask,
    Best,
    Active,
    NoobStories,
    Favorites
} HNCategoryIdentifier;

@interface HNConnection : NSObject

@property (unsafe_unretained) id<HNConnectionDelegate> delegate;

@property (nonatomic, assign) HNCategoryIdentifier categoryIdentifier;
@property (nonatomic, strong) NSString *requestURL;
@property (nonatomic, strong) NSString *requestMethod;
@property (nonatomic, strong) NSDictionary *requestParameters;
@property (nonatomic, strong) AFHTTPRequestOperation *requestOperation;

+ (id)connectionWithCategory:(HNCategoryIdentifier)theCategory;
+ (id)connectionWithCategory:(HNCategoryIdentifier)theCategory parameters:(NSDictionary *)theParameters;

- (void)startRequest;
- (void)cancelRequest;

@end
