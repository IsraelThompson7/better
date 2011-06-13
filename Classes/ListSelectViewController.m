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

@synthesize editableTableViewCell;
@synthesize lists, word;


#pragma mark -
#pragma mark View lifecycle

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.tableView.allowsSelectionDuringEditing = YES;
    self.title = @"Word Lists";
       
    self.navigationItem.rightBarButtonItem = self.editButtonItem;
    
    UIBarButtonItem *dismissButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone
                                                                                     target:self 
                                                                                     action:@selector(dismissAction:)];
    self.navigationItem.leftBarButtonItem = dismissButton;
    [dismissButton release];
    
    [self loadLists];
    didViewJustLoad = YES;
}


- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    if (!didViewJustLoad) {
        [self loadLists];
    }
    
    didViewJustLoad = NO;
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
        
        NSString *message = [[NSString alloc] initWithString:kErrorCoreDataMessageForUser];
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Error" message:message delegate:self cancelButtonTitle:@"Ok" otherButtonTitles:nil];
        
        [alert show];
        [alert release];
        [message release];
		
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
	
	[self.tableView reloadData];
}


- (IBAction)dismissAction:(id)sender {
    [self.parentViewController dismissModalViewControllerAnimated:YES];
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
    
    if ([word.belongsToList containsObject:list]) {
		cell.accessoryType = UITableViewCellAccessoryCheckmark;
	}
	else {
		cell.accessoryType = UITableViewCellAccessoryNone;
	}
	
    return cell;
}


#pragma mark -
#pragma mark Editing Talble Rows

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


- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.row == [lists count]) 
        return NO;
    
    return YES;
}


- (NSIndexPath *)tableView:(UITableView *)tableView targetIndexPathForMoveFromRowAtIndexPath:(NSIndexPath *)sourceIndexPath toProposedIndexPath:(NSIndexPath *)proposedDestinationIndexPath {
    NSIndexPath *destination = proposedDestinationIndexPath;
    NSUInteger section = proposedDestinationIndexPath.section;
    
    NSUInteger lastIndex = [lists count] - 1;
    NSUInteger firstEditableIndex = 1;
    
    if (proposedDestinationIndexPath.row > lastIndex) {
        destination = [NSIndexPath indexPathForRow:lastIndex inSection:section];
    } else if (proposedDestinationIndexPath.row < firstEditableIndex) {
        destination = [NSIndexPath indexPathForRow:firstEditableIndex inSection:section];
    }
    
    return destination;
}


- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)sourceIndexPath toIndexPath:(NSIndexPath *)destinationIndexPath {
    NSUInteger fromRow = [sourceIndexPath row];
    NSUInteger toRow = [destinationIndexPath row];
    
    List *list = [lists objectAtIndex:fromRow];
    [lists removeObjectAtIndex:fromRow];
    [lists insertObject:list atIndex:toRow];
    
    NSInteger start = fromRow;
    if (toRow < start) {
        start = toRow;
    }
    
    NSInteger end = toRow;
    if (fromRow > end) {
        end = fromRow;
    }
    
    for (NSInteger i = start; i <= end; i++) {
        list = [lists objectAtIndex:i];
        list.listIndex = [NSNumber numberWithInteger:i];
    }
}


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


- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
	NSManagedObjectContext *context = [word managedObjectContext];
    
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

- (NSIndexPath *)tableView:(UITableView *)tableView willSelectRowAtIndexPath:(NSIndexPath *)indexPath {
	if (indexPath.row == [lists count]) {
		return nil;
	}
	return indexPath;
}


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
#pragma mark Editing text fields

- (void)textFieldDidEndEditing:(UITextField *)textField {
    if (textField.tag < [lists count]) {
        List *list = [lists objectAtIndex:textField.tag];
        
        NSString *finalListText = [textField.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
        
        if ([finalListText length] == 0) {
            finalListText = @"Unnamed Word List";
        }
        
        NSString *tempListText = [[[NSString alloc] initWithString:finalListText] autorelease];
        int i = 1;
        BOOL hasSameName;
        do {
            hasSameName = NO;
            for (List *listObject in lists) {
                if (![list isEqual:listObject] && [finalListText isEqualToString:listObject.listName]) {
                    hasSameName = YES;
                    finalListText = [tempListText stringByAppendingString:[NSString stringWithFormat:@" %d", i]];
                    i++;
                    break;
                }
            }
        } while (hasSameName);
        
        if (list.listName) {
            [list.listName release];
        }
        list.listName = finalListText;
        textField.text = finalListText;
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
	self.lists = nil;
    self.word = nil;
}


- (void)dealloc {
	[lists release];
    [word release];
    [super dealloc];
}


@end
