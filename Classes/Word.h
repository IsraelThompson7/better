//
//  Word.h
//  StudyDictionary
//
//  Created by James Weinert on 4/19/11.
//  Copyright (c) 2011 Weinert Works. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class List;

@interface Word : NSManagedObject {
@private
}
@property (nonatomic, retain) NSNumber * lookupCount;
@property (nonatomic, retain) NSString * word;
@property (nonatomic, retain) NSSet* belongsToList;

- (void)addBelongsToListObject:(List *)value;
- (void)removeBelongsToListObject:(List *)value;
- (void)addBelongsToList:(NSSet *)value;
- (void)removeBelongsToList:(NSSet *)value;

@end
