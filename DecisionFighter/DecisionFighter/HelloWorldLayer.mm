//
//  HelloWorldLayer.mm
//  DecisionFighter
//
//  Created by Nicholas Esposito on 8/15/13.
//  Copyright NickTitle 2013. All rights reserved.
//

// Import the interfaces
#import "HelloWorldLayer.h"
#import "CCTouchDispatcher.h"
#import "SimpleContactListener.h"

// Not included in "cocos2d.h"
#import "CCPhysicsSprite.h"

#import "Base.h"
#import "Soldier.h"

// Needed to obtain the Navigation Controller
#import "AppDelegate.h"

NSMutableArray *baseArray;
NSMutableArray *killList;
SimpleContactListener *_contactListener;

int oldangle = 0;
CGPoint loc1 = ccp(200,300);
CGPoint loc2 = ccp (300, 100);
bool skip = TRUE;

enum {
	kTagParentNode = 1,
};


#pragma mark - HelloWorldLayer

@interface HelloWorldLayer()
-(void) initPhysics;
-(Soldier *) addNewSoldierAtLocation:(CGPoint)p;
-(void) createMenu;
@end

@implementation HelloWorldLayer

+(CCScene *) scene
{
	// 'scene' is an autorelease object.
	CCScene *scene = [CCScene node];
	
	// 'layer' is an autorelease object.
	HelloWorldLayer *layer = [HelloWorldLayer node];
	
	// add layer as a child to scene
	[scene addChild: layer];
	
	// return the scene
	return scene;
}

-(id) init
{
	if( (self=[super init])) {
		
		// enable events
		
		self.touchEnabled = YES;
		self.accelerometerEnabled = YES;
        baseArray = [NSMutableArray new];
        killList = [NSMutableArray new];
        
		
		// init physics
		[self initPhysics];
		
		// create reset button
		//[self createMenu];
		
		//Set up sprite
		[self scheduleUpdate];
	}
	return self;
}

-(void) registerWithTouchDispatcher {
    [[[CCDirector sharedDirector] touchDispatcher] addTargetedDelegate:self priority:0 swallowsTouches:TRUE];
}

-(BOOL) ccTouchBegan:(UITouch *)touch withEvent:(UIEvent *)event {
    if ([baseArray count]< 4) {
        CGPoint loc = [self convertTouchToNodeSpace:touch];
        Base *b = [self makeBaseAtLocation:loc];
        [baseArray addObject:b];
    }
    
    return YES;
}

-(void) ccTouchMoved:(UITouch *)touch withEvent:(UIEvent *)event {
}

-(void)ccTouchEnded:(UITouch *)touch withEvent:(UIEvent *)event
{
    
}

-(Base *)makeBaseAtLocation:(CGPoint)p {

    b2BodyDef bodyDef;
	bodyDef.type = b2_dynamicBody;
	bodyDef.position.Set(p.x/PTM_RATIO, p.y/PTM_RATIO);
	b2Body *body = world->CreateBody(&bodyDef);
	
    b2PolygonShape dynamicHex;
    b2Vec2 vertices[4];
    for (int i=0; i<4; i++) {
        float angle = -i/4.0 * 360 * M_PI/180;
        vertices[i].Set(sinf(angle),cosf(angle));
    }
    dynamicHex.Set(vertices, 4);
    
	b2FixtureDef fixtureDef;
	fixtureDef.shape = &dynamicHex;
	fixtureDef.density = .7f;
	fixtureDef.friction = 0.1f;
	body->CreateFixture(&fixtureDef);
    CCNode *parent = [self getChildByTag:kTagParentNode];
    
    
    Base *b;
    
    if (p.x > [[CCDirector sharedDirector] winSize].width/2) {
        b = [Base spriteWithFile:@"baseP.png" rect:CGRectMake(0, 0, 160, 160)];
        [b setTeam:teamA];
    }
    else {
        b = [Base spriteWithFile:@"baseB.png" rect:CGRectMake(0, 0, 160, 160)];
        [b setTeam:teamB];
    }
    
    [parent addChild:b];
	
	[b setPTMRatio:PTM_RATIO];
	[b setB2Body:body];
    body->SetUserData(b);
	[b setPosition: ccp( p.x, p.y)];
    
    [self makeSpritesForBase:b];
    
    return b;
}

-(void) makeSpritesForBase:(Base *)base {
    CGPoint loc = base.position;
    
    for (int i = 0; i < 5; i++) {
    
        Soldier *gG = [self addNewSoldierAtLocation:loc];
        gG.base = base;
        [base.soldierArray addObject:gG];
        [self addChild:gG];
    }
}

-(void) killSpritesForTouch:(UITouch *)touch {
//    NSMutableArray *killIndex = [NSMutableArray new];
//    for (Soldier *s in gGArray) {
//        if ([s.touch isEqual:touch]) {
//            [killIndex addObject:s];
//        }
//    }
//    for (Soldier *s in killIndex) {
//        [gGArray removeObject:s];
//        world->DestroyBody(s.b2Body);
//        [s removeFromParentAndCleanup:YES];
//        s = nil;
//    }
}

-(void) nextFrame:(ccTime)dt {
    
}

-(void) updateLocation:(ccTime)dt {
    
}

-(void) createMenu
{

}

-(void) initPhysics
{
	
	CGSize s = [[CCDirector sharedDirector] winSize];
	
	b2Vec2 gravity;
	gravity.Set(0.0f, 0.0f);
	world = new b2World(gravity);
    _contactListener = new SimpleContactListener(self);
    world->SetContactListener(_contactListener);
	
	
	// Do we want to let bodies sleep?
	world->SetAllowSleeping(true);
	
	world->SetContinuousPhysics(true);
	
//	m_debugDraw = new GLESDebugDraw( PTM_RATIO );
//	world->SetDebugDraw(m_debugDraw);
	
//	uint32 flags = 0;
//	flags += b2Draw::e_shapeBit;
	//		flags += b2Draw::e_jointBit;
	//		flags += b2Draw::e_aabbBit;
	//		flags += b2Draw::e_pairBit;
	//		flags += b2Draw::e_centerOfMassBit;
//	m_debugDraw->SetFlags(flags);
	
	
	// Define the ground body.
	b2BodyDef groundBodyDef;
	groundBodyDef.position.Set(0, 0); // bottom-left corner
	
	// Call the body factory which allocates memory for the ground body
	// from a pool and creates the ground box shape (also from a pool).
	// The body is also added to the world.
	b2Body* groundBody = world->CreateBody(&groundBodyDef);
	
	// Define the ground box shape.
	b2EdgeShape groundBox;		
	
	// bottom
	
	groundBox.Set(b2Vec2(0,0), b2Vec2(s.width/PTM_RATIO,0));
	groundBody->CreateFixture(&groundBox,0);

	// top
	groundBox.Set(b2Vec2(0,s.height/PTM_RATIO), b2Vec2(s.width/PTM_RATIO,s.height/PTM_RATIO));
	groundBody->CreateFixture(&groundBox,0);

	// left
	groundBox.Set(b2Vec2(0,s.height/PTM_RATIO), b2Vec2(0,0));
	groundBody->CreateFixture(&groundBox,0);

	// right
	groundBox.Set(b2Vec2(s.width/PTM_RATIO,s.height/PTM_RATIO), b2Vec2(s.width/PTM_RATIO,0));
	groundBody->CreateFixture(&groundBox,0);
}

-(void) draw
{
	//
	// IMPORTANT:
	// This is only for debug purposes
	// It is recommend to disable it
	//
//	[super draw];
//	ccGLEnableVertexAttribs( kCCVertexAttribFlag_Position );
//	kmGLPushMatrix();
//	world->DrawDebugData();
//	kmGLPopMatrix();
//    kmGLPushMatrix();
//    kmGLScalef(CC_CONTENT_SCALE_FACTOR(), CC_CONTENT_SCALE_FACTOR(), 1.0f);
//    world->DrawDebugData();
//    kmGLPopMatrix();
}

-(Soldier *)addNewSoldierAtLocation:(CGPoint)p
{

	b2BodyDef bodyDef;
	bodyDef.type = b2_dynamicBody;
	bodyDef.position.Set(p.x/PTM_RATIO, p.y/PTM_RATIO);
	b2Body *body = world->CreateBody(&bodyDef);
	
    b2PolygonShape dynamicHex;
    b2Vec2 vertices[6];
    for (int i=0; i<6; i++) {
        float angle = -i/6.0 * 360 * M_PI/180;
        vertices[i].Set(sinf(angle)/2,cosf(angle)/2);
    }
    dynamicHex.Set(vertices, 6);

	b2FixtureDef fixtureDef;
	fixtureDef.shape = &dynamicHex;
	fixtureDef.density = .7f;
	fixtureDef.friction = 0.1f;
	body->CreateFixture(&fixtureDef);
    CCNode *parent = [self getChildByTag:kTagParentNode];
    
    Soldier *sprite;
    
    if (p.x > [[CCDirector sharedDirector] winSize].width/2) {
        sprite = [Soldier spriteWithFile:@"pink.png" rect:CGRectMake(0, 0, 32, 32)];
        [sprite setTeam:teamA];
    }
    else {
        sprite = [Soldier spriteWithFile:@"blu.png" rect:CGRectMake(0, 0, 32, 32)];
        [sprite setTeam:teamB];
    }
    
    sprite.speed = arc4random_uniform(10)+5;
    sprite.momX = 0.0;
    sprite.momY = 0.0;
    sprite.health = 100;
    sprite.power = arc4random_uniform(5)+1;
    
	[parent addChild:sprite];
	
	[sprite setPTMRatio:PTM_RATIO];
	[sprite setB2Body:body];
    body->SetUserData(sprite);
	[sprite setPosition: ccp( p.x, p.y)];
    
    return sprite;

}

-(void) update: (ccTime) dt
{
	//It is recommended that a fixed time step is used with Box2D for stability
	//of the simulation, however, we are using a variable time step here.
	//You need to make an informed choice, the following URL is useful
	//http://gafferongames.com/game-physics/fix-your-timestep/
	
	int32 velocityIterations = 8;
	int32 positionIterations = 3;
	
	// Instruct the world to perform a single step of simulation. It is
	// generally best to keep the time step and iterations fixed
    
    [self updateSoldierMomentums];
//    if ([killList count]) {
//    [self killCollidedSprites];
//    }
	
    world->Step(dt, velocityIterations, positionIterations);
}

-(void)beginContact:(b2Contact *)contact {
    
    b2Fixture *fixtureA = contact->GetFixtureA();
    b2Fixture *fixtureB = contact->GetFixtureB();
    b2Body *bodyA = fixtureA->GetBody();
    b2Body *bodyB = fixtureB->GetBody();
    
    id dA = (id)bodyA->GetUserData();
    id dB = (id)bodyB->GetUserData();
    if (dA == nil || dB == nil) {
        return;
    }
    else if ([dA isKindOfClass:[Soldier class]] && [dB isKindOfClass:[Soldier class]]) {
        [self collideSoldierA:dA soldierB:dB];
    };
}

-(void)endContact:(b2Contact *)contact {
    
}

-(void)collideSoldierA:(Soldier *)sA soldierB:(Soldier *)sB {
    
    if (sA.team == sB.team) {
        return;
    }
    else {
        b2Body *bodyA = sA.b2Body;
        b2Body *bodyB = sB.b2Body;
        
        CGFloat aA = bodyA->GetAngle();
        CGFloat aB = bodyB->GetAngle();
        
        b2Vec2 pA = bodyA->GetPosition();
        b2Vec2 pB = bodyB->GetPosition();
        
        CGFloat dx1 = pB.x-pA.x;
        CGFloat dy1 = pB.y-pA.y;
        
        CGFloat aAB = atan2f(dy1, dx1);
        
        CGFloat dx2 = pA.x-pB.x;
        CGFloat dy2 = pA.y-pB.y;
        
        CGFloat aBA = atan2f(dy2, dx2);
        
        Soldier *killObj;
        if (abs(aA-aAB)<abs(aB-aBA)) {
            killObj = sA;
        }
        else {
            killObj = sB;
        }
        
        if (![killList containsObject:killObj]) {
            [killList addObject:killObj];
        }
    }

}

-(void)killCollidedSprites {
    for (Soldier *s in killList) {
    world->DestroyBody(s.b2Body);
    [s removeFromParentAndCleanup:YES];
    s = nil;
    }
    [killList removeAllObjects];
}

-(void)updateSoldierMomentums {
    skip = !skip;
    if (skip)
        return;
    for (Base *b in baseArray) {
        [self updateSoldiersForBase:b];
    }
}

- (void)updateSoldiersForBase:(Base *)b {
    for (Soldier *sD in b.soldierArray) {
        CGPoint sP = sD.position;
        
        CGPoint loc = b.position;
        CGFloat dx1 = loc.x-sP.x;
        CGFloat dy1 = loc.y-sP.y;
        
        CGFloat angle = atan2f(dy1, dx1);
        
        sD.momX += cos(angle);
        sD.momY += sin(angle);
        
        b2Vec2 vel = sD.b2Body->GetLinearVelocity();
        vel.x += sD.momX*1.5;
        vel.y += sD.momY*1.5;
        
        CGFloat totalMomentum = abs(vel.x)+abs(vel.y);
        if (totalMomentum > sD.speed) {
            CGFloat scale = sD.speed/totalMomentum;
            vel.x *= scale;
            vel.y *= scale;
        }
        
        sD.b2Body->SetLinearVelocity(vel);
        float bodyAngle = atan2f(vel.y, vel.x);
        sD.b2Body->SetTransform( sD.b2Body->GetWorldCenter(), bodyAngle);
        
        sD.momX = vel.x;
        sD.momY = vel.y;
        
    }
}

-(void) dealloc
{
	delete world;
	world = NULL;
	
	delete m_debugDraw;
	m_debugDraw = NULL;
    
    delete _contactListener;
	
	[super dealloc];
}

#pragma mark GameKit delegate

-(void) achievementViewControllerDidFinish:(GKAchievementViewController *)viewController
{
	AppController *app = (AppController*) [[UIApplication sharedApplication] delegate];
	[[app navController] dismissModalViewControllerAnimated:YES];
}

-(void) leaderboardViewControllerDidFinish:(GKLeaderboardViewController *)viewController
{
	AppController *app = (AppController*) [[UIApplication sharedApplication] delegate];
	[[app navController] dismissModalViewControllerAnimated:YES];
}

@end
