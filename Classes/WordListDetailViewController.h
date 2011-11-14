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
    BOOL didViewJustLoad;
}
@property (nonatomic, strong) NSMutableArray *listContents;
@property (nonatomic, strong) List *list;

- (void)loadWordList;

@end
