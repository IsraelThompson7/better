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
    EditableTableViewCell *__unsafe_unretained editableTableViewCell;
	NSMutableArray *lists;
    BOOL didViewJustLoad;
}
@property (nonatomic, unsafe_unretained) IBOutlet EditableTableViewCell *editableTableViewCell;
@property (nonatomic, strong) NSMutableArray *lists;

- (void)loadLists;
- (void)insertListAnimated:(BOOL)animated;

@end
