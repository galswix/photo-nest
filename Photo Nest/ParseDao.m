//
//  ParseDao.m
//  Photo Nest
//
//  Created by Gal Skarishevsky on 10/8/14.
//  Copyright (c) 2014 Gal Skarishevsky. All rights reserved.
//

#import "ParseDao.h"
#import "BuildHelper.h"
#import "AlbumBuilder.h"

@implementation ParseDao

+ (id)sharedInstance {
    static ParseDao *sharedMyManager = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedMyManager = [[self alloc] init];
    });
    return sharedMyManager;
}

- (id)init {
    if (self = [super init]) {
//        album = [PFObject objectWithClassName:@"Album"];
    }
    return self;
}

- (BFTask *) saveAsync:(PFObject *)object
          numOfRetries:(int)retries
             andTaskId:(UIBackgroundTaskIdentifier)taskId
            WithCancel:(MYCancellationToken *)cancellationToken{
    
    BFTaskCompletionSource *task = [BFTaskCompletionSource taskCompletionSource];
    [object saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
        if (!error) {
            [task setResult:object];
            [[UIApplication sharedApplication] endBackgroundTask:taskId];
        } else {
            if (retries>0) [self saveAsync:object numOfRetries:retries-1 andTaskId:taskId WithCancel:cancellationToken];
            else [task setError:error];
        }
    }];
    return task.task;
}

- (BFTask *) deleteAsync:(PFObject *)object
            numOfRetries:(int)retries
               andTaskId:(UIBackgroundTaskIdentifier)taskId{
    BFTaskCompletionSource *task = [BFTaskCompletionSource taskCompletionSource];
    [object deleteInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
        if (!error) {
            [task setResult:object];
            [[UIApplication sharedApplication] endBackgroundTask:taskId];
        } else {
            if (retries>0) [self deleteAsync:object numOfRetries:retries-1 andTaskId:taskId];
            else [task setError:error];
        }
        
    }];
    return task.task;
}

- (BFTask*)saveAsyncWithCancel:(MYCancellationToken *)cancellationToken
                     andObject:(PFObject *)object
                  numOfRetries:(int)retries
                     andTaskId:(UIBackgroundTaskIdentifier)taskId{
    if (![cancellationToken isCancelled]) return [self saveAsync:object numOfRetries:retries andTaskId:taskId WithCancel:cancellationToken] ;
    else return [BFTask cancelledTask];
}

- (void)uploadImagesTo:(NSString *)albumid
       withPhotoAssets:(NSArray *)assets
     cancellationToken:(MYCancellationToken*)token{
    
    __block BFTask *task = [BFTask taskWithResult:nil];
    
    [assets enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        
        PFFile *imageFile = [BuildHelper buildFile:obj idx:idx albumid:albumid];
        
        PFObject *photoObject = [BuildHelper buildPhotoObject:imageFile albumid:albumid];
        UIBackgroundTaskIdentifier taskId = [BuildHelper generateTaskId];
        // For each item, extend the task with a function to delete the item.
        task = [task continueWithBlock:^id(BFTask *task) {
            // Return a task that will be marked as completed when the delete is finished.
            return [self saveAsyncWithCancel:token andObject:photoObject numOfRetries:3 andTaskId:taskId];
            
        }];
//        [tasksArray addObject:task];
    }];
    
}


- (void)uploadPhotosInBackground:(NSArray *)assets
                         albumid:(NSString *)albumid
               cancellationToken:(MYCancellationToken*) token{
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0), ^{
        [self uploadImagesTo:albumid withPhotoAssets:assets cancellationToken:token];
        // If you then need to execute something making sure it's on the main thread (updating the UI for example)
        dispatch_async(dispatch_get_main_queue(), ^{
            //            [self updateGUI];
        });
    });
}

- (void)uploadAlbumMetadata {
    UIBackgroundTaskIdentifier taskId = [BuildHelper generateTaskId];
    PFObject* newAlbum = [[AlbumBuilder sharedBuilder] album];
    [self saveAsync:newAlbum  numOfRetries:3 andTaskId:taskId WithCancel:nil];
}

- (void)cancelAlbum:(NSString*)albumId {
    PFQuery *photoQuery = [PFQuery queryWithClassName:@"Photo"];
    [photoQuery whereKey:@"albumId" equalTo:albumId];
    [photoQuery findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
        UIBackgroundTaskIdentifier taskId = [BuildHelper generateTaskId];
        BFTask *task = [BFTask taskWithResult:nil];
        for (PFObject *object in objects) {
            // For each item, extend the task with a function to delete the item.
            task = [task continueWithBlock:^id(BFTask *task) {
                // Return a task that will be marked as completed when the delete is finished.
                return [[ParseDao sharedInstance] deleteAsync:object numOfRetries:3 andTaskId:taskId];
            }];
        }
        
    }];
}


@end
