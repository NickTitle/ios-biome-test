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

#import "Fort.h"
#import "Soldier.h"
#import "Tree.h"

// Needed to obtain the Navigation Controller
#import "AppDelegate.h"

NSMutableArray *fortArray;
NSMutableArray *treeArray;

NSMutableArray *killList;
SimpleContactListener *_contactListener;
CCLabelTTF *toolLabel;

int oldangle = 0;
CGPoint loc1 = ccp(200,300);
CGPoint loc2 = ccp (300, 100);
bool skip = TRUE;
int currentToolTag = 0;

enum {
	kTagParentNode = 1,
};

enum toolTags{
    baseToolTag = 990,
    treeToolTag = 991,
    deleteToolTag = 992
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
        fortArray = [NSMutableArray new];
        treeArray = [NSMutableArray new];
        killList = [NSMutableArray new];
        
		
		// init physics
		[self initPhysics];
		
		// create reset button
        [self createMenu];
        
		//Set up sprite
		[self scheduleUpdate];
	}
	return self;
}

-(void) registerWithTouchDispatcher {
    [[[CCDirector sharedDirector] touchDispatcher] addTargetedDelegate:self priority:0 swallowsTouches:TRUE];
}

-(void) createMenu {
    CGSize winSize = [[CCDirector sharedDirector] winSize];
    
    toolLabel = [[CCLabelTTF labelWithString:@"Tool:Bases" fontName:@"Helvetica" fontSize:32.0] retain];
    toolLabel.dimensions = CGSizeMake(320, 50);
    toolLabel.position = ccp(winSize.width/2, winSize.height-toolLabel.contentSize.height/2);
    [self addChild:toolLabel];
    
    CCMenuItem *baseMenuItem = [CCMenuItemImage itemWithNormalImage:@"baseB.png" selectedImage:@"baseB.png" disabledImage:@"baseB.png" target:self selector:@selector(toolSelected:)];
    baseMenuItem.tag = baseToolTag;
    baseMenuItem.scale = .25;
    baseMenuItem.position = ccp(32, winSize.height - 64);
    
    CCMenuItem *treeMenuItem = [CCMenuItemImage itemWithNormalImage:@"tree.png" selectedImage:@"tree.png" disabledImage:@"tree.png" target:self selector:@selector(toolSelected:)];
    treeMenuItem.tag = treeToolTag;
    treeMenuItem.scale = .5;
    treeMenuItem.position = ccp(32, winSize.height - 128);
    
    CCMenu *toolMenu = [CCMenu menuWithItems:baseMenuItem, treeMenuItem, nil];
    toolMenu.position = ccp(0,0);
    toolMenu.zOrder = 999;
    [self addChild:toolMenu];
}

-(BOOL) ccTouchBegan:(UITouch *)touch withEvent:(UIEvent *)event {
    switch (currentToolTag) {
        case baseToolTag:
            [self touchToFortAction:touch];
            break;
            
        case treeToolTag:
            [self touchToTreeAction:touch];
            break;
            
        case deleteToolTag:
            [self touchToDeleteAction:touch];
            break;
    }
    
    return YES;
}

-(void) ccTouchMoved:(UITouch *)touch withEvent:(UIEvent *)event {
}

-(void)ccTouchEnded:(UITouch *)touch withEvent:(UIEvent *)event
{
    
}

-(void)touchToFortAction:(UITouch *)touch {
    if ([fortArray count]< 4) {
        CGPoint loc = [self convertTouchToNodeSpace:touch];
        Fort *f = [self makeFortAtLocation:loc];
        [fortArray addObject:f];
        [self addChild:f];
    }
}

-(void)touchToTreeAction:(UITouch *)touch {
    if ([treeArray count]< 200) {
        CGPoint loc = [self convertTouchToNodeSpace:touch];
        Tree *t = [self makeTreeAtLocation:loc];
        [treeArray addObject:t];
        [self addChild:t];
    }
}

-(Fort *)makeFortAtLocation:(CGPoint)p {

    b2BodyDef bodyDef;
	bodyDef.type = b2_staticBody;
	bodyDef.position.Set(p.x/PTM_RATIO, p.y/PTM_RATIO);
	b2Body *body = world->CreateBody(&bodyDef);
    
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
	
	[f setPTMRatio:PTM_RATIO];
	[f setB2Body:body];
    body->SetUserData(f);
	[f setPosition: ccp( p.x, p.y)];
    
    [self makeSpritesForFort:f];
    
    return f;
}

-(void) makeSpritesForFort:(Fort *)f {
    CGPoint loc = f.position;
    
    for (int i = 0; i < 5; i++) {
    
        Soldier *gG = [self addNewSoldierAtLocation:loc];
        gG.fort = f;
        [f.soldierArray addObject:gG];
        [self addChild:gG];
    }
}

-(Soldier *)addNewSoldierAtLocation:(CGPoint)p
{
    
	b2BodyDef bodyDef;
	bodyDef.type = b2_dynamicBody;
	bodyDef.position.Set(p.x/PTM_RATIO, p.y/PTM_RATIO);
	b2Body *body = world->CreateBody(&bodyDef);
	
    b2PolygonShape hexBox;
    hexBox.SetAsBox(.25, .25);
    
	b2FixtureDef fixtureDef;
	fixtureDef.shape = &hexBox;
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
    
    sprite.scale = .5;
    
    sprite.speed = arc4random_uniform(5)+5;
    sprite.countdown = arc4random_uniform(300);
    sprite.currState = passive;
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

-(Tree *)makeTreeAtLocation:(CGPoint)p {
    
    b2BodyDef bodyDef;
	bodyDef.type = b2_staticBody;
	bodyDef.position.Set(p.x/PTM_RATIO, p.y/PTM_RATIO);
	b2Body *body = world->CreateBody(&bodyDef);
    
    b2PolygonShape fBox;
    fBox.SetAsBox(.25,.25);
    
	b2FixtureDef fixtureDef;
	fixtureDef.shape = &fBox;
	body->CreateFixture(&fixtureDef);
    
    Tree *t = [Tree spriteWithFile:@"tree.png" rect:CGRectMake(0, 0, 64, 64)];
    t.scale = .5;
	t.wood = arc4random_uniform(50)+5;
	[t setPTMRatio:PTM_RATIO];
	[t setB2Body:body];
    body->SetUserData(t);
	[t setPosition: ccp( p.x, p.y)];
    t.b2Body->SetTransform( t.b2Body->GetWorldCenter(), arc4random_uniform(3.14));
    return t;
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



-(void)toolSelected:(id)sender {
    NSString *toolType;
    switch ([sender tag]) {
        case baseToolTag: {
            toolType = @"Bases";
            break;
        }
        case treeToolTag: {
            toolType = @"Trees";
            break;
        }
        case deleteToolTag: {
            toolType = @"Delete";
            break;
        }
    }
    currentToolTag = [sender tag];
    [toolLabel setString:[NSString stringWithFormat:@"Tool:%@", toolType]];
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
	
	m_debugDraw = new GLESDebugDraw( PTM_RATIO );
	world->SetDebugDraw(m_debugDraw);
	
	uint32 flags = 0;
	flags += b2Draw::e_shapeBit;
	//		flags += b2Draw::e_jointBit;
	//		flags += b2Draw::e_aabbBit;
	//		flags += b2Draw::e_pairBit;
	//		flags += b2Draw::e_centerOfMassBit;
	m_debugDraw->SetFlags(flags);
	
	
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
    if ([killList count]) {
    [self killCollidedSprites];
    }
	
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
//        [self collideSoldierA:dA soldierB:dB];
    }
    else if (([dA isKindOfClass:[Soldier class]] && [dB isKindOfClass:[Tree class]]) || ([dA isKindOfClass:[Tree class]] && [dB isKindOfClass:[Soldier class]])){
        if ([dA class] == [Tree class]) {
            [self collideSoldier:dB andTree:dA];
        }
        else {
            [self collideSoldier:dA andTree:dB];
        }
    }
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

-(void)collideSoldier:(Soldier *)s andTree:(Tree *)t {
    
//    if (s.wood >= 25) {
//        s.currState = passive;
//        return;
//    }
//    else {
    
        s.wood += (MIN(t.wood, s.power));
        t.wood -= s.power;
        
        if (t.wood <= 0) {
            [treeArray removeObject:t];
            if (![killList containsObject:t]) {
                [killList addObject:t];
            }
        }
//    }
    
}


-(void)killCollidedSprites {
    for (CCPhysicsSprite *s in killList) {
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
    for (Fort *f in fortArray) {
        [self updateSoldiersForFort:f];
    }
}

- (void)updateSoldiersForFort:(Fort *)f {
    
    for (Soldier *sD in f.soldierArray) {
        
        if (sD.countdown > 0) {
            sD.countdown -= 1;
        }
        else {
            sD.countdown = arc4random_uniform(600);
            if (sD.currState == passive) {
                sD.currState = gathering;
            }
            else {
                sD.currState = passive;
            }
        }
        
        CGPoint destination;
        if (sD.currState == passive) {
            destination = f.position;
        }
        else {
            destination = [self nearestTreeToPos:sD.position];
        }

        CGPoint sP = sD.position;
        CGFloat dx1 = destination.x-sP.x;
        CGFloat dy1 = destination.y-sP.y;
        CGFloat angle = atan2f(dy1, dx1);
        
        float newDist;
        
        b2Vec2 vel = sD.b2Body->GetLinearVelocity();
        
        if (sD.currState == passive) {
            
            newDist = ccpDistance(sD.position, f.position);
            
            sD.momX += cos(angle);
            sD.momY += sin(angle);
            
            vel.x += sD.momX;
            vel.y += sD.momY;
            
            CGFloat totalMomentum = abs(vel.x)+abs(vel.y);
            
//            if (newDist <= 64) {
//                vel.x *= .3;
//                vel.y *= .3;
//            }
//            else {
                if (totalMomentum > sD.speed) {
                    CGFloat scale = sD.speed/totalMomentum;
                    vel.x *= scale;
                    vel.y *= scale;
                }
//                if (newDist > sD.oldDistToFort) {
//                    vel.x *= .75;
//                    vel.y *= .75;
//                }
//            }
            
        }
        
        sD.b2Body->SetLinearVelocity(vel);
        float bodyAngle = atan2f(vel.y, vel.x);
        sD.b2Body->SetTransform( sD.b2Body->GetWorldCenter(), bodyAngle);
        
        sD.momX = vel.x;
        sD.momY = vel.y;
        sD.oldDistToFort = newDist;
    }
}

-(CGPoint)nearestTreeToPos:(CGPoint)p {
    CGFloat minDist = 9999;
    Tree *targetTree = nil;
    for (Tree *t in treeArray) {
        CGFloat tDist = ccpDistance(p, t.position);
        if (tDist < minDist) {
            targetTree = t;
            minDist = tDist;
        }
    }
        return targetTree.position;
}

-(void) dealloc
{
	delete world;
	world = NULL;
	
	delete m_debugDraw;
	m_debugDraw = NULL;
    
    delete _contactListener;
    
	[toolLabel release];
    toolLabel = nil;
	
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
