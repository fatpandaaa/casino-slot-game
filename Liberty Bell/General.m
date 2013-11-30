//
//  General.m
//  Liberty Bell
//
//  Created by Lehel Medves on 5/24/13.
//  Copyright (c) 2013 Lehel Medves. All rights reserved.
//

#import "General.h"

@implementation General

+ (NSDictionary *) readConfig
{
    NSString *path = [[NSBundle mainBundle] pathForResource:@"config" ofType:@"ini"];
    
    NSDictionary *config = [[NSDictionary alloc] initWithContentsOfFile:path];
    
    return config;
}

@end
