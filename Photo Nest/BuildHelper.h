//
//  BuildHelper.h
//  Photo Nest
//
//  Created by Gal Skarishevsky on 10/8/14.
//  Copyright (c) 2014 Gal Skarishevsky. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "UzysAssetsPickerController.h"
#import <Parse/Parse.h>


@interface BuildHelper : NSObject

+ (PFObject *)buildPhotoObject:(PFFile *)imageFile albumid:(NSString *)albumid;
+ (PFFile *)buildFile:(id)obj idx:(NSUInteger)idx albumid:(NSString *)albumid;
+ (UIBackgroundTaskIdentifier)generateTaskId;
@end
