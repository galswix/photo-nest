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

@interface CreateAlbumViewController () <UzysAssetsPickerControllerDelegate>
@property (nonatomic, assign) UIBackgroundTaskIdentifier photoPostBackgroundTaskId;

@end

@implementation CreateAlbumViewController
@synthesize photoPostBackgroundTaskId;

- (void)viewDidLoad {
    [super viewDidLoad];
    self.photoPostBackgroundTaskId = UIBackgroundTaskInvalid;
    
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
    picker.maximumNumberOfSelectionPhoto = 30;
    
    
    [self presentViewController:picker animated:YES completion:nil];
    
}


- (void)UzysAssetsPickerController:(UzysAssetsPickerController *)picker didFinishPickingAssets:(NSArray *)assets{
    NSString* albumid = [self generateAlbumId];
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
    
}


- (IBAction)choosePhotosTapped:(id)sender {
    [self presentMediaPicker];
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

- (void)uploadPhoto:(UIBackgroundTaskIdentifier)taskId
        photoObject:(PFObject *)photoObject
   numOfRetiresLeft:(int)retries{
    

    
    [photoObject saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
        if (error){
            if (retries>0) {
                NSLog(@"upload filed. retrying %i more times",retries);
                [self uploadPhoto:taskId photoObject:photoObject numOfRetiresLeft:retries-1];
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
                NSLog(@"%i",_uploaded);
            }
            [[UIApplication sharedApplication] endBackgroundTask:taskId];
            
        }
    }];
}

- (void)uploadImagesTo:(NSString *)albumid
       withPhotoAssets:(NSArray *)assets {
    
    [assets enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        PFFile *imageFile = [self buildFile:obj idx:idx albumid:albumid];
        PFObject *photoObject = [self buildPhotoObject:imageFile albumid:albumid];
        UIBackgroundTaskIdentifier taskId = [self generateTaskId];
        [self uploadPhoto:taskId photoObject:photoObject numOfRetiresLeft:3];
    }];
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

@end
