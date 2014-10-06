//
//  CreateAlbumViewController.m
//  Photo Nest
//
//  Created by Gal Skarishevsky on 10/4/14.
//  Copyright (c) 2014 Gal Skarishevsky. All rights reserved.
//

#import "CreateAlbumViewController.h"
#import "UzysAssetsPickerController.h"
#define PHOTOS_PICKER 1
#define COVER_PICKER 2
#define MAXIMUM_PHOTOS_IN_ALBUM 30

@interface CreateAlbumViewController () <UzysAssetsPickerControllerDelegate>
@property (nonatomic, assign) UIBackgroundTaskIdentifier photoPostBackgroundTaskId;

@end

@implementation CreateAlbumViewController
@synthesize photoPostBackgroundTaskId;

- (void)viewDidLoad {
    [super viewDidLoad];
    self.photoPostBackgroundTaskId = UIBackgroundTaskInvalid;
    _uploaded = 0;
    _totalToUpload = 0;
    
}
-(void)viewDidAppear:(BOOL)animated{
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

-(void)presentMediaPicker{
    UzysAssetsPickerController *picker = [[UzysAssetsPickerController alloc] init];
    picker.delegate = self;
    picker.maximumNumberOfSelectionVideo = 0;
    picker.maximumNumberOfSelectionPhoto = MAXIMUM_PHOTOS_IN_ALBUM;
    
    
    [self presentViewController:picker animated:YES completion:nil];
    
}


- (NSString *)createNewAlbum {
    NSString* albumid = [self generateAlbumId];
    newAlbum = [PFObject objectWithClassName:@"Album"];
    [newAlbum setObject:albumid forKey:@"albumId"];
    return albumid;
}

- (void)UzysAssetsPickerController:(UzysAssetsPickerController *)picker didFinishPickingAssets:(NSArray *)assets{
    NSString *albumid = [self createNewAlbum];
    _uploaded = 0;
    _totalToUpload = 0;
    NSLog(@"Start Uploading");
    [self uploadPhotosInBackground:assets albumid:albumid];
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


- (IBAction)choosePhotosTapped:(id)sender {
    [self presentMediaPicker];
}

- (void)uploadAlbumMetadata {
    UIBackgroundTaskIdentifier taskId = [self generateTaskId];
    [self uploadObject:taskId pfObject:newAlbum numOfRetiresLeft:3];
}

- (IBAction)saveAlbum:(id)sender {
    [self uploadAlbumMetadata];
}


- (NSString *)generateAlbumId {
    NSString *albumid = [[NSUUID UUID] UUIDString];
    return albumid;
}

- (PFObject *)buildPhotoObject:(PFFile *)imageFile albumid:(NSString *)albumid {
    PFObject *photoObject = [PFObject objectWithClassName:@"Photo"];
    [photoObject setObject:imageFile forKey:@"imageFile"];
    [photoObject setObject:[[PFUser currentUser] objectId] forKey:@"senderId"];
    [photoObject setObject:[[PFUser currentUser] username] forKey:@"owner"];
    [photoObject setObject:albumid forKey:@"albumId"];
//    [photoObject setObject:0 forKey:@"numOfLikes"];
    return photoObject;
}

- (PFFile *)buildFile:(id)obj idx:(NSUInteger)idx albumid:(NSString *)albumid {
    ALAsset *representation = obj;
    UIImage *image = [UIImage imageWithCGImage:representation.defaultRepresentation.fullResolutionImage
                                         scale:representation.defaultRepresentation.scale
                                   orientation:(UIImageOrientation)representation.defaultRepresentation.orientation];
    NSData * fileData = UIImageJPEGRepresentation(image, 0.9f);
    NSString *fileName =[NSString stringWithFormat:@"%@_%lu.jpg",albumid,(unsigned long)idx];
    PFFile *imageFile = [PFFile fileWithName:fileName data:fileData];
    return imageFile;
}

- (UIBackgroundTaskIdentifier)generateTaskId {
    UIBackgroundTaskIdentifier taskId = [[UIApplication sharedApplication] beginBackgroundTaskWithExpirationHandler:^{
        [[UIApplication sharedApplication] endBackgroundTask:taskId];
    }];
    return taskId;
}

- (void)uploadObject:(UIBackgroundTaskIdentifier)taskId
        pfObject:(PFObject *)photoObject
   numOfRetiresLeft:(int)retries{
    
    @synchronized(self){
        _totalToUpload=_totalToUpload+1;
       
    }
    [photoObject saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
        if (error){
            @synchronized(self){
                _totalToUpload=_totalToUpload-1;
                
            }
            if (retries>0) {
                NSLog(@"%@ upload failed. retrying %i more times",photoObject.parseClassName, retries);
                [self uploadObject:taskId pfObject:photoObject numOfRetiresLeft:retries-1];
            }
            else{
                UIAlertView *errorAlert = [[UIAlertView alloc]initWithTitle:@"Image Upload Error" message:@"please try sending your image again" delegate:self cancelButtonTitle:@"Ok" otherButtonTitles:nil];
                [errorAlert show];
                [[UIApplication sharedApplication] endBackgroundTask:taskId];
            }
            NSLog(@"Error: %@ %@", error, [error userInfo]);
        }
        else if (succeeded){
            @synchronized(self){
                _uploaded=_uploaded+1;
                if (_totalToUpload!=0) {
                    double percent = (_uploaded/_totalToUpload)*100;
                NSLog(@"%i%%",(int)percent);
                }

            }
            [[UIApplication sharedApplication] endBackgroundTask:taskId];
            
        }
    }];
}

- (void)uploadImagesTo:(NSString *)albumid
       withPhotoAssets:(NSArray *)assets {
//    NSMutableArray* photosArray = [[NSMutableArray alloc]initWithCapacity:MAXIMUM_PHOTOS_IN_ALBUM];
    [assets enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {

        PFFile *imageFile = [self buildFile:obj idx:idx albumid:albumid];
        
        if (idx==0) [self setCoverPhoto:imageFile];
        
        PFObject *photoObject = [self buildPhotoObject:imageFile albumid:albumid];
        UIBackgroundTaskIdentifier taskId = [self generateTaskId];
        [self uploadObject:taskId pfObject:photoObject numOfRetiresLeft:3];
//        [photosArray addObject:photoObject];
    }];

    
//    [PFObject saveAllInBackground:photosArray chunkSize:1 block:^(BOOL succeeded, NSError *error) {
//        //code
//    } progressBlock:^(int percentDone) {
//        NSLog(@"%i/100",percentDone);
//    }];


}

- (void)setCoverPhoto:(PFFile*)coverPhotoFile{
    [newAlbum setObject:coverPhotoFile forKey:@"coverPhoto"];
}
- (void)uploadPhotosInBackground:(NSArray *)assets
                         albumid:(NSString *)albumid {
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0), ^{
        [self uploadImagesTo:albumid withPhotoAssets:assets];
        // If you then need to execute something making sure it's on the main thread (updating the UI for example)
        dispatch_async(dispatch_get_main_queue(), ^{
            //            [self updateGUI];
        });
    });
}

- (BOOL)textFieldShouldBeginEditing:(UITextField *)textField
{
    return YES;
}

// It is important for you to hide kwyboard

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    [textField resignFirstResponder];
    NSString *trimmedAlbumName = [textField.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];

    if ([trimmedAlbumName isEqualToString:@""]) {
        NSLog(@"Empty album name!");
            return NO;
    }
    else
    {
        [newAlbum setObject:trimmedAlbumName forKey:@"albumTitle"];
        return YES;
    }

}


@end
