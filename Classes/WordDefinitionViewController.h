//
//  WordDefinitionViewController.h
//  StudyDictionary
//
//  Created by James Weinert on 2/21/11.
//  Copyright 2011 Weinert Works. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <iAd/iAd.h>

@class Word;

@interface WordDefinitionViewController : UIViewController <ADBannerViewDelegate> {
	UITextView *wordDefinitionView;
	Word *wordToLookup;
    
    ADBannerView *adBannerView;
}
@property (nonatomic, retain) IBOutlet UITextView *wordDefinitionView;
@property (nonatomic, retain) Word *wordToLookup;

@property (nonatomic, retain) IBOutlet ADBannerView *adBannerView;

- (void)updateDefinition;
- (IBAction)addWordToList:(id)sender;

@end
