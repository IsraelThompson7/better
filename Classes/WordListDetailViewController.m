//
//  WordListViewController.m
//  StudyDictionary
//
//  Created by James Weinert on 2/17/11.
//  Copyright 2011 Weinert Works. All rights reserved.
//

#import "WordListDetailViewController.h"
#import "StudyDictionaryAppDelegate.h"
#import "WordDefinitionViewController.h"
#import "StudyDictionaryConstants.h"
#import "List.h"
#import "Word.h"


@implementation WordListDetailViewController

@synthesize listContents, list;


#pragma mark -
#pragma mark View lifecycle


- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = list.listName;
}


- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    [self loadWordList];
}


- (void)loadWordList {
    NSMutableArray *listObjects = [[NSMutableArray alloc] init];
    for (Word *word in list.listContents) {
        [listObjects addObject:word];
    }
    
    if (listContents != nil) [listContents release];
    listContents = [[NSMutableArray alloc] initWithArray:listObjects];
    
    [listObjects release];
    
	[self.tableView reloadData];
}


#pragma mark -
#pragma mark Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [listContents count];
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    static NSString *CellIdentifier = @"WordListCell";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:CellIdentifier] autorelease];
    }
    
	NSUInteger row = [indexPath row]; 
    Word *word = [listContents objectAtIndex:row];
    cell.textLabel.text = word.word;
	
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
		
		Word *word = [listContents objectAtIndex:row];
        
        [context deleteObject:word];
        [listContents removeObject:word];
		
        [self.tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationFade];
        
        NSError *error = nil;
		if (![context save:&error]) {
			NSLog(@"%@ %@, %@", kErrorUnableToDeleteWord, error, [error userInfo]);
            
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
    WordDefinitionViewController *wordDefViewController = [[WordDefinitionViewController alloc] 
														   initWithNibName:@"WordDefinitionView" 
														   bundle:nil];
	
	NSUInteger row = [indexPath row];
    Word *word = [listContents objectAtIndex:row];
	wordDefViewController.wordToLookup = word;
    [self.navigationController pushViewController:wordDefViewController animated:YES];
    [wordDefViewController release];

}


#pragma mark -
#pragma mark Memory management

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}


- (void)viewDidUnload {
	self.listContents = nil;
}


- (void)dealloc {
	[listContents release];
    [super dealloc];
}


@end

