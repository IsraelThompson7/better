//
//  StudyDictionaryAppDelegate.m
//  StudyDictionary
//
//  Created by James Weinert on 2/12/11.
//  Copyright 2011 Weinert Works. All rights reserved.
//

#import "StudyDictionaryAppDelegate.h"
#import "StudyDictionaryConstants.h"
#import "StudyDictionaryAPIConstants.h"

@implementation StudyDictionaryAppDelegate

@synthesize window;
@synthesize tabBarController;
@synthesize wordnikClient_;


#pragma mark -
#pragma mark Application lifecycle

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {    
    [self.window addSubview:self.tabBarController.view];
    [self.window makeKeyAndVisible];
    
    return YES;
}


- (void)applicationWillResignActive:(UIApplication *)application {
    /*
     Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
     Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
     */
}


- (void)applicationDidEnterBackground:(UIApplication *)application {
    /*
     Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later. 
     If your application supports background execution, called instead of applicationWillTerminate: when the user quits.
     */
    [self saveContext];
}


- (void)applicationWillEnterForeground:(UIApplication *)application {
    /*
     Called as part of the transition from the background to the inactive state: here you can undo many of the changes made on entering the background.
     */
}


- (void)applicationDidBecomeActive:(UIApplication *)application {
    /*
     Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
     */
}


/**
 applicationWillTerminate: saves changes in the application's managed object context before the application terminates.
 */
- (void)applicationWillTerminate:(UIApplication *)application {
    [self saveContext];
}


- (void)saveContext {
    
    NSError *error = nil;
	NSManagedObjectContext *managedObjectContext = self.managedObjectContext;
    if (managedObjectContext != nil) {
        if ([managedObjectContext hasChanges] && ![managedObjectContext save:&error]) {
            NSLog(@"%@ %@, %@", kErrorUnableToSaveContext, error, [error userInfo]);
            
            NSString *message = [[NSString alloc] initWithString:kErrorCoreDataMessageForUser];
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Error" message:message delegate:self cancelButtonTitle:@"Ok" otherButtonTitles:nil];
                                  
            [alert show];
        } 
    }
}    


#pragma mark -
#pragma mark Wordnik Client

- (WNClient *)wordnikClient {
    if (wordnikClient_ != nil) {
        return wordnikClient_;
    }
    
    WNClientConfig *config = [WNClientConfig configWithAPIKey:WORDNIK_API_KEY ];
    wordnikClient_ = [[WNClient alloc] initWithClientConfig:config];
    
    /* Fetch API usage information (for testing purposes). */
    [wordnikClient_ requestAPIUsageStatusWithCompletionBlock: ^(WNClientAPIUsageStatus *status, NSError *error) {
        if (error != nil) {
            NSLog(@"%@ %@, %@", kErrorUnableToConnectToWordnik, error, [error userInfo]);
            
            NSString *message = [[NSString alloc] initWithString:kErrorWordnikErrorForUser];
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Error" message:message delegate:self cancelButtonTitle:@"Ok" otherButtonTitles:nil];
            
            [alert show];
        }
        
        NSMutableString *output = [NSMutableString string];
        [output appendFormat: @"Expires at: %@\n", status.expirationDate];
        [output appendFormat: @"Reset at: %@\n", status.resetDate];
        [output appendFormat: @"Total calls permitted: %ld\n", (long) status.totalPermittedRequestCount];
        [output appendFormat: @"Total calls remaining: %ld\n", (long) status.remainingPermittedRequestCount];
        
        NSLog(@"API Usage:\n%@", output);
    }];
    
    return wordnikClient_;
}


#pragma mark -
#pragma mark Core Data stack

/**
 Returns the managed object context for the application.
 If the context doesn't already exist, it is created and bound to the persistent store coordinator for the application.
 */
- (NSManagedObjectContext *)managedObjectContext {
    
    if (managedObjectContext_ != nil) {
        return managedObjectContext_;
    }
    
    NSPersistentStoreCoordinator *coordinator = [self persistentStoreCoordinator];
    if (coordinator != nil) {
        managedObjectContext_ = [[NSManagedObjectContext alloc] init];
        [managedObjectContext_ setPersistentStoreCoordinator:coordinator];
    }
    return managedObjectContext_;
}


/**
 Returns the managed object model for the application.
 If the model doesn't already exist, it is created from the application's model.
 */
- (NSManagedObjectModel *)managedObjectModel {
    
    if (managedObjectModel_ != nil) {
        return managedObjectModel_;
    }
    NSURL *modelURL = [[NSBundle mainBundle] URLForResource:@"StudyDictionary" withExtension:@"momd"];
    managedObjectModel_ = [[NSManagedObjectModel alloc] initWithContentsOfURL:modelURL];    
    return managedObjectModel_;
}


/**
 Returns the persistent store coordinator for the application.
 If the coordinator doesn't already exist, it is created and the application's store added to it.
 */
- (NSPersistentStoreCoordinator *)persistentStoreCoordinator {
    
    if (persistentStoreCoordinator_ != nil) {
        return persistentStoreCoordinator_;
    }
    
    NSString *storePath = [[self applicationDocumentsDirectory] stringByAppendingPathComponent:@"StudyDictionary.sqlite"];
	
	NSFileManager *fileManager = [NSFileManager defaultManager];
    
	if (![fileManager fileExistsAtPath:storePath]) {
		NSString *defaultStorePath = [[NSBundle mainBundle] pathForResource:@"StudyDictionary" ofType:@"sqlite"];
		if (defaultStorePath) {
			[fileManager copyItemAtPath:defaultStorePath toPath:storePath error:NULL];
		}
	}
    
    NSURL *storeURL = [NSURL fileURLWithPath:storePath];
    
    NSError *error = nil;
    persistentStoreCoordinator_ = [[NSPersistentStoreCoordinator alloc] initWithManagedObjectModel:[self managedObjectModel]];
    
    NSDictionary *options = [NSDictionary dictionaryWithObjectsAndKeys:
                             [NSNumber numberWithBool:YES], NSMigratePersistentStoresAutomaticallyOption,
                             [NSNumber numberWithBool:YES], NSInferMappingModelAutomaticallyOption, nil];
    
    if (![persistentStoreCoordinator_ addPersistentStoreWithType:NSSQLiteStoreType configuration:nil URL:storeURL options:options error:&error]) {
        NSLog(@"%@ %@, %@", kErrorUnableToCreatePersistentStore, error, [error userInfo]);
        
        NSString *message = [[NSString alloc] initWithString:kErrorCoreDataMessageForUser];
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Error" message:message delegate:self cancelButtonTitle:@"Ok" otherButtonTitles:nil];
        
        [alert show];
    }    
    
    return persistentStoreCoordinator_;
}


#pragma mark -
#pragma mark Application's Documents directory

/**
 Returns the path to the application's Documents directory.
 */
- (NSString *)applicationDocumentsDirectory {
	
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *basePath = ([paths count] > 0) ? [paths objectAtIndex:0] : nil;
    return basePath;
}



#pragma mark -
#pragma mark Memory management

- (void)applicationDidReceiveMemoryWarning:(UIApplication *)application {
    /*
     Free up as much memory as possible by purging cached data objects that can be recreated (or reloaded from disk) later.
     */
}




@end

