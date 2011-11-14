//
//  StudyDictionaryAppDelegate.h
//  StudyDictionary
//
//  Created by James Weinert on 2/12/11.
//  Copyright 2011 Weinert Works. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreData/CoreData.h>
#import <Wordnik/Wordnik.h>
#import <Wordnik/WNClient.h>

#import "Debug.h"

@interface StudyDictionaryAppDelegate : NSObject <UIApplicationDelegate> {
    
    UIWindow *window;
	UITabBarController *tabBarController;
    
@private
    NSManagedObjectContext *managedObjectContext_;
    NSManagedObjectModel *managedObjectModel_;
    NSPersistentStoreCoordinator *persistentStoreCoordinator_;
    
    WNClient *wordnikClient_;
}

@property (nonatomic, strong) IBOutlet UIWindow *window;
@property (nonatomic, strong) IBOutlet UITabBarController *tabBarController;

@property (nonatomic, strong, readonly) NSManagedObjectContext *managedObjectContext;
@property (nonatomic, strong, readonly) NSManagedObjectModel *managedObjectModel;
@property (nonatomic, strong, readonly) NSPersistentStoreCoordinator *persistentStoreCoordinator;

@property (nonatomic, strong, readonly) WNClient *wordnikClient_;

- (NSString *)applicationDocumentsDirectory;
- (WNClient *)wordnikClient;
- (void)saveContext;

@end

