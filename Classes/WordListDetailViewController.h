//
//  WordListViewController.h
//  StudyDictionary
//
//  Created by James Weinert on 2/17/11.
//  Copyright 2011 Weinert Works. All rights reserved.
//

#import <UIKit/UIKit.h>

@class List;

@interface WordListDetailViewController : UITableViewController <UITableViewDataSource, UITableViewDelegate> {
    List *list;
	NSMutableArray *listContents;
}
@property (nonatomic, retain) NSMutableArray *listContents;
@property (nonatomic, retain) List *list;

- (void)loadWordList;

@end
