//
//  Constants.h
//  StudyDictionary
//
//  Created by James Weinert on 3/12/11.
//  Copyright 2011 Weinert Works. All rights reserved.
//

// Default List Name
#define kDefaultListName   @"Recent Words"

// Core Data Keys
#define kWordEntityName @"Word"
#define kWordKey        @"word"
#define kCountKey       @"lookupCount"

#define kListEntityName @"List"

// Error messgaes
#define kErrorUnableToSaveContext           @"Unable to save context"
#define kErrorUnableToUpdateWordHistory     @"Unable to update word history"
#define kErrorUnableToLoadHistory           @"Unable to load word history"
#define kErrorUnableToDeleteWord            @"Unable to delete word from history"
#define kErrorUnableToDeleteList            @"Unable to delete list from history"
#define kErrorUnableToCreatePersistentStore @"Unable to create Persistent Store"

#define kErrorCoreDataMessageForUser        @"Unable to save word to history. Please restart the app using your Home button"