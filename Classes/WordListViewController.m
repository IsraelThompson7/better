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
#import "EditableTableViewCell.h"


@implementation WordListViewController

@synthesize table;
@synthesize editableTableViewCell, lists;


#pragma mark -
#pragma mark View lifecycle

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.title = @"Word Lists";
    
    self.tableView.allowsSelectionDuringEditing = YES;
    self.navigationItem.rightBarButtonItem = self.editButtonItem;
}


- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    [self loadLists];
    [Debug printCoreDataObjects];
}


- (void)loadLists {
    StudyDictionaryAppDelegate *appDelegate = [[UIApplication sharedApplication] delegate];
	NSManagedObjectContext *context = [appDelegate managedObjectContext];
	
	NSEntityDescription *entityDescription = [NSEntityDescription entityForName:kListEntityName inManagedObjectContext:context];
    NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"listIndex" ascending:YES];
    
	NSFetchRequest *request = [[NSFetchRequest alloc] init];
	[request setEntity:entityDescription];
    [request setSortDescriptors:[NSArray arrayWithObject:sortDescriptor]];
	    
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
    [sortDescriptor release];
	
	[table reloadData];
}


#pragma mark -
#pragma mark Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    NSUInteger count = [lists count];
    if(self.editing) {
        count++;
    }
    
    return count;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    NSUInteger row = [indexPath row]; 
    
    if (row == [lists count]) {
        static NSString *NewCellIdentifier = @"NewListCell";
        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:NewCellIdentifier];
        if (cell == nil) {
            cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:NewCellIdentifier] autorelease];
        }
        
        cell.textLabel.text = @"Add New List";
        cell.textLabel.textColor = [UIColor grayColor];
        cell.accessoryType = UITableViewCellAccessoryNone;
        
        return cell;
    }
    
    static NSString *CellIdentifier = @"ListCell";
    
    EditableTableViewCell *cell = (EditableTableViewCell *)[tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        [[NSBundle mainBundle] loadNibNamed:@"EditableTableViewCell" owner:self options:nil];
		cell = editableTableViewCell;
		self.editableTableViewCell = nil;
        cell.textField.placeholder = @"New List";
    }
    
    cell.textField.tag = row;
    List *list = [lists objectAtIndex:row];
    cell.textField.text = list.listName;
    
    return cell;
}


#pragma mark -
#pragma mark Editing Table Rows

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    NSUInteger row = [indexPath row];
    
    if (row < [lists count]) {
        List *list = [lists objectAtIndex:row];
        if ([list.listName isEqualToString:kDefaultListName])
            return NO;
    }
    
    return self.editing;
}


- (UITableViewCellEditingStyle)tableView:(UITableView *)tableView editingStyleForRowAtIndexPath:(NSIndexPath *)indexPath {
	if (indexPath.row == [lists count]) {
		return UITableViewCellEditingStyleInsert;
	}
    return UITableViewCellEditingStyleDelete;
}


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
            [alert release];
            [message release];
		}
	}
    
}


- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
	StudyDictionaryAppDelegate *appDelegate = [[UIApplication sharedApplication] delegate];
	NSManagedObjectContext *context = [appDelegate managedObjectContext];
    
    if (editingStyle == UITableViewCellEditingStyleDelete) {
		NSUInteger row = [indexPath row];
		
		List *list = [lists objectAtIndex:row];
        
        [context deleteObject:list];
        [lists removeObjectAtIndex:row];
		
        [tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationFade];
        
        NSError *error = nil;
		if (![context save:&error]) {
			NSLog(@"%@ %@, %@", kErrorUnableToDeleteList, error, [error userInfo]);
            
            NSString *message = [[NSString alloc] initWithString:kErrorCoreDataMessageForUser];
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Error" message:message delegate:self cancelButtonTitle:@"Ok" otherButtonTitles:nil];
            
            [alert show];
            [alert release];
            [message release];
		}
    } else if (editingStyle == UITableViewCellEditingStyleInsert) {
        [self insertListAnimated:YES];
    }
}


- (void)insertListAnimated:(BOOL)animated {
    StudyDictionaryAppDelegate *appDelegate = [[UIApplication sharedApplication] delegate];
	NSManagedObjectContext *context = [appDelegate managedObjectContext];
    
    List *list = [NSEntityDescription insertNewObjectForEntityForName:kListEntityName inManagedObjectContext:context];
    
    list.listName = @"";
    
    [lists addObject:list];
    
    NSIndexPath *indexPath = [NSIndexPath indexPathForRow:[lists count] - 1 inSection:0];
    list.listIndex = [NSNumber numberWithInt:[indexPath row]];
    
    UITableViewRowAnimation animationStyle = UITableViewRowAnimationNone;
    if (animated) {
        animationStyle = UITableViewRowAnimationFade;
    }
    
    [self.tableView insertRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:animationStyle];
    EditableTableViewCell *cell = (EditableTableViewCell *)[self.tableView cellForRowAtIndexPath:indexPath];
    
    [cell.textField becomeFirstResponder];
}


#pragma mark -
#pragma mark Table view delegate

- (NSIndexPath *)tableView:(UITableView *)tableView willSelectRowAtIndexPath:(NSIndexPath *)indexPath {
	if (indexPath.row == [lists count]) {
		return nil;
	}
	return indexPath;
}


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
#pragma mark Editing text fields

- (void)textFieldDidEndEditing:(UITextField *)textField {
    if (textField.tag < [lists count]) {
        List *list = [lists objectAtIndex:textField.tag];
        list.listName = textField.text;
    }
}	


- (BOOL)textFieldShouldReturn:(UITextField *)textField {	
	[textField resignFirstResponder];
	return YES;	
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