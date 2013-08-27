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
@property (nonatomic, assign) int inventoryCount;
@property (nonatomic, assign) int inventoryType;
@property (nonatomic, assign) int sleep;
@property (nonatomic, assign) int countdown;
@property (nonatomic, assign) int currState;

@property (nonatomic, retain) CCLabelTTF *debugLabel;

enum soldierState {
    passive = 0,
    gathering = 1,
    fullInventory = 2,
    attacking = 3,
    running = 4,
    building = 5
};

enum inventoryType {
    empty = 0,
    wood = 1,
    food = 2
};

+(Soldier *)makeSoldierAtPoint:(CGPoint)p inWorld:(b2World *)w;

-(void)showCurrState;

@end
