//
//  Base.h
//  DecisionFighter
//
//  Created by Nicholas Esposito on 8/19/13.
//  Copyright 2013 NickTitle. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "cocos2d.h"
#import "Box2D.h"
#import "CCPhysicsSprite.h"

@interface Base : CCPhysicsSprite {

}

@property (nonatomic, assign) int health;
@property (nonatomic, assign) int team;
@property (nonatomic, assign) int reserveCount;
@property (nonatomic, retain) NSMutableArray *soldierArray;

@end
