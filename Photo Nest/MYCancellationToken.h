//
//  MYCancellationToken.h
//  Photo Nest
//
//  Created by Gal Skarishevsky on 10/7/14.
//  Copyright (c) 2014 Gal Skarishevsky. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface MYCancellationToken : NSObject
{
    BOOL cancelled;
}

-(void)setCancelled:(BOOL)shouldCancell;
-(BOOL)isCancelled;


@end
