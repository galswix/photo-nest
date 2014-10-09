//
//  AlbumBuilder.m
//  Photo Nest
//
//  Created by Gal Skarishevsky on 10/8/14.
//  Copyright (c) 2014 Gal Skarishevsky. All rights reserved.
//

#import "AlbumBuilder.h"

@implementation AlbumBuilder

@synthesize album;

+ (id)sharedBuilder {
    static AlbumBuilder *sharedMyManager = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedMyManager = [[self alloc] init];
    });
    return sharedMyManager;
}
- (id)init {
    if (self = [super init]) {
        album = [PFObject objectWithClassName:@"Album"];
    }
    return self;
}

- (NSString *)createNewAlbumId {
    NSString* albumid = [self generateAlbumId];
    album = [PFObject objectWithClassName:@"Album"];
    [album setObject:albumid forKey:@"albumId"];
    return albumid;
}
- (void)setCoverPhoto:(PFFile*)coverPhotoFile{
    [album setObject:coverPhotoFile forKey:@"coverPhoto"];
}
- (void)setAlbumName:(NSString *)trimmedAlbumName{
    [album setObject:trimmedAlbumName forKey:@"albumTitle"];
}

- (NSString *)generateAlbumId {
    NSString *albumid = [[NSUUID UUID] UUIDString];
    return albumid;
}

@end
