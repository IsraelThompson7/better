//
//  WordListViewController.m
//  StudyDictionary
//
//  Created by James Weinert on 4/23/11.
//  Copyright 2011 Weinert Works. All rights reserved.
//

#import "WordListViewController.h"
#import "StudyDictionaryAppDelegate.h"
#import "StudyDictionaryConstants.h"
#import "List.h"


@implementation WordListViewController

#pragma mark -
#pragma mark View lifecycle

- (void)viewDidLoad {
    [super viewDidLoad];
}


- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
}


#pragma mark -
#pragma mark Editing Table Rows

- (void)setEditing:(BOOL)editing animated:(BOOL)animated {
    [super setEditing:editing animated:animated];
    
	// Don't show the Back button while editing.
	[self.navigationItem setHidesBackButton:editing animated:YES];
    
	
	[self.tableView beginUpdates];
	
    NSUInteger count = [lists count];
    
    NSArray *listInsertIndexPath = [NSArray arrayWithObject:[NSIndexPath indexPathForRow:count inSection:0]];
    
    UITableViewRowAnimation animationStyle = UITableViewRowAnimationNone;
	if (editing) {
		if (animated) {
			animationStyle = UITableViewRowAnimationFade;
		}
		[self.tableView insertRowsAtIndexPaths:listInsertIndexPath withRowAnimation:animationStyle];
	}
	else {
        [self.tableView deleteRowsAtIndexPaths:listInsertIndexPath withRowAnimation:UITableViewRowAnimationFade];
    }
    
    [self.tableView endUpdates];
	
	// If editing is finished, save the managed object context.
	
	if (!editing) {
		StudyDictionaryAppDelegate *appDelegate = [[UIApplication sharedApplication] delegate];
        NSManagedObjectContext *context = [appDelegate managedObjectContext];
		NSError *error = nil;
		if (![context save:&error]) {
			NSLog(@"%@ %@, %@", kErrorUnableToDeleteList, error, [error userInfo]);
            
            NSString *message = [[NSString alloc] initWithString:kErrorCoreDataMessageForUser];
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Error" message:message delegate:self cancelButtonTitle:@"Ok" otherButtonTitles:nil];
            
            [alert show];
		}
	}
    
}


#pragma mark -
#pragma mark Memory management

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

- (void)viewDidUnload {
}




@end