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
@property (nonatomic, strong) NSNumber * lookupCount;
@property (nonatomic, strong) NSString * word;
@property (nonatomic, strong) NSSet* belongsToList;

- (void)addBelongsToListObject:(List *)value;
- (void)removeBelongsToListObject:(List *)value;
- (void)addBelongsToList:(NSSet *)value;
- (void)removeBelongsToList:(NSSet *)value;

@end
