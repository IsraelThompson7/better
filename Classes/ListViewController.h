//
//  ListViewController.h
//  StudyDictionary
//
//  Created by James Weinert on 9/22/11.
//  Copyright 2011 Weinert Works. All rights reserved.
//

#import <UIKit/UIKit.h>

@class EditableTableViewCell;

@interface ListViewController : UITableViewController <UITextFieldDelegate> {
    EditableTableViewCell *editableTableViewCell;
	NSMutableArray *lists;
    BOOL didViewJustLoad;
}
@property (nonatomic, assign) IBOutlet EditableTableViewCell *editableTableViewCell;
@property (nonatomic, retain) NSMutableArray *lists;

- (void)loadLists;
- (void)insertListAnimated:(BOOL)animated;

@end
