//
//  SearchBarContents.h
//  StudyDictionary
//
//  Created by James Weinert on 9/29/11.
//  Copyright (c) 2011 Weinert Works. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>


@interface SearchBarContents : NSManagedObject {
@private
}
@property (nonatomic, strong) NSString * savedSearchString;
@property (nonatomic, strong) NSNumber * searchWasActive;

@end
