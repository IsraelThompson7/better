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
#import "List.h"
#import "Word.h"


@implementation DictionarySearchViewController
@synthesize searchBar, searchResults;


#pragma mark -
#pragma mark View lifecycle

- (void)viewDidLoad {
    [super viewDidLoad];
    
    StudyDictionaryAppDelegate *appDelegate = [[UIApplication sharedApplication] delegate];
    client = [appDelegate wordnikClient];
    [client addObserver: self];
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
		
	} else {
        if ([listObjects count] > 0) {
            list = [listObjects objectAtIndex:0];
        } else {
            list = [NSEntityDescription insertNewObjectForEntityForName:kListEntityName inManagedObjectContext:context];
            list.listName = @"All";
        }
    }
	
    //[request 
	entityDescription = [NSEntityDescription entityForName:kWordEntityName inManagedObjectContext:context];
	[request setEntity:entityDescription];
	
    // Using kWordKey instead of "word" causes errors here. Oddness.
	pred = [NSPredicate predicateWithFormat:@"(word = %@)", wordLookedUp];
	[request setPredicate:pred];
	
	NSArray *wordObjects = [context executeFetchRequest:request error:&error];

	Word *word = nil;
	if(wordObjects == nil) {
		NSLog(@"%@ %@, %@", kErrorUnableToUpdateWordHistory, error, [error userInfo]);
		
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
    /* Cancel any running request */
    [requestTicket_ cancel];
    [requestTicket_ release];
    requestTicket_ = nil;
    
    /* If word was deleted, simply reset the current result text. */
    if ([searchText length] == 0) {
//        resultTextView.text = nil;
        return;
    }
    
    /* Submit an autocompletion request */
	WNWordSearchRequest * req = [WNWordSearchRequest requestWithWordFragment:searchText
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
	self.searchBar = nil;
	self.searchResults = nil;
}


- (void)dealloc {
	[searchBar release];
	[searchResults release];
    [super dealloc];
}


@end
