//
//  WordListViewController.h
//  StudyDictionary
//
//  Created by James Weinert on 4/23/11.
//  Copyright 2011 Weinert Works. All rights reserved.
//

#import <UIKit/UIKit.h>


@interface WordListViewController : UITableViewController {
    UITableView *table;
    
	NSMutableArray *lists;
}
@property (nonatomic, retain) IBOutlet UITableView *table;
@property (nonatomic, retain) NSMutableArray *lists;

- (void)loadLists;

@end
