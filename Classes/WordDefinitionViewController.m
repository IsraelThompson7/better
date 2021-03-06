//
//  WordDefinitionViewController.m
//  StudyDictionary
//
//  Created by James Weinert on 2/21/11.
//  Copyright 2011 Weinert Works. All rights reserved.
//


#import <Wordnik/WNClient.h>

#import "WordDefinitionViewController.h"
#import "StudyDictionaryConstants.h"
#import "ListSelectViewController.h"
#import "StudyDictionaryAppDelegate.h"
#import "StudyDictionaryAPIConstants.h"
#import "SVProgressHUD.h"
#import "Word.h"


@interface NSArray (WNAdditions)

- (NSArray *)wn_map:(id (^)(id obj))block;

@end


@implementation WordDefinitionViewController

@synthesize wordDefinitionView, wordToLookup;


#pragma mark -
#pragma mark View lifecycle

- (void)viewDidLoad {
    [super viewDidLoad];
	self.title = wordToLookup.word;
    
    UIBarButtonItem *addToListButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAdd 
                                                                                     target:self 
                                                                                     action:@selector(addWordToList:)];

    self.navigationItem.rightBarButtonItem = addToListButton;
}


- (void)viewDidAppear:(BOOL)animated {
	[super viewDidAppear:animated];
    if ([wordDefinitionView.text length] == 0) {
        [self updateDefinition];
    }
}


- (void)updateDefinition {
	NSArray *elements = [NSArray arrayWithObjects:
                         [WNWordDefinitionRequest requestWithDictionary:[WNDictionary wordnetDictionary]],
                         [WNWordExampleRequest request],
                         nil];
    WNWordRequest *req = [WNWordRequest requestWithWord: wordToLookup.word
                                   requestCanonicalForm: YES
                             requestSpellingSuggestions: YES
                                        elementRequests: elements];
    
    StudyDictionaryAppDelegate *appDelegate = [[UIApplication sharedApplication] delegate];
    WNClient *client = [appDelegate wordnikClient];

    [SVProgressHUD showInView:self.view];
    [client wordWithRequest:req completionBlock:^(WNWordResponse *response, NSError *error) {      
        if (error != nil) {
            NSLog(@"%@ %@, %@", kErrorUnableToCompleteWNWordRequest, error, [error userInfo]);
            [SVProgressHUD dismissWithError:[error localizedFailureReason]];
        }
        else {
            NSMutableString *wordText = [NSMutableString string];
            WNWordObject *word = response.wordObject;
            
            /* Definitions */
            if (word.definitions != nil && word.definitions.count > 0) {
                
                NSString *partOfSpeech = @"";
                for (WNDefinitionList *list in word.definitions) {
                    if (list.definitions.count == 0)
                        continue;
                    
                    NSUInteger count = 1;
                    for (WNDefinition *def in list.definitions) {
                        if (![partOfSpeech isEqualToString:def.partOfSpeech.name]) {
                            partOfSpeech = def.partOfSpeech.name;
                            [wordText appendString:[NSString stringWithFormat:@"-%@\n", partOfSpeech]];
                        }
                        
                        [wordText appendString:[NSString stringWithFormat:@"%d. ", count]];
                        count++;
                        
                        if (def.extendedText != nil) {
                            [wordText appendString:def.extendedText];
                        } else {
                            [wordText appendString:def.text];
                        }
                        
                        [wordText appendString: @"\n\n"];
                    }
                }
            }
            
            /* Example sentences. */
            if (word.examples != nil && word.examples.count > 0) {
                NSArray *strings = [word.examples wn_map:^(id obj) {
                    WNExample *sentence = obj;
                    return [NSString stringWithFormat: @"“%@”\n%@ (%d)", 
                            sentence.text, sentence.title, [sentence.publicationDateComponents year]];
                }];
                
                [wordText appendFormat: @"Examples:\n%@", [strings componentsJoinedByString: @"\n\n"]];
            }
            
            /* linking to wordnik.com */
            [wordText appendString:[NSString stringWithFormat:@"\n\nhttp://www.wordnik.com/words/%@", wordToLookup.word]];
            
            wordDefinitionView.text = wordText;
            [SVProgressHUD dismiss];
        }
    }];
}


- (IBAction)addWordToList:(id)sender {
    ListSelectViewController *listSelViewController = [[ListSelectViewController alloc]
                                                       initWithNibName:@"ListSelectView"
                                                       bundle:nil];

    listSelViewController.word = wordToLookup;
    
    UINavigationController *navigationController = [[UINavigationController alloc] initWithRootViewController:listSelViewController];
    navigationController.navigationBar.barStyle = UIBarStyleBlack;
    
    [self.navigationController presentModalViewController:navigationController animated:YES];

}


#pragma mark -
#pragma mark Memory management

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}


- (void)viewDidUnload {
    [super viewDidUnload];
    self.wordDefinitionView = nil;
	self.wordToLookup = nil;
}




@end
