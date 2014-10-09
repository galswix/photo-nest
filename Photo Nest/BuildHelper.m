//
//  BuildHelper.m
//  Photo Nest
//
//  Created by Gal Skarishevsky on 10/8/14.
//  Copyright (c) 2014 Gal Skarishevsky. All rights reserved.
//

#import "BuildHelper.h"


@implementation BuildHelper

+ (PFObject *)buildPhotoObject:(PFFile *)imageFile albumid:(NSString *)albumid {
    PFObject *photoObject = [PFObject objectWithClassName:@"Photo"];
    [photoObject setObject:imageFile forKey:@"imageFile"];
    [photoObject setObject:[[PFUser currentUser] objectId] forKey:@"senderId"];
    [photoObject setObject:[[PFUser currentUser] username] forKey:@"owner"];
    [photoObject setObject:albumid forKey:@"albumId"];
    return photoObject;
}
+ (PFFile *)buildFile:(id)obj idx:(NSUInteger)idx albumid:(NSString *)albumid {
    ALAsset *representation = obj;
    UIImage *image = [UIImage imageWithCGImage:representation.defaultRepresentation.fullResolutionImage
                                         scale:representation.defaultRepresentation.scale
                                   orientation:(UIImageOrientation)representation.defaultRepresentation.orientation];
    NSData * fileData = UIImageJPEGRepresentation(image, 0.9f);
    NSString *fileName =[NSString stringWithFormat:@"%@_%lu.jpg",albumid,(unsigned long)idx];
    PFFile *imageFile = [PFFile fileWithName:fileName data:fileData];
    return imageFile;
}
+ (UIBackgroundTaskIdentifier)generateTaskId {
    UIBackgroundTaskIdentifier taskId = [[UIApplication sharedApplication] beginBackgroundTaskWithExpirationHandler:^{
        [[UIApplication sharedApplication] endBackgroundTask:taskId];
    }];
    return taskId;
}

@end
