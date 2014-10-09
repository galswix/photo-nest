//
//  AlbumBuilder.h
//  Photo Nest
//
//  Created by Gal Skarishevsky on 10/8/14.
//  Copyright (c) 2014 Gal Skarishevsky. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <Parse/Parse.h>

@interface AlbumBuilder : NSObject
{
    PFObject *album;
}
@property (nonatomic, retain) PFObject *album;

+ (id)sharedBuilder;
- (NSString *)createNewAlbumId;
- (void)setCoverPhoto:(PFFile*)coverPhotoFile;
- (void)setAlbumName:(NSString *)trimmedAlbumName;
@end
