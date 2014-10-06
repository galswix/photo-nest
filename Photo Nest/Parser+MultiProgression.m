//
//  Parser+MultiProgression.m
//  Photo Nest
//
//  Created by Gal Skarishevsky on 10/6/14.
//  Copyright (c) 2014 Gal Skarishevsky. All rights reserved.
//

#import "Parser+MultiProgression.h"

@implementation PFObject(MultiProgression)
+(void)saveAllInBackground:(NSArray *)array chunkSize:(int)chunkSize block:(PFBooleanResultBlock)block progressBlock:(PFProgressBlock)progressBlock
{
    unsigned long numberOfCyclesRequired = array.count/chunkSize;
    __block unsigned long count = 0;
    [PFObject saveAllInBackground:array chunkSize:chunkSize block:block trigger:^(BOOL trig) {
        count++;
        progressBlock((int)(100.0*count/numberOfCyclesRequired));
    }];
}

+(void)saveAllInBackground:(NSArray *)array chunkSize:(int)chunkSize block:(PFBooleanResultBlock)block trigger:(void(^)(BOOL trig))trigger
{
    
    NSRange range = NSMakeRange(0, array.count <= chunkSize ? array.count:chunkSize);
    NSArray *saveArray = [array subarrayWithRange:range];
    NSArray *nextArray = nil;
    if (range.length<array.count) nextArray = [array subarrayWithRange:NSMakeRange(range.length, array.count-range.length)];
    [PFObject saveAllInBackground:saveArray block:^(BOOL succeeded, NSError *error) {
        if(!error && succeeded && nextArray){
            trigger(true);
            [PFObject saveAllInBackground:nextArray chunkSize:chunkSize block:block trigger:trigger];
        }
        else
        {
            trigger(true);
            block(succeeded,error);
        }
    }];
}

@end