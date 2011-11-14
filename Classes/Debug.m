//
//  Debug.m
//  StudyDictionary
//
//  Created by James Weinert on 4/27/11.
//  Copyright 2011 Weinert Works. All rights reserved.
//

#import "Debug.h"
#import "StudyDictionaryAppDelegate.h"
#import "StudyDictionaryConstants.h"
#import "List.h"
#import "Word.h"


@implementation Debug


+ (void)printCoreDataObjects {
    StudyDictionaryAppDelegate *appDelegate = [[UIApplication sharedApplication] delegate];
	NSManagedObjectContext *context = [appDelegate managedObjectContext];
	
	NSEntityDescription *entityDescription = [NSEntityDescription entityForName:kListEntityName inManagedObjectContext:context];
	NSFetchRequest *request = [[NSFetchRequest alloc] init];
	[request setEntity:entityDescription];
    
	NSError *error;
	NSArray *objects = [context executeFetchRequest:request error:&error];
	
	if (objects == nil) {
		NSLog(@"%@ %@, %@", kErrorUnableToLoadHistory, error, [error userInfo]);
		
	} else {	
        NSLog(@"Lists and their words");
        for (List *listObject in objects) {            
            NSLog(@"-%@", listObject.listName);
            for (Word *wordObject in listObject.listContents) {
                NSLog(@"--%@", wordObject.word);
            }
        }
    }
    
    
    entityDescription = [NSEntityDescription entityForName:kWordEntityName inManagedObjectContext:context];
	request = [[NSFetchRequest alloc] init];
	[request setEntity:entityDescription];
    
	objects = [context executeFetchRequest:request error:&error];
	
	if (objects == nil) {
		NSLog(@"%@ %@, %@", kErrorUnableToLoadHistory, error, [error userInfo]);
		
	} else {	
        NSLog(@"Words and their Lists");
        for (Word *wordObject in objects) {      
            NSLog(@"-%@", wordObject.word);
            for (List *listObject in wordObject.belongsToList) {
                NSLog(@"--%@", listObject.listName);
            }
        }
    }
    
}

@end
