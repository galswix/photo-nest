//
//  MyAlbumsViewController.m
//  Photo Nest
//
//  Created by Gal Skarishevsky on 10/4/14.
//  Copyright (c) 2014 Gal Skarishevsky. All rights reserved.
//

#import "MyAlbumsViewController.h"
#import "UIImageView+WebCache.h"
#import "AlbumCollectionViewCell.h"



@interface MyAlbumsViewController ()<UICollectionViewDataSource, UICollectionViewDelegate, UIScrollViewDelegate>
@property (weak, nonatomic) IBOutlet UICollectionView *parallaxCollectionView;
@property (nonatomic, strong) NSMutableArray* imagesLinks;
@end

@implementation MyAlbumsViewController
@synthesize profileImg = profileImageView;

- (void)viewDidLoad {
    [super viewDidLoad];
    //    NSUInteger index;
    //    for (index = 0; index < 14; ++index) {
    //        // Setup image name
    //        NSString *link = @"http://upload.wikimedia.org/wikipedia/commons/5/53/%C3%9Cber_den_D%C3%A4chern_von_Berlin.jpg";
    //        if(!self.imagesLinks)
    //            self.imagesLinks = [NSMutableArray arrayWithCapacity:0];
    //        [self.imagesLinks addObject:link];
    //    }
    
    NSString *link = @"http://upload.wikimedia.org/wikipedia/commons/5/53/%C3%9Cber_den_D%C3%A4chern_von_Berlin.jpg";
    if(!self.imagesLinks)
        self.imagesLinks = [NSMutableArray arrayWithCapacity:0];
    [self.imagesLinks addObject:link];
    
    NSString *link2 = @"http://images.fineartamerica.com/images-medium-large/2-nyc-empire-nina-papiorek.jpg";
    if(!self.imagesLinks)
        self.imagesLinks = [NSMutableArray arrayWithCapacity:0];
    [self.imagesLinks addObject:link2];
    
    NSString *link3 = @"http://the-elk.com/wp-content/uploads/wedding17f.jpg";
    
    [self.imagesLinks addObject:link3];
    
    NSString *link4 = @"http://i.telegraph.co.uk/multimedia/archive/02352/the-giant-christ-t_2352863b.jpg";
    [self.imagesLinks addObject:link4];
    
    NSString *link5 = @"http://images.elephantjournal.com/wp-content/uploads/2011/09/DSC_0211.jpg";
    [self.imagesLinks addObject:link5];
    [self.imagesLinks addObject:link];
    [self.imagesLinks addObject:link3];
    [self.imagesLinks addObject:link4];
    [self.imagesLinks addObject:link2];
    
    
    profileImageView.layer.cornerRadius = profileImageView.frame.size.width / 2;
    profileImageView.clipsToBounds = YES;
    profileImageView.layer.borderWidth = 3.0f;
    profileImageView.layer.borderColor = [UIColor whiteColor].CGColor;
    [self putView:profileImageView insideShadowWithColor:[UIColor darkGrayColor] andRadius:1.0 andOffset:CGSizeMake(0.0, 1.0) andOpacity:1.0];
    
    
    [self.parallaxCollectionView reloadData];
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

#pragma mark - UICollectionViewDatasource Methods
- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return self.imagesLinks.count;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    AlbumCollectionViewCell* cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"AlbumCell" forIndexPath:indexPath];
    
    //get image link and assign
    cell.imageLink = [self.imagesLinks objectAtIndex:indexPath.item];
    
    //set offset accordingly
    CGFloat yOffset = ((self.parallaxCollectionView.contentOffset.y - cell.frame.origin.y) / IMAGE_HEIGHT) * IMAGE_OFFSET_SPEED;
    cell.imageOffset = CGPointMake(0.0f, yOffset);
    
    return cell;
}
- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath{

    NSLog(@"Album %i was tapped",indexPath.row);
    
}


#pragma mark - UIScrollViewdelegate methods
- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    for(AlbumCollectionViewCell *view in self.parallaxCollectionView.visibleCells) {
        CGFloat yOffset = ((self.parallaxCollectionView.contentOffset.y - view.frame.origin.y) / IMAGE_HEIGHT) * IMAGE_OFFSET_SPEED;
        view.imageOffset = CGPointMake(0.0f, yOffset);
    }
}

- (UIView*)putView:(UIView*)view insideShadowWithColor:(UIColor*)color andRadius:(CGFloat)shadowRadius andOffset:(CGSize)shadowOffset andOpacity:(CGFloat)shadowOpacity
{
    CGRect shadowFrame; // Modify this if needed
    shadowFrame.size.width = 0.f;
    shadowFrame.size.height = 0.f;
    shadowFrame.origin.x = 0.f;
    shadowFrame.origin.y = 0.f;
    UIView * shadow = [[UIView alloc] initWithFrame:shadowFrame];
    shadow.userInteractionEnabled = NO; // Modify this if needed
    shadow.layer.shadowColor = color.CGColor;
    shadow.layer.shadowOffset = shadowOffset;
    shadow.layer.shadowRadius = shadowRadius;
    shadow.layer.masksToBounds = NO;
    shadow.clipsToBounds = NO;
    shadow.layer.shadowOpacity = shadowOpacity;
    [view.superview insertSubview:shadow belowSubview:view];
    [shadow addSubview:view];
    return shadow;
}
@end
