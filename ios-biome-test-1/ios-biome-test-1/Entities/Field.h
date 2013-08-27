//
//  Field.h
//  DecisionFighter
//
//  Created by Nicholas Esposito on 8/23/13.
//  Copyright 2013 NickTitle. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "cocos2d.h"
#import "Box2D.h"
#import "CCPhysicsSprite.h"

@interface Field : CCPhysicsSprite {
    
}

@property (nonatomic, assign) int fieldState;
@property (nonatomic, assign) int growthCountdown;
@property (nonatomic, assign) BOOL tended;

enum grownState {
    dirt = 0,
    seed = 1,
    growing = 2,
    ripe = 4
};

+(Field *)makeFieldAtPoint:(CGPoint)p inWorld:(b2World *)w;

-(void)updateSprite;
-(void)resetGrowthCounter;
@end
