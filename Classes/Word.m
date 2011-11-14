//
//  Word.m
//  StudyDictionary
//
//  Created by James Weinert on 4/19/11.
//  Copyright (c) 2011 Weinert Works. All rights reserved.
//

#import "Word.h"
#import "List.h"


@implementation Word
@dynamic lookupCount;
@dynamic word;
@dynamic belongsToList;

- (void)addBelongsToListObject:(List *)value {    
    NSSet *changedObjects = [[NSSet alloc] initWithObjects:&value count:1];
    [self willChangeValueForKey:@"belongsToList" withSetMutation:NSKeyValueUnionSetMutation usingObjects:changedObjects];
    [[self primitiveValueForKey:@"belongsToList"] addObject:value];
    [self didChangeValueForKey:@"belongsToList" withSetMutation:NSKeyValueUnionSetMutation usingObjects:changedObjects];
}

- (void)removeBelongsToListObject:(List *)value {
    NSSet *changedObjects = [[NSSet alloc] initWithObjects:&value count:1];
    [self willChangeValueForKey:@"belongsToList" withSetMutation:NSKeyValueMinusSetMutation usingObjects:changedObjects];
    [[self primitiveValueForKey:@"belongsToList"] removeObject:value];
    [self didChangeValueForKey:@"belongsToList" withSetMutation:NSKeyValueMinusSetMutation usingObjects:changedObjects];
}

- (void)addBelongsToList:(NSSet *)value {    
    [self willChangeValueForKey:@"belongsToList" withSetMutation:NSKeyValueUnionSetMutation usingObjects:value];
    [[self primitiveValueForKey:@"belongsToList"] unionSet:value];
    [self didChangeValueForKey:@"belongsToList" withSetMutation:NSKeyValueUnionSetMutation usingObjects:value];
}

- (void)removeBelongsToList:(NSSet *)value {
    [self willChangeValueForKey:@"belongsToList" withSetMutation:NSKeyValueMinusSetMutation usingObjects:value];
    [[self primitiveValueForKey:@"belongsToList"] minusSet:value];
    [self didChangeValueForKey:@"belongsToList" withSetMutation:NSKeyValueMinusSetMutation usingObjects:value];
}


@end
