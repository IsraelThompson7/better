//
//  WordListViewController.h
//  StudyDictionary
//
//  Created by James Weinert on 2/17/11.
//  Copyright 2011 Weinert Works. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "List.h"


@interface WordListDetailViewController : UITableViewController <UITableViewDataSource, UITableViewDelegate> {
	UITableView *table;

    List *list;
	NSMutableArray *listContents;
}
@property (nonatomic, retain) IBOutlet UITableView *table;
@property (nonatomic, retain) NSMutableArray *listContents;
@property (nonatomic, retain) List *list;

- (void)loadWordList;

@end
