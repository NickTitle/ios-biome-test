//
//  Field.m
//  DecisionFighter
//
//  Created by Nicholas Esposito on 8/23/13.
//  Copyright 2013 NickTitle. All rights reserved.
//

#import "Field.h"


@implementation Field

@synthesize fieldState;
@synthesize growthCountdown;
@synthesize tended;

+(Field *)makeFieldAtPoint:(CGPoint)p inWorld:(b2World *)w {
    
    
    b2BodyDef bodyDef;
	bodyDef.type = b2_staticBody;
	bodyDef.position.Set(p.x/PTM_RATIO, p.y/PTM_RATIO);
	b2Body *body = w->CreateBody(&bodyDef);
    
    b2PolygonShape fShape;
    fShape.SetAsBox(.25, .25);
    
	b2FixtureDef fixtureDef;
	fixtureDef.shape = &fShape;
    fixtureDef.friction = 0;
	body->CreateFixture(&fixtureDef);
    
    Field *f;
    f = [Field spriteWithFile:@"field.png" rect:CGRectMake(0, 0, 32, 32)];
    
    f.scale = .5;
    f.fieldState = dirt;
    f.growthCountdown = 500;
    f.tended = FALSE;

	[f setPTMRatio:PTM_RATIO];
	[f setB2Body:body];
    body->SetUserData(f);
	[f setPosition: ccp( p.x, p.y)];
    
    return f;
}

-(void)updateSprite {
    switch (fieldState) {
        case dirt:
            [self setTextureRect:CGRectMake(0, 0, 32, 32)];
            break;
        case seed:
            [self setTextureRect:CGRectMake(32, 0, 32, 32)];
            break;
        case growing:
            [self setTextureRect:CGRectMake(0, 32, 32, 32)];
            break;
        case ripe:
            [self setTextureRect:CGRectMake(32, 32, 32, 32)];
            break;
    }
}

-(void)resetGrowthCounter {
    self.growthCountdown = 400+arc4random_uniform(400);
}
@end
