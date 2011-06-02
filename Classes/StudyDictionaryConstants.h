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

// Core Data Error messgaes
#define kErrorUnableToSaveContext           @"Unable to save context"
#define kErrorUnableToUpdateWordHistory     @"Unable to update word history"
#define kErrorUnableToLoadHistory           @"Unable to load word history"
#define kErrorUnableToDeleteWord            @"Unable to delete word from history"
#define kErrorUnableToDeleteList            @"Unable to delete list from history"
#define kErrorUnableToCreatePersistentStore @"Unable to create a storange file"

#define kErrorCoreDataMessageForUser        @"Unable to save word to history. Please restart the app using your Home button"

// Wordnik Error Messages
#define kErrorUnableToConnectToWordnik      @"Unable to create WNClient"
#define kErrorUnableToCompleteWNRequest     @"Unable to complete WNRequest"
#define kErrorUnableToCompleteWNWordRequest @"Unable to complete WNWordRequest"

#define kErrorWordnikErrorForUser           @"Unable to connect to wordnik.com."