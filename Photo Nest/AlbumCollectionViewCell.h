//
//  AlbumCollectionViewCell.h
//  Photo Nest
//
//  Created by Gal Skarishevsky on 10/9/14.
//  Copyright (c) 2014 Gal Skarishevsky. All rights reserved.
//

#import <UIKit/UIKit.h>

#define IMAGE_HEIGHT 200
#define IMAGE_OFFSET_SPEED 25

@interface AlbumCollectionViewCell : UICollectionViewCell

/*
 
 image used in the cell which will be having the parallax effect
 
 */
@property (nonatomic, strong, readwrite) UIImage *image;
@property (nonatomic, strong, readwrite) NSString *imageLink;
/*
 Image will always animate according to the imageOffset provided. Higher the value means higher offset for the image
 */
@property (nonatomic, assign, readwrite) CGPoint imageOffset;

@end

