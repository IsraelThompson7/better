//
//  ListSelectViewController.h
//  StudyDictionary
//
//  Created by James Weinert on 4/26/11.
//  Copyright 2011 Weinert Works. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ListViewController.h"

@class Word;

@interface ListSelectViewController : ListViewController {
    Word *word;
}
@property (nonatomic, retain) Word *word;

- (IBAction)dismissAction:(id)sender;
@end
