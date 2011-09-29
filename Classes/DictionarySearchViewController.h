//
//  DictionarySearchViewController.h
//  StudyDictionary
//
//  Created by James Weinert on 2/23/11.
//  Copyright 2011 Weinert Works. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <Wordnik/Wordnik.h>

@class Word;

@interface DictionarySearchViewController : UIViewController <UITableViewDataSource, UITableViewDelegate, UISearchBarDelegate, WNClientObserver> {
    UIImageView *imageView;
    
	WNClient *client;
    WNRequestTicket *requestTicket_;
	
	NSArray *searchResults;
}
@property (nonatomic, retain) IBOutlet UIImageView *imageView;
@property (nonatomic, retain) NSArray *searchResults;

- (void)loadSearchBarState;
- (void)saveSearchBarState;
- (Word *)updateWordHistory:(NSString *)wordToLookup;
- (void)finishSearchWithString:(NSString *)searchString;

@end
