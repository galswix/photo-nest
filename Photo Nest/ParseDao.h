//
//  ParseDao.h
//  Photo Nest
//
//  Created by Gal Skarishevsky on 10/8/14.
//  Copyright (c) 2014 Gal Skarishevsky. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <Bolts/Bolts.h>
#import "MYCancellationToken.h"
#import <Parse/Parse.h>
@interface ParseDao : NSObject


+ (id)sharedInstance;

- (BFTask *) deleteAsync:(PFObject *)object numOfRetries:(int)retries andTaskId:(UIBackgroundTaskIdentifier)taskId;

- (BFTask *) saveAsync:(PFObject *)object
          numOfRetries:(int)retries
             andTaskId:(UIBackgroundTaskIdentifier)taskId
            WithCancel:(MYCancellationToken *)cancellationToken;

- (BFTask*)saveAsyncWithCancel:(MYCancellationToken *)cancellationToken
                     andObject:(PFObject *)object
                  numOfRetries:(int)retries
                     andTaskId:(UIBackgroundTaskIdentifier)taskId;

- (void)uploadImagesTo:(NSString *)albumid
       withPhotoAssets:(NSArray *)assets
     cancellationToken:(MYCancellationToken*)token;

- (void)uploadPhotosInBackground:(NSArray *)assets
                         albumid:(NSString *)albumid
               cancellationToken:(MYCancellationToken*) token;
- (void)uploadAlbumMetadata;

- (void)cancelAlbum:(NSString*)albumId;


@end

