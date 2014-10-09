//
//  CreateAlbumViewController.h
//  Photo Nest
//
//  Created by Gal Skarishevsky on 10/4/14.
//  Copyright (c) 2014 Gal Skarishevsky. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <Parse/Parse.h>



@interface CreateAlbumViewController : UIViewController<UITextFieldDelegate>
{
//    int uploaded;
    int total;
//    PFObject* newAlbum;
}

@property (readwrite, atomic) volatile double uploaded;
@property (readwrite, atomic) volatile double totalToUpload;

- (IBAction)choosePhotosTapped:(id)sender;
- (IBAction)saveAlbumTapped:(id)sender;
- (IBAction)chooseCoverTapped:(id)sender;
- (IBAction)shareWithFriendsTapped:(id)sender;
- (IBAction)cancelAlbumCreationTapped:(id)sender;

@end
