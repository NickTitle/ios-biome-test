//
//  Soldier.h
//  DecisionFighter
//
//  Created by Nicholas Esposito on 8/19/13.
//  Copyright 2013 NickTitle. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "cocos2d.h"
#import "Box2D.h"
#import "CCPhysicsSprite.h"
#import "Fort.h"

@interface Soldier : CCPhysicsSprite {
    
}

@property (nonatomic, assign) float health;
@property (nonatomic, assign) float speed;
@property (nonatomic, assign) int team;
@property (nonatomic, assign) int power;
@property (nonatomic, assign) float momX;
@property (nonatomic, assign) float momY;
@property (nonatomic, assign) Fort *fort;
@property (nonatomic, assign) float oldDistToFort;
@property (nonatomic, assign) int wood;

@property (nonatomic, assign) int countdown;
@property (nonatomic, assign) int currState;

enum soldierState {
    passive = 0,
    gathering = 1,
    fullInventory = 2,
    attacking = 3,
    running = 4,
    building = 5
};

@end
