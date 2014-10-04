//
//  CreateAlbumViewController.h
//  Photo Nest
//
//  Created by Gal Skarishevsky on 10/4/14.
//  Copyright (c) 2014 Gal Skarishevsky. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <Parse/Parse.h>


@interface CreateAlbumViewController : UIViewController
{
//    int uploaded;
    int total;
}

@property (readwrite, atomic) volatile int uploaded;
- (IBAction)choosePhotosTapped:(id)sender;

@end
