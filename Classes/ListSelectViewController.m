//
//  ListSelectViewController.m
//  StudyDictionary
//
//  Created by James Weinert on 4/26/11.
//  Copyright 2011 Weinert Works. All rights reserved.
//

#import "ListSelectViewController.h"
#import "StudyDictionaryAppDelegate.h"
#import "StudyDictionaryConstants.h"
#import "List.h"
#import "Word.h"
#import "EditableTableViewCell.h"


@implementation ListSelectViewController

@synthesize word;


#pragma mark -
#pragma mark View lifecycle

- (void)viewDidLoad {
    [super viewDidLoad];
    
    UIBarButtonItem *dismissButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone
                                                                                     target:self 
                                                                                     action:@selector(dismissAction:)];
    self.navigationItem.leftBarButtonItem = dismissButton;
    [dismissButton release];
}


- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
}


- (IBAction)dismissAction:(id)sender {
    [self.parentViewController dismissModalViewControllerAnimated:YES];
}


#pragma mark -
#pragma mark Table view data source

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
    
    if ([word.belongsToList containsObject:list]) {
		cell.accessoryType = UITableViewCellAccessoryCheckmark;
	}
	else {
		cell.accessoryType = UITableViewCellAccessoryNone;
	}
	
    return cell;
}


#pragma mark -
#pragma mark Editing Table Rows

- (void)setEditing:(BOOL)editing animated:(BOOL)animated {
    [super setEditing:editing animated:animated];

	// Don't show the Back button while editing.
	if (editing) {
        [self.navigationItem setLeftBarButtonItem:nil animated:YES];
    } else {
        UIBarButtonItem *dismissButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone
                                                                                       target:self 
                                                                                       action:@selector(dismissAction:)];
        [self.navigationItem setLeftBarButtonItem:dismissButton animated:YES];
        [dismissButton release];
    }      
	
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
		NSManagedObjectContext *context = [word managedObjectContext];
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


- (void)insertListAnimated:(BOOL)animated {
    List *list = [NSEntityDescription insertNewObjectForEntityForName:kListEntityName inManagedObjectContext:[word managedObjectContext]];
    
    list.listName = @"";
    [word addBelongsToListObject:list];
    
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

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    NSUInteger row = [indexPath row];

    List *list = [lists objectAtIndex:row];
    
    UITableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
    
    if([word.belongsToList containsObject:list]) {
        cell.accessoryType = UITableViewCellAccessoryNone;
        [word removeBelongsToListObject:list];
        [list removeListContentsObject:word];
    } else {
        cell.accessoryType = UITableViewCellAccessoryCheckmark;
        [word addBelongsToListObject:list];
    }
    
    NSError *error = nil;
    if (![word.managedObjectContext save:&error]) {
        NSLog(@"%@ %@, %@", kErrorUnableToDeleteList, error, [error userInfo]);
        
        NSString *message = [[NSString alloc] initWithString:kErrorCoreDataMessageForUser];
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Error" message:message delegate:self cancelButtonTitle:@"Ok" otherButtonTitles:nil];
        
        [alert show];
        [alert release];
        [message release];
    }
    
    [self.tableView deselectRowAtIndexPath:indexPath animated:YES];
}


#pragma mark -
#pragma mark Memory management

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

- (void)viewDidUnload {
    self.word = nil;
}


- (void)dealloc {
    [word release];
    [super dealloc];
}


@end
