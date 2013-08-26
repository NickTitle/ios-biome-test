//
//  Tree.m
//  DecisionFighter
//
//  Created by Nicholas Esposito on 8/20/13.
//  Copyright 2013 NickTitle. All rights reserved.
//

#import "Tree.h"


@implementation Tree

@synthesize initialScale, initialWood, wood, isDamaged, growthCounter, thresholdWood, saplingGrowthCounter;

-(void)resetGrowthCounter {
    self.growthCounter = 100+arc4random_uniform(400);
}

@end
