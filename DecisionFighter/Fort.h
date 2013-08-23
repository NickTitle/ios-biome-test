//
//  Fort.h
//  DecisionFighter
//
//  Created by Nicholas Esposito on 8/19/13.
//  Copyright 2013 NickTitle. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "cocos2d.h"
#import "Box2D.h"
#import "CCPhysicsSprite.h"

@class Soldier;

@interface Fort : CCPhysicsSprite {

}

@property (nonatomic, assign) int health;
@property (nonatomic, assign) int team;
@property (nonatomic, assign) int reserveCount;
@property (nonatomic, assign) int countdown;
@property (nonatomic, assign) int woodCount;
@property (nonatomic, assign) int foodCount;
@property (nonatomic, retain) NSMutableArray *soldierArray;

-(void)takeSuppliesFromSoldier:(Soldier *)s;

@end
