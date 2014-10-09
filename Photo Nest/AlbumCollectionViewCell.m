//
//  MJCollectionViewCell.m
//  RCCPeakableImageSample
//
//  Created by Mayur on 4/1/14.
//  Copyright (c) 2014 RCCBox. All rights reserved.
//

#import "AlbumCollectionViewCell.h"
#import "UIImageView+WebCache.h"


@interface AlbumCollectionViewCell()

@property (nonatomic, strong, readwrite) UIImageView *MJImageView;

@end

@implementation AlbumCollectionViewCell

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) [self setupImageView];
    return self;
}

- (id)initWithCoder:(NSCoder *)aDecoder {
    self = [super initWithCoder:aDecoder];
    if (self) [self setupImageView];
    return self;
}

/*
 // Only override drawRect: if you perform custom drawing.
 // An empty implementation adversely affects performance during animation.
 - (void)drawRect:(CGRect)rect
 {
 // Drawing code
 }
 */

#pragma mark - Setup Method
- (void)setupImageView
{
    // Clip subviews
    self.clipsToBounds = YES;
    
    // Add image subview
    self.MJImageView = [[UIImageView alloc] initWithFrame:CGRectMake(self.bounds.origin.x, self.bounds.origin.y, self.bounds.size.width, IMAGE_HEIGHT)];
    self.MJImageView.backgroundColor = [UIColor colorWithRed:37.0/255.0 green:39.0/255.0 blue:30.0/255.0 alpha:1.0];
    self.MJImageView.contentMode = UIViewContentModeScaleAspectFill;
    self.MJImageView.clipsToBounds = NO;
    [self addSubview:self.MJImageView];
}

# pragma mark - Setters

- (void)setImage:(UIImage *)image
{
    // Store image
    self.MJImageView.image = image;
    
    // Update padding
    [self setImageOffset:self.imageOffset];
}

- (UILabel *)albumLabelWithName:(NSString *)albumName
{
    UILabel* albumNameLabel = [[UILabel alloc]initWithFrame:CGRectMake(self.bounds.origin.x, self.bounds.origin.y, self.bounds.size.width, self.bounds.size.height)];
    [albumNameLabel setText:albumName];
    [albumNameLabel setTextAlignment:NSTextAlignmentCenter];
    //albumNameLabel.numberOfLines = 1;
    //albumNameLabel.minimumScaleFactor = 8.;
    [albumNameLabel setFont:[UIFont systemFontOfSize:40]];
    albumNameLabel.textColor = [UIColor whiteColor];
    [albumNameLabel setShadowOffset:CGSizeMake(1, 1)];
    [albumNameLabel setShadowColor:[UIColor darkGrayColor]];
    albumNameLabel.adjustsFontSizeToFitWidth = YES;
    return albumNameLabel;
}

-(void)setImageLink:(NSString *)imageLink{
    
    NSURL* url = [NSURL URLWithString:imageLink];
    [self.MJImageView sd_setImageWithURL:url completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, NSURL *imageURL) {
        NSString* albumName = @"Gidi and Tali in Berlin";
        [self addSubview:[self albumLabelWithName:albumName]];
        [self setImageOffset:self.imageOffset];
    }];
    
}


- (void)setImageOffset:(CGPoint)imageOffset
{
    // Store padding value
    _imageOffset = imageOffset;
    
    // Grow image view
    CGRect frame = self.MJImageView.bounds;
    CGRect offsetFrame = CGRectOffset(frame, _imageOffset.x, _imageOffset.y);
    self.MJImageView.frame = offsetFrame;
}

@end
