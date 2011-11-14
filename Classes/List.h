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
@property (nonatomic, strong) NSString * listName;
@property (nonatomic, strong) NSNumber * listIndex;
@property (nonatomic, strong) NSSet* listContents;

- (void)addListContentsObject:(Word *)value;
- (void)removeListContentsObject:(Word *)value;
- (void)addListContents:(NSSet *)value;
- (void)removeListContents:(NSSet *)value;

@end
