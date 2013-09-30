//
//  AppDelegate.m
//  Hacksy
//
//  Created by Nico Hämäläinen on 9/27/13.
//  Copyright (c) 2013 Nico Hämäläinen. All rights reserved.
//

#import <AdSupport/AdSupport.h>
#import <CoreData/CoreData.h>
#import <KeenClient/KeenClient.h>
#import "AppDelegate.h"
#import "HNConnection.h"

@implementation AppDelegate

@synthesize window = _window;
@synthesize categoryIdentifier;
@synthesize hnConnection;
@synthesize managedObjectContext;
@synthesize persistentStoreCoordinator;
@synthesize managedObjectModel;
@synthesize iCloudReady;

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    // keen.io
    NSString *keenProjectID = @"524566c736bf5a7c2e000019";
    NSString *keenWriteKey = @"58f4a0e6f0118638445d27c4e76dcb0ed74c865eefe28421b21d93c855906277e47bbb06f8da802076ee7cb596a449c93fffda6c7a709e546463d4552d8837b2c72cd763271f90274a5e2188dcc4fc64a5678b774980352f5527a6425511656348c2bbd4e886bbd4b2831cccf3f09492";
    NSString *keenReadKey  = @"959f9676aa4bcd45418bb70d62bdaf3fb7fb2b16d9eba2f1176c9844967ff303eb8e6fab9825cc590571970d33c3323698ba022c87bcbd9240ed9ef415190735d4b5b439cc5a1905bbd70843d4692fa3d2d5fb36b6e753c8ce97b6eb66baeefed2d21a4f0568d4d81c9db213ae34415a";
    [KeenClient sharedClientWithProjectId:keenProjectID
                              andWriteKey:keenWriteKey
                               andReadKey:keenReadKey];
    [KeenClient enableLogging];

    NSString *deviceUUID = [[[ASIdentifierManager sharedManager] advertisingIdentifier] UUIDString];
    [[KeenClient sharedClient] setGlobalPropertiesDictionary:@{@"device_id": deviceUUID}];

    // track keen.io app launch
    [[KeenClient sharedClient] addEvent:@{} toEventCollection:@"app_launches" error:nil];

    // Notifications
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(iCloudStatusDidChange:)
                                                 name:@"iCloudStatusDidChange"
                                               object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(iCloudDidUpdate)
                                                 name:@"iCloudDidUpdate"
                                               object:nil];

    // default category
    categoryIdentifier = New;

    // Set up core data
    [[AppDelegate sharedAppDelegate] managedObjectContext];

    // Observe whether we're connected
    [self observeReachability];

    

    return YES;
}

- (void)load
{
    hnConnection = [HNConnection connectionWithCategory:(HNCategoryIdentifier)categoryIdentifier];
    hnConnection.delegate = self;
}

- (void)observeReachability
{
    Reachability* reach = [Reachability reachabilityWithHostname:@"news.ycombinator.com"];

    // set the blocks
    reach.reachableBlock = ^(Reachability *reach) {
        [self load];
    };

    reach.unreachableBlock = ^(Reachability *reach) {
        NSLog(@"Reachability could not connect.");
    };

    [reach startNotifier];
}

- (void)iCloudStatusDidChange:(NSNotification*)aNotification
{
    iCloudReady = YES;
    [self load];
}

- (void)iCloudDidUpdate
{
    if (categoryIdentifier == Favorites)
        [self load];
}

#pragma mark - HNconnection Delegate
- (void)connection:(HNConnection *)theConnection didLoadFavorites:(NSArray *)theFavorites
{
    NSLog(@"Loaded favorites: %@", theFavorites);
}
							
- (void)applicationWillResignActive:(UIApplication *)application
{
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application
{
    UIBackgroundTaskIdentifier taskId = [application beginBackgroundTaskWithExpirationHandler:^(void) {
        NSLog(@"Background task is being expired.");
    }];

    [[KeenClient sharedClient] uploadWithFinishedBlock:^(void) {
        [application endBackgroundTask:taskId];
    }];
}

- (void)applicationWillEnterForeground:(UIApplication *)application
{
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}

- (void)applicationDidBecomeActive:(UIApplication *)application
{
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}

- (void)applicationWillTerminate:(UIApplication *)application
{
    UIBackgroundTaskIdentifier taskId = [application beginBackgroundTaskWithExpirationHandler:^(void) {
        NSLog(@"Background task is being expired.");
    }];

    [[KeenClient sharedClient] uploadWithFinishedBlock:^(void) {
        [application endBackgroundTask:taskId];
    }];
}

// Singleton
+ (AppDelegate *)sharedAppDelegate {
    return (AppDelegate *)[[UIApplication sharedApplication] delegate];
}

// Core data

- (void)mergeChangesFrom_iCloud:(NSNotification *)notification {

	NSLog(@"Merging in changes from iCloud...");

    NSManagedObjectContext* moc = [self managedObjectContext];

    [moc performBlock:^{
        [moc mergeChangesFromContextDidSaveNotification:notification];

        [[NSNotificationCenter defaultCenter] postNotificationName:@"iCloudDidUpdate" object:nil];
    }];
}


/**
 Returns the managed object context for the application.
 If the context doesn't already exist, it is created and bound to the persistent store coordinator for the application.
 */
- (NSManagedObjectContext *)managedObjectContext {

    if (managedObjectContext != nil) {
        return managedObjectContext;
    }

    NSPersistentStoreCoordinator *coordinator = [self persistentStoreCoordinator];

    if (coordinator != nil) {
        NSManagedObjectContext* moc = [[NSManagedObjectContext alloc] initWithConcurrencyType:NSMainQueueConcurrencyType];

        [moc performBlockAndWait:^{
            [moc setPersistentStoreCoordinator: coordinator];
            [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(mergeChangesFrom_iCloud:) name:NSPersistentStoreDidImportUbiquitousContentChangesNotification object:coordinator];
        }];
        managedObjectContext = moc;
    }
    
    return managedObjectContext;
}

/**
 Returns the managed object model for the application.
 If the model doesn't already exist, it is created by merging all of the models found in the application bundle.
 */
- (NSManagedObjectModel *)managedObjectModel {

    if (managedObjectModel != nil) {
        return managedObjectModel;
    }
    managedObjectModel = [NSManagedObjectModel mergedModelFromBundles:nil];
    return managedObjectModel;
}

/**
 Returns the persistent store coordinator for the application.
 If the coordinator doesn't already exist, it is created and the application's store added to it.
 */
- (NSPersistentStoreCoordinator *)persistentStoreCoordinator {
    if((persistentStoreCoordinator != nil)) {
        return persistentStoreCoordinator;
    }

    persistentStoreCoordinator = [[NSPersistentStoreCoordinator alloc] initWithManagedObjectModel: [self managedObjectModel]];
    NSPersistentStoreCoordinator *psc = persistentStoreCoordinator;


    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        // ** Note: if you adapt this code for your own use, you MUST change this variable:
        NSString *iCloudEnabledAppID = @"org.nph.Hacksy";

        // ** Note: if you adapt this code for your own use, you should change this variable:
        NSString *dataFileName = @"Models.sqlite";

        // ** Note: For basic usage you shouldn't need to change anything else

        NSString *iCloudDataDirectoryName = @"Data.nosync";
        NSString *iCloudLogsDirectoryName = @"Logs";
        NSFileManager *fileManager = [NSFileManager defaultManager];
        NSURL* applicationDocumentsDirectory = [self applicationDocumentsDirectory];
        NSLog(@"%@", applicationDocumentsDirectory);
        NSURL *localStore = [applicationDocumentsDirectory URLByAppendingPathComponent:dataFileName];
        NSURL *iCloud = [fileManager URLForUbiquityContainerIdentifier:nil];

        if (iCloud) {
            NSLog(@"iCloud is working");

            NSURL *iCloudLogsPath = [NSURL fileURLWithPath:[[iCloud path] stringByAppendingPathComponent: iCloudLogsDirectoryName]];

            NSLog(@"iCloudEnabledAppID = %@",iCloudEnabledAppID);
            NSLog(@"dataFileName = %@", dataFileName);
            NSLog(@"iCloudDataDirectoryName = %@", iCloudDataDirectoryName);
            NSLog(@"iCloudLogsDirectoryName = %@", iCloudLogsDirectoryName);
            NSLog(@"iCloud = %@", iCloud);
            NSLog(@"iCloudLogsPath = %@", iCloudLogsPath);

            if([fileManager fileExistsAtPath:[[iCloud path] stringByAppendingPathComponent:iCloudDataDirectoryName]] == NO) {
                NSError *fileSystemError;
                [fileManager createDirectoryAtPath:[[iCloud path] stringByAppendingPathComponent:iCloudDataDirectoryName]
                       withIntermediateDirectories:YES
                                        attributes:nil
                                             error:&fileSystemError];
                if(fileSystemError != nil) {
                    NSLog(@"Error creating database directory %@", fileSystemError);
                }
            }

            NSString *iCloudData = [[[iCloud path]
                                     stringByAppendingPathComponent:iCloudDataDirectoryName]
                                    stringByAppendingPathComponent:dataFileName];

            NSLog(@"iCloudData = %@", iCloudData);

            NSMutableDictionary *options = [NSMutableDictionary dictionary];
            [options setObject:[NSNumber numberWithBool:YES] forKey:NSMigratePersistentStoresAutomaticallyOption];
            [options setObject:[NSNumber numberWithBool:YES] forKey:NSInferMappingModelAutomaticallyOption];
            [options setObject:iCloudEnabledAppID            forKey:NSPersistentStoreUbiquitousContentNameKey];
            [options setObject:iCloudLogsPath                forKey:NSPersistentStoreUbiquitousContentURLKey];

            [psc lock];

            [psc addPersistentStoreWithType:NSSQLiteStoreType
                              configuration:nil
                                        URL:[NSURL fileURLWithPath:iCloudData]
                                    options:options
                                      error:nil];

            [psc unlock];
        }
        else {
            NSLog(@"iCloud is NOT working - using a local store");

            NSFileManager *fileManager = [NSFileManager defaultManager];
            NSURL *applicationFilesDirectory = [self applicationDocumentsDirectory];
            NSError *error = nil;

            NSDictionary *properties = [applicationFilesDirectory resourceValuesForKeys:@[NSURLIsDirectoryKey] error:&error];

            if (!properties) {
                BOOL ok = NO;
                if ([error code] == NSFileReadNoSuchFileError) {
                    ok = [fileManager createDirectoryAtPath:[applicationFilesDirectory path] withIntermediateDirectories:YES attributes:nil error:&error];
                }
                if (!ok) {
                    NSLog(@"Persistent store error: %@", error.localizedDescription);
                }
            } else {
                if (![properties[NSURLIsDirectoryKey] boolValue]) {
                    NSString *failureDescription = [NSString stringWithFormat:@"Expected a folder to store application data, found a file (%@).", [applicationFilesDirectory path]];

                    NSMutableDictionary *dict = [NSMutableDictionary dictionary];
                    [dict setValue:failureDescription forKey:NSLocalizedDescriptionKey];
                    error = [NSError errorWithDomain:@"YOUR_ERROR_DOMAIN" code:101 userInfo:dict];

                    NSLog(@"Persistent store error: %@", error.localizedDescription);
                }
            }

            NSMutableDictionary *options = [NSMutableDictionary dictionary];
            [options setObject:[NSNumber numberWithBool:YES] forKey:NSMigratePersistentStoresAutomaticallyOption];
            [options setObject:[NSNumber numberWithBool:YES] forKey:NSInferMappingModelAutomaticallyOption];
            
            [psc lock];
            
            [psc addPersistentStoreWithType:NSSQLiteStoreType
                              configuration:nil
                                        URL:localStore
                                    options:options
                                      error:nil];
            [psc unlock];
            
        }
        
        dispatch_async(dispatch_get_main_queue(), ^{
            [[NSNotificationCenter defaultCenter] postNotificationName:@"iCloudStatusDidChange" object:self userInfo:nil];
        });
    });
    
    return persistentStoreCoordinator;
}

- (NSURL *)applicationDocumentsDirectory
{
    NSFileManager *fileManager = [NSFileManager defaultManager];
    NSURL *appSupportURL = [[fileManager URLsForDirectory:NSDocumentDirectory inDomains:NSUserDomainMask] lastObject];
    return appSupportURL;
}

@end
