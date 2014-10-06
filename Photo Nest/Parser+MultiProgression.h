//
//  Parser+MultiProgression.h
//  Photo Nest
//
//  Created by Gal Skarishevsky on 10/6/14.
//  Copyright (c) 2014 Gal Skarishevsky. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <Parse/Parse.h>

@interface  PFObject(MultiProgression)
+(void)saveAllInBackground:(NSArray *)array chunkSize:(int)chunkSize block:(PFBooleanResultBlock)block progressBlock:(PFProgressBlock)progressBlock;
@end
