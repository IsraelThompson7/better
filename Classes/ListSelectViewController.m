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
    
    [self loadLists];
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
	
	[self.tableView reloadData];
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
    
    NSLog([NSString stringWithFormat:@"%@ %d", list.listName, [list.listIndex intValue]]);
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
    [Debug printCoreDataObjects];
}


#pragma mark -
#pragma mark Editing text fields

- (BOOL)textFieldShouldEndEditing:(UITextField *)textField {
    if (textField.tag >= [lists count]) return YES;
	List *list = [lists objectAtIndex:textField.tag];
	list.listName = textField.text;
	
	return YES;
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
