//
//  AppDelegate.h
//  Hacksy
//
//  Created by Nico Hämäläinen on 9/27/13.
//  Copyright (c) 2013 Nico Hämäläinen. All rights reserved.
//


#import <Reachability/Reachability.h>
#import "HNStory.h"
#import "HNConnection.h"

@interface AppDelegate : UIResponder <UIApplicationDelegate, HNConnectionDelegate>

@property (strong, nonatomic) UIWindow *window;

// HN Connections
@property (nonatomic, assign) HNCategoryIdentifier categoryIdentifier;
@property (nonatomic, strong) HNConnection *hnConnection;

// Core data
@property (nonatomic, strong) NSManagedObjectModel *managedObjectModel;
@property (nonatomic, strong) NSManagedObjectContext *managedObjectContext;
@property (nonatomic, strong) NSPersistentStoreCoordinator *persistentStoreCoordinator;

// Other
@property (nonatomic, assign) BOOL iCloudReady;

// Singleton
+ (AppDelegate *)sharedAppDelegate;

@end
