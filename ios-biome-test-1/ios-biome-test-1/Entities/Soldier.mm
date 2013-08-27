//
//  Soldier.m
//  DecisionFighter
//
//  Created by Nicholas Esposito on 8/19/13.
//  Copyright 2013 NickTitle. All rights reserved.
//

#import "Soldier.h"


@implementation Soldier

@synthesize health, speed, team, power, momX, momY, fort, oldDistToFort, currState, countdown, inventoryCount, inventoryType, sleep, debugLabel;

+(Soldier *)makeSoldierAtPoint:(CGPoint)p inWorld:(b2World *)w {
    
    b2BodyDef bodyDef;
	bodyDef.type = b2_dynamicBody;
	bodyDef.position.Set(p.x/PTM_RATIO, p.y/PTM_RATIO);
	b2Body *body = w->CreateBody(&bodyDef);
    
    b2CircleShape fCirc;
    fCirc.m_radius = .25;
    
	b2FixtureDef fixtureDef;
	fixtureDef.shape = &fCirc;
    fixtureDef.friction = .05;
	body->CreateFixture(&fixtureDef);
    
    Soldier *sprite;
    
    if (p.x > [[CCDirector sharedDirector] winSize].width/2) {
        sprite = [Soldier spriteWithFile:@"pink.png" rect:CGRectMake(0, 0, 32, 32)];
        [sprite setTeam:teamA];
    }
    else {
        sprite = [Soldier spriteWithFile:@"blu.png" rect:CGRectMake(0, 0, 32, 32)];
        [sprite setTeam:teamB];
    }
    
    sprite.scale = .5;
    
    sprite.speed = arc4random_uniform(5)+5;
    sprite.countdown = arc4random_uniform(300);
    sprite.currState = passive;
    sprite.momX = 0.0;
    sprite.momY = 0.0;
    sprite.health = 100;
    sprite.power = arc4random_uniform(5)+1;
    sprite.sleep = 0;
    sprite.zOrder = soldierZIndex;
	
	[sprite setPTMRatio:PTM_RATIO];
	[sprite setB2Body:body];
    body->SetUserData(sprite);
	[sprite setPosition: ccp( p.x, p.y)];

    
    return sprite;
}

-(void)showCurrState {
    if (debugLabel == nil) {
        debugLabel = [CCLabelTTF labelWithString:@"" fontName:@"Arial" fontSize:24];
        debugLabel.dimensions = CGSizeMake(64, 64);
        [self addChild:debugLabel];
        }

    NSString *newText;
    switch (currState) {
        case passive:
            newText = @"P";
            break;
        case gathering:
            newText = @"G";
            break;
        case fullInventory:
            newText = @"F";
            break;
        case attacking:
            newText = @"A";
            break;
        case running:
            newText = @"R";
            break;
        case building:
            newText = @"B";
            break;
    }
    newText = [NSString stringWithFormat:@"%@,%i", newText, wood];
    [debugLabel setString:newText];
}

@end
