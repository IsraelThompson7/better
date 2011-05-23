//
//  WordListViewController.h
//  StudyDictionary
//
//  Created by James Weinert on 4/23/11.
//  Copyright 2011 Weinert Works. All rights reserved.
//

#import <UIKit/UIKit.h>

@class EditableTableViewCell;

@interface WordListViewController : UITableViewController <UITextFieldDelegate> {
    UITableView *table;
    
    EditableTableViewCell *editableTableViewCell;
	NSMutableArray *lists;
    BOOL didViewJustLoad;
}
@property (nonatomic, assign) IBOutlet EditableTableViewCell *editableTableViewCell;
@property (nonatomic, retain) IBOutlet UITableView *table;
@property (nonatomic, retain) NSMutableArray *lists;

- (void)loadLists;
- (void)insertListAnimated:(BOOL)animated;

@end
