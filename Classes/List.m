//
//  List.m
//  StudyDictionary
//
//  Created by James Weinert on 4/19/11.
//  Copyright (c) 2011 Weinert Works. All rights reserved.
//

#import "List.h"
#import "Word.h"


@implementation List
@dynamic listName;
@dynamic listIndex;
@dynamic listContents;

- (void)addListContentsObject:(Word *)value {    
    NSSet *changedObjects = [[NSSet alloc] initWithObjects:&value count:1];
    [self willChangeValueForKey:@"listContents" withSetMutation:NSKeyValueUnionSetMutation usingObjects:changedObjects];
    [[self primitiveValueForKey:@"listContents"] addObject:value];
    [self didChangeValueForKey:@"listContents" withSetMutation:NSKeyValueUnionSetMutation usingObjects:changedObjects];
}

- (void)removeListContentsObject:(Word *)value {
    NSSet *changedObjects = [[NSSet alloc] initWithObjects:&value count:1];
    [self willChangeValueForKey:@"listContents" withSetMutation:NSKeyValueMinusSetMutation usingObjects:changedObjects];
    [[self primitiveValueForKey:@"listContents"] removeObject:value];
    [self didChangeValueForKey:@"listContents" withSetMutation:NSKeyValueMinusSetMutation usingObjects:changedObjects];
}

- (void)addListContents:(NSSet *)value {    
    [self willChangeValueForKey:@"listContents" withSetMutation:NSKeyValueUnionSetMutation usingObjects:value];
    [[self primitiveValueForKey:@"listContents"] unionSet:value];
    [self didChangeValueForKey:@"listContents" withSetMutation:NSKeyValueUnionSetMutation usingObjects:value];
}

- (void)removeListContents:(NSSet *)value {
    [self willChangeValueForKey:@"listContents" withSetMutation:NSKeyValueMinusSetMutation usingObjects:value];
    [[self primitiveValueForKey:@"listContents"] minusSet:value];
    [self didChangeValueForKey:@"listContents" withSetMutation:NSKeyValueMinusSetMutation usingObjects:value];
}


@end
