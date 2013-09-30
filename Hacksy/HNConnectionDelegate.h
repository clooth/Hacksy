//
//  HNConnectionDelegate.h
//  Hacksy
//
//  Created by Nico Hämäläinen on 9/27/13.
//  Copyright (c) 2013 Nico Hämäläinen. All rights reserved.
//


@class HNConnection;

@protocol HNConnectionDelegate <NSObject>

@optional

- (void)connection:(HNConnection *)theConnection didLoadFavorites:(NSArray *)theFavorites;
- (void)connection:(HNConnection *)theConnection didLoadStories:(NSArray *)theStories;

@end
