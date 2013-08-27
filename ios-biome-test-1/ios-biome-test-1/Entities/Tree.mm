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
//    self.growthCounter = 10+arc4random_uniform(10);
}

+(Tree *)makeTreeAtPoint:(CGPoint)p inWorld:(b2World *)w {
    b2BodyDef bodyDef;
	bodyDef.type = b2_staticBody;
	bodyDef.position.Set(p.x/PTM_RATIO, p.y/PTM_RATIO);
	b2Body *body = w->CreateBody(&bodyDef);
    
    b2CircleShape fCirc;
    fCirc.m_radius = .25;
    
	b2FixtureDef fixtureDef;
	fixtureDef.shape = &fCirc;
	body->CreateFixture(&fixtureDef);
    
    Tree *t = [Tree spriteWithFile:@"tree.png" rect:CGRectMake(0, 0, 64, 64)];
    t.initialWood = 30+(arc4random_uniform(40));
	t.wood = t.initialWood;
    t.scale = (float)t.wood/float(treeMaxWood);
    t.thresholdWood = .6*t.wood;
    t.zOrder = treeZIndex;
    [t resetGrowthCounter];
	[t setPTMRatio:PTM_RATIO];
	[t setB2Body:body];
    body->SetUserData(t);
	[t setPosition: ccp( p.x, p.y)];
    t.b2Body->SetTransform( t.b2Body->GetWorldCenter(), arc4random_uniform(3.14));
    
    return t;

}

@end
