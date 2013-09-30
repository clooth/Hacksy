//
//  HNParser.m
//  Hacksy
//
//  Created by Nico Hämäläinen on 9/27/13.
//  Copyright (c) 2013 Nico Hämäläinen. All rights reserved.
//

#import "HNParser.h"
#import <hpple/TFHpple.h>

@implementation HNParser

- (NSMutableArray *)parseStoriesFromReponse:(NSString *)response
{
    NSMutableArray *stories = [NSMutableArray new];

    NSError *error = nil;
    NSData  *data  = [response dataUsingEncoding:NSUTF8StringEncoding];

    TFHpple *doc   = [TFHpple hppleWithHTMLData:data];

    TFHppleElement *bodyElement = [[doc searchWithXPathQuery:@"//body"] firstObject];

    NSLog(@"%@", [doc data]);

    return nil;
}

@end
