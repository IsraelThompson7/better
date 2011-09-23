//
//  WordDefinitionViewController.h
//  StudyDictionary
//
//  Created by James Weinert on 2/21/11.
//  Copyright 2011 Weinert Works. All rights reserved.
//

#import <UIKit/UIKit.h>

@class Word;

@interface WordDefinitionViewController : UIViewController {
	UITextView *wordDefinitionView;
	Word *wordToLookup;
}
@property (nonatomic, retain) IBOutlet UITextView *wordDefinitionView;
@property (nonatomic, retain) Word *wordToLookup;


- (void)updateDefinition;
- (IBAction)addWordToList:(id)sender;

@end
