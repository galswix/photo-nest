//
//  MYCancellationToken.m
//  Photo Nest
//
//  Created by Gal Skarishevsky on 10/7/14.
//  Copyright (c) 2014 Gal Skarishevsky. All rights reserved.
//

#import "MYCancellationToken.h"

@implementation MYCancellationToken

-(id)init{
    if (self = [super init]) {
        cancelled = NO;
    }
    return self;
}

-(BOOL)isCancelled{
    @synchronized(self){
        return cancelled;
    }
}
-(void)setCancelled:(BOOL)shouldCancell{
    @synchronized(self){
        cancelled = shouldCancell;
    }
}
@end
