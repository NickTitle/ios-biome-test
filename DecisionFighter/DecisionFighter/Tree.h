//
//  Tree.h
//  DecisionFighter
//
//  Created by Nicholas Esposito on 8/20/13.
//  Copyright 2013 NickTitle. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "cocos2d.h"
#import "CCPhysicsSprite.h"

@interface Tree : CCPhysicsSprite {
    
}

@property (nonatomic, assign) float initialScale;
@property (nonatomic, assign) int initialWood;
@property (nonatomic, assign) int wood;
@property (nonatomic, assign) int thresholdWood;
@property (nonatomic, assign) BOOL isDamaged;
@property (nonatomic, assign) int saplingGrowthCounter;
@property (nonatomic, assign) int growthCounter;

-(void)resetGrowthCounter;
@end
