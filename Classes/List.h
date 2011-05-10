//
//  List.h
//  StudyDictionary
//
//  Created by James Weinert on 4/19/11.
//  Copyright (c) 2011 Weinert Works. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class Word;

@interface List : NSManagedObject {
@private
}
@property (nonatomic, retain) NSString * listName;
@property (nonatomic, retain) NSSet* listContents;

- (void)addListContentsObject:(Word *)value;
- (void)removeListContentsObject:(Word *)value;
- (void)addListContents:(NSSet *)value;
- (void)removeListContents:(NSSet *)value;

@end
