//
//  DictionarySearchViewController.m
//  StudyDictionary
//
//  Created by James Weinert on 2/23/11.
//  Copyright 2011 Weinert Works. All rights reserved.
//

#import "DictionarySearchViewController.h"
#import "StudyDictionaryAppDelegate.h"
#import "WordDefinitionViewController.h"
#import "StudyDictionaryConstants.h"
#import "SearchBarContents.h"
#import "List.h"
#import "Word.h"


@implementation DictionarySearchViewController

@synthesize imageView, searchResults;


#pragma mark -
#pragma mark View lifecycle

- (void)viewDidLoad {
    [super viewDidLoad];
    self.imageView.image = [UIImage imageNamed:@"lined-paper.png"];
    
    StudyDictionaryAppDelegate *appDelegate = [[UIApplication sharedApplication] delegate];
    client = [appDelegate wordnikClient];
    [client addObserver: self];

    [self loadSearchBarState];
    
    UIApplication *app = [UIApplication sharedApplication];
    [[NSNotificationCenter defaultCenter] addObserver:self
											 selector:@selector(applicationWillResignActive:)
												 name:UIApplicationWillResignActiveNotification
											   object:app];
}


- (void)viewDidDisappear:(BOOL)animated {
    [self saveSearchBarState];
    [super viewDidDisappear:animated];
}


- (void)applicationWillResignActive:(NSNotification *)notification {
    [self saveSearchBarState];
}


- (void)loadSearchBarState {
    StudyDictionaryAppDelegate *appDelegate = [[UIApplication sharedApplication] delegate];
	NSManagedObjectContext *context = [appDelegate managedObjectContext];
	NSError *error;
    
	NSFetchRequest *request = [[NSFetchRequest alloc] init];
    
	NSEntityDescription *entityDescription = [NSEntityDescription entityForName:kSearchBarEntityName inManagedObjectContext:context];
	[request setEntity:entityDescription];
    
    NSArray *objects = [context executeFetchRequest:request error:&error];
    
    if (objects == nil) {
        NSLog(@"%@ %@, %@", kErrorUnableToSaveSearchBarContents, error, [error userInfo]);
    } else {
        SearchBarContents *searchBar = nil;
        if ([objects count] > 0) {
            searchBar = [objects objectAtIndex:0];
            
            if (searchBar.savedSearchString && ![searchBar.savedSearchString isEqualToString:@""]) {
                [self.searchDisplayController setActive:[searchBar.searchWasActive boolValue]];
                [self.searchDisplayController.searchBar setText:searchBar.savedSearchString];
                
                [self finishSearchWithString:searchBar.savedSearchString];
            }
        }
    }
    [request release];
}


- (void)saveSearchBarState {
    StudyDictionaryAppDelegate *appDelegate = [[UIApplication sharedApplication] delegate];
	NSManagedObjectContext *context = [appDelegate managedObjectContext];
	NSError *error;
    
	NSFetchRequest *request = [[NSFetchRequest alloc] init];
    
	NSEntityDescription *entityDescription = [NSEntityDescription entityForName:kSearchBarEntityName inManagedObjectContext:context];
	[request setEntity:entityDescription];
    
    NSArray *objects = [context executeFetchRequest:request error:&error];
    
    if (objects == nil) {
        NSLog(@"%@ %@, %@", kErrorUnableToSaveSearchBarContents, error, [error userInfo]);
    } else {
        SearchBarContents *searchBar = nil;
        if ([objects count] > 0) {
            searchBar = [objects objectAtIndex:0];
        } else {
            searchBar = [NSEntityDescription insertNewObjectForEntityForName:kSearchBarEntityName inManagedObjectContext:context];
        }
                
        searchBar.savedSearchString = self.searchDisplayController.searchBar.text;
        searchBar.searchWasActive = [NSNumber numberWithBool:[self.searchDisplayController isActive]];
        
        [context save:&error];
    }
    [request release];
}


#pragma mark -
#pragma mark UITableView data source and delegate methods

- (Word *)updateWordHistory:(NSString *)wordLookedUp {
	StudyDictionaryAppDelegate *appDelegate = [[UIApplication sharedApplication] delegate];
	NSManagedObjectContext *context = [appDelegate managedObjectContext];
	NSError *error;
    
	NSFetchRequest *request = [[NSFetchRequest alloc] init];
    	
	NSEntityDescription *entityDescription = [NSEntityDescription entityForName:kListEntityName inManagedObjectContext:context];
	[request setEntity:entityDescription];
	
    // Using kWordKey instead of "word" causes errors here. Oddness.
	NSPredicate *pred = [NSPredicate predicateWithFormat:@"(listName = %@)", kDefaultListName];
	[request setPredicate:pred];
    
    NSArray *listObjects = [context executeFetchRequest:request error:&error];
    
    List *list = nil;
    if(listObjects == nil) {
		NSLog(@"%@ %@, %@", kErrorUnableToUpdateWordHistory, error, [error userInfo]);
        
        NSString *message = [[NSString alloc] initWithString:kErrorCoreDataMessageForUser];
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Error" message:message delegate:self cancelButtonTitle:@"Ok" otherButtonTitles:nil];
        
        [alert show];
        [alert release];
        [message release];
		
	} else {
        if ([listObjects count] > 0) {
            list = [listObjects objectAtIndex:0];
        } else {
            list = [NSEntityDescription insertNewObjectForEntityForName:kListEntityName inManagedObjectContext:context];
            list.listName = kDefaultListName;
            list.listIndex = [NSNumber numberWithInt:0];
        }
    }
	
	entityDescription = [NSEntityDescription entityForName:kWordEntityName inManagedObjectContext:context];
	[request setEntity:entityDescription];
	
    // Using kWordKey instead of "word" causes errors here. Oddness.
	pred = [NSPredicate predicateWithFormat:@"(word = %@)", wordLookedUp];
	[request setPredicate:pred];
	
	NSArray *wordObjects = [context executeFetchRequest:request error:&error];

	Word *word = nil;
	if(wordObjects == nil) {
		NSLog(@"%@ %@, %@", kErrorUnableToUpdateWordHistory, error, [error userInfo]);
        
        NSString *message = [[NSString alloc] initWithString:kErrorCoreDataMessageForUser];
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Error" message:message delegate:self cancelButtonTitle:@"Ok" otherButtonTitles:nil];
        
        [alert show];
        [alert release];
        [message release];
		
	} else {
        if ([wordObjects count] > 0) {
            word = [wordObjects objectAtIndex:0];
        } else {
            word = [NSEntityDescription insertNewObjectForEntityForName:kWordEntityName inManagedObjectContext:context];
        }
	
        int count = [word.lookupCount intValue];
        count++;
        	
        word.word = wordLookedUp;
        word.lookupCount = [NSNumber numberWithInt:count];
        if (![word.belongsToList containsObject:list]) {
            [word addBelongsToListObject:list];
        }
        
        [context save:&error];
    }
 	[request release];
    return word;
}


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
	return [searchResults count];
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
	static NSString *SearchCellIdentifier = @"DictionarySearchCell";
	
	UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:SearchCellIdentifier];
	if (cell == nil) {
		cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:SearchCellIdentifier] autorelease];
		cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
	}
	if([searchResults objectAtIndex:indexPath.row] != nil)
	cell.textLabel.text = [searchResults objectAtIndex:indexPath.row];

	return cell;
}


- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
	NSUInteger row = [indexPath row];
	NSString *wordToLookup = [searchResults objectAtIndex:row];
	
	Word *word = [self updateWordHistory:wordToLookup];
	
	WordDefinitionViewController *wordDefViewController = [[WordDefinitionViewController alloc] 
														   initWithNibName:@"WordDefinitionView" 
														   bundle:nil];
	
	wordDefViewController.wordToLookup = word;
    [self.navigationController pushViewController:wordDefViewController animated:YES];
    [wordDefViewController release];
}


#pragma mark -
#pragma mark Search bar delegate methods

- (void)searchBar:(UISearchBar *)searchBar textDidChange:(NSString *)searchText {    
    [self finishSearchWithString:searchText];
}


- (void)finishSearchWithString:(NSString *)searchString {
    /* Cancel any running request */
    [requestTicket_ cancel];
    [requestTicket_ release];
    requestTicket_ = nil;
    
    /* If word was deleted, simply reset the current result text. */
    if ([searchString length] == 0) {
        //        resultTextView.text = nil;
        return;
    }
    
    /* Submit an autocompletion request */
	WNWordSearchRequest * req = [WNWordSearchRequest requestWithWordFragment:searchString
																		skip:0 
																	   limit:10 
														 includePartOfSpeech:nil
														 excludePartOfSpeech:nil
															  minCorpusCount:0
															  maxCorpusCount:0
														  minDictionaryCount:0
														  maxDictionaryCount:0
																   minLength:0
																   maxLength:0
															 resultCollation:WNAutocompleteWordCollationFrequencyDescending];
    
    requestTicket_ = [[client autocompletedWordsWithRequest:req] retain];
}


#pragma mark -
#pragma mark WNClient delegate methods

- (void) client:(WNClient *)client autocompleteWordRequestDidFailWithError:(NSError *)error requestTicket:(WNRequestTicket *) requestTicket {
    [requestTicket_ release];
    requestTicket_ = nil;
    
    /* Report error */
    NSLog(@"%@ %@, %@", kErrorUnableToCompleteWNRequest, error, [error userInfo]);
    UIAlertView *alert = [[[UIAlertView alloc] initWithTitle: @"Lookup Failure" 
                                                     message: [error localizedFailureReason]
                                                    delegate: nil 
                                           cancelButtonTitle: @"OK" 
                                           otherButtonTitles: nil] autorelease];
    [alert show];
}


- (void) client:(WNClient *)client didReceiveAutocompleteWordResponse:(WNWordSearchResponse *)response requestTicket:(WNRequestTicket *)requestTicket {
    /* Verify that this corresponds to our request */
    if (![requestTicket_ isEqual: requestTicket])
        return;
    
    /* Drop saved reference to the request ticket */
    [requestTicket_ release];
    requestTicket_ = nil;
    
    /* Display results */
    searchResults = [response.words retain];
    [self.searchDisplayController.searchResultsTableView reloadData];
}


#pragma mark -
#pragma mark Memory management

- (void)didReceiveMemoryWarning {
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc. that aren't in use.
}

- (void)viewDidUnload {
    [super viewDidUnload];
    self.imageView = nil;
	self.searchResults = nil;
}


- (void)dealloc {
    [imageView release];
	[searchResults release];
    [super dealloc];
}


@end
