//
//  CreateAlbumViewController.m
//  Photo Nest
//
//  Created by Gal Skarishevsky on 10/4/14.
//  Copyright (c) 2014 Gal Skarishevsky. All rights reserved.
//

#import "CreateAlbumViewController.h"
#import "UzysAssetsPickerController.h"
#import "MYCancellationToken.h"
#import <Bolts/Bolts.h>
#import "AlbumBuilder.h"
#import "BuildHelper.h"
#import "ParseDao.h"
#define PHOTOS_PICKER 1
#define COVER_PICKER 2
#define MAXIMUM_PHOTOS_IN_ALBUM 30
#define PHOTOS_FOR_ALBUM_PURPOSE 1
#define PHOTO_FOR_COVER_PURPOSE 2

@interface CreateAlbumViewController () <UzysAssetsPickerControllerDelegate>
@property (nonatomic, assign) UIBackgroundTaskIdentifier photoPostBackgroundTaskId;
@property (nonatomic,strong) NSString * albumId;
@property (nonatomic,strong) NSMutableArray* tasksArray;
@property (nonatomic,strong) MYCancellationToken* cancelToken;

@end

@implementation CreateAlbumViewController
@synthesize photoPostBackgroundTaskId,albumId,tasksArray,cancelToken;

- (void)viewDidLoad {
    [super viewDidLoad];
    self.photoPostBackgroundTaskId = UIBackgroundTaskInvalid;
    _uploaded = 0;
    _totalToUpload = 0;
    cancelToken = [[MYCancellationToken alloc] init];
    
    
}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


/*
 #pragma mark - Navigation
 
 // In a storyboard-based application, you will often want to do a little preparation before navigation
 - (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
 // Get the new view controller using [segue destinationViewController].
 // Pass the selected object to the new view controller.
 }
 */


- (IBAction)choosePhotosTapped:(id)sender {
    
    UzysAssetsPickerController *picker;
    picker = [self generatePickerWithMaximumPhotos:MAXIMUM_PHOTOS_IN_ALBUM andPurpose:PHOTOS_FOR_ALBUM_PURPOSE];
    
    [self presentViewController:picker animated:YES completion:nil];
}
- (IBAction)chooseCoverTapped:(id)sender {
    UzysAssetsPickerController *picker;
    picker = [self generatePickerWithMaximumPhotos:1 andPurpose:PHOTO_FOR_COVER_PURPOSE];
    
    [self presentViewController:picker animated:YES completion:nil];
    
}
- (IBAction)shareWithFriendsTapped:(id)sender {
}
- (IBAction)saveAlbumTapped:(id)sender {
    [[ParseDao sharedInstance] uploadAlbumMetadata];
    [self dismissViewControllerAnimated:YES completion:nil];
}
- (IBAction)cancelAlbumCreationTapped:(id)sender {
    if ([albumId length]>0) {
        [cancelToken setCancelled:YES];
        [[ParseDao sharedInstance] cancelAlbum:albumId];
    }
    [self dismissViewControllerAnimated:YES completion:nil];

}


- (BOOL)textFieldShouldBeginEditing:(UITextField *)textField{
    return YES;
}
- (BOOL)textFieldShouldReturn:(UITextField *)textField{
    [textField resignFirstResponder];
    NSString *trimmedAlbumName = [textField.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
    
    if ([trimmedAlbumName isEqualToString:@""]) {
        NSLog(@"Empty album name!");
        return NO;
    }
    else
    {
        [[AlbumBuilder sharedBuilder] setAlbumName:trimmedAlbumName];
        return YES;
    }
    
}




- (UzysAssetsPickerController *)generatePickerWithMaximumPhotos:(int)maxPhotosInAlbum andPurpose:(int)purpose {
    UzysAssetsPickerController *picker = [[UzysAssetsPickerController alloc] init];
    picker.delegate = self;
    picker.maximumNumberOfSelectionVideo = 0;
    picker.maximumNumberOfSelectionPhoto = maxPhotosInAlbum;
    picker.purposeForPicker = purpose;
    return picker;
}

- (void)UzysAssetsPickerController:(UzysAssetsPickerController *)picker didFinishPickingAssets:(NSArray *)assets{
    if (picker.purposeForPicker==PHOTOS_FOR_ALBUM_PURPOSE) {
        albumId = [[AlbumBuilder sharedBuilder] createNewAlbumId];
        _uploaded = 0;
        _totalToUpload = 0;
        NSLog(@"Start Uploading");
        [[ParseDao sharedInstance] uploadPhotosInBackground:assets albumid:albumId cancellationToken:cancelToken];
    }
    else if(picker.purposeForPicker==PHOTO_FOR_COVER_PURPOSE){
        [assets enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
            PFFile *imageFile = [BuildHelper buildFile:obj idx:idx albumid:albumId];
            if (idx==0) [[AlbumBuilder sharedBuilder] setCoverPhoto:imageFile];}];
    }
}
- (void)UzysAssetsPickerControllerDidCancel:(UzysAssetsPickerController *)picker{
#warning add BI event
    [self dismissViewControllerAnimated:YES completion:nil];
}
- (void)UzysAssetsPickerControllerDidExceedMaximumNumberOfSelection:(UzysAssetsPickerController *)picker{
#warning Add bi event
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@""
                                                    message:@"Exceed Maximum Number Of Selection"
                                                   delegate:nil
                                          cancelButtonTitle:@"OK"
                                          otherButtonTitles:nil];
    [alert show];
    [PFQuery clearAllCachedResults];
}



@end
