//
//  HNParser.h
//  Hacksy
//
//  Created by Nico Hämäläinen on 9/27/13.
//  Copyright (c) 2013 Nico Hämäläinen. All rights reserved.
//

#import "HNStory.h"

@interface HNParser : NSObject

- (NSMutableArray *)parseStoriesFromReponse:(NSString *)response;
- (NSMutableArray *)parseCommentsFromReponse:(NSString *)response hasURL:(BOOL)hasURL;

@end
