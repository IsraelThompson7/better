//
//  ListSelectViewController.h
//  StudyDictionary
//
//  Created by James Weinert on 4/26/11.
//  Copyright 2011 Weinert Works. All rights reserved.
//

#import <UIKit/UIKit.h>

@class Word, EditableTableViewCell;

@interface ListSelectViewController : UITableViewController <UITextFieldDelegate> {
    EditableTableViewCell *editableTableViewCell;
    
	NSMutableArray *lists;
    Word *word;
}
@property (nonatomic, assign) IBOutlet EditableTableViewCell *editableTableViewCell;
@property (nonatomic, retain) NSMutableArray *lists;
@property (nonatomic, retain) Word *word;

- (void)loadLists;
- (void)insertListAnimated:(BOOL)animated;
@end
