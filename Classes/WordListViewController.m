//
//  WordListViewController.m
//  StudyDictionary
//
//  Created by James Weinert on 4/23/11.
//  Copyright 2011 Weinert Works. All rights reserved.
//

#import "WordListViewController.h"
#import "StudyDictionaryAppDelegate.h"
#import "WordListDetailViewController.h"
#import "StudyDictionaryConstants.h"
#import "List.h"


@implementation WordListViewController
@synthesize table;
@synthesize lists;


#pragma mark -
#pragma mark View lifecycle


- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    [self loadLists];
    [Debug printCoreDataObjects];
}


- (void)loadLists {
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
        NSMutableArray *listObjects = [[NSMutableArray alloc] init];
        
        for (List *oneObject in objects) {            
            [listObjects addObject:oneObject];
        }
        
        if (lists != nil) [lists release];
        lists = [[NSMutableArray alloc] initWithArray:listObjects];
        
        [listObjects release];
    }
    
	[request release];
	
	[table reloadData];
}


#pragma mark -
#pragma mark Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [lists count];
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    static NSString *CellIdentifier = @"WordListCell";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:CellIdentifier] autorelease];
    }
    
	NSUInteger row = [indexPath row]; 
    List *list = [lists objectAtIndex:row];
    cell.textLabel.text = list.listName;
	
    return cell;
}


- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    return YES;
}


- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    StudyDictionaryAppDelegate *appDelegate = [[UIApplication sharedApplication] delegate];
	NSManagedObjectContext *context = [appDelegate managedObjectContext];
    
    if (editingStyle == UITableViewCellEditingStyleDelete) {
		NSUInteger row = [indexPath row];
		
		List *list = [lists objectAtIndex:row];
        
        [context deleteObject:list];
        [lists removeObject:list];
		
        [table deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationFade];
        
        NSError *error = nil;
		if (![context save:&error]) {
			NSLog(@"%@ %@, %@", kErrorUnableToDeleteList, error, [error userInfo]);
            
            NSString *message = [[NSString alloc] initWithString:kErrorCoreDataMessageForUser];
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Error" message:message delegate:self cancelButtonTitle:@"Ok" otherButtonTitles:nil];
            
            [alert show];
            [alert release];
            [message release];
		}
    }  
}


#pragma mark -
#pragma mark Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    WordListDetailViewController *wordListViewController = [[WordListDetailViewController alloc] 
														   initWithNibName:@"WordListDetailView" 
														   bundle:nil];
	
	NSUInteger row = [indexPath row];
    List *list = [lists objectAtIndex:row];
	wordListViewController.list = list;
    [self.navigationController pushViewController:wordListViewController animated:YES];
    [wordListViewController release];
    
}


#pragma mark -
#pragma mark Memory management

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

- (void)viewDidUnload {
	self.table = nil;
	self.lists = nil;
}


- (void)dealloc {
	[table release];
	[lists release];
    [super dealloc];
}


@end