//
//  Base.m
//  DecisionFighter
//
//  Created by Nicholas Esposito on 8/19/13.
//  Copyright 2013 NickTitle. All rights reserved.
//

#import "Fort.h"
#import "Soldier.h"

@implementation Fort

@synthesize health, team, reserveCount, soldierArray, woodCount, foodCount;

+(Fort *)makeFortAtPoint:(CGPoint)p inWorld:(b2World *)w {
    b2BodyDef bodyDef;
	bodyDef.type = b2_staticBody;
	bodyDef.position.Set(p.x/PTM_RATIO, p.y/PTM_RATIO);
	b2Body *body = w->CreateBody(&bodyDef);
    
    b2PolygonShape fBox;
    fBox.SetAsBox(.3,.3);
    
	b2FixtureDef fixtureDef;
	fixtureDef.shape = &fBox;
	body->CreateFixture(&fixtureDef);
    
    Fort *f;
    
    if (p.x > [[CCDirector sharedDirector] winSize].width/2) {
        f = [Fort spriteWithFile:@"baseP.png"];
        [f setTeam:teamA];
    }
    else {
        f = [Fort spriteWithFile:@"baseB.png" rect:CGRectMake(0, 0, 160, 160)];
        [f setTeam:teamB];
    }
    f.soldierArray = [NSMutableArray new];
    f.scale = .5;
    f.zOrder = baseZIndex;
	
	[f setPTMRatio:PTM_RATIO];
	[f setB2Body:body];
    body->SetUserData(f);
	[f setPosition: ccp( p.x, p.y)];
    
    return f;
};

-(void)takeSuppliesFromSoldier:(Soldier *)s {
    switch (s.inventoryType) {
        case wood:
            self.woodCount += s.inventoryCount;
            break;
        case food:
            self.foodCount += s.inventoryCount;
            break;
    }
    s.inventoryCount = 0;
    
    if (s.currState == fullInventory) {
        s.currState = gathering;
    }
    
    if (s.health < 100) {
        s.health += (100-s.health)/2;
    }
    
}





@end
