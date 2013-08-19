//
//  Base.m
//  DecisionFighter
//
//  Created by Nicholas Esposito on 8/19/13.
//  Copyright 2013 NickTitle. All rights reserved.
//

#import "Base.h"

@implementation Base

int countdown = 600;

@synthesize health, team, reserveCount, soldierArray;

+(id)spriteWithFile:(NSString *)filename rect:(CGRect)rect {
    Base *s = [super spriteWithFile:filename rect:rect];
    s.soldierArray = [NSMutableArray new];
    return s;
}

@end
