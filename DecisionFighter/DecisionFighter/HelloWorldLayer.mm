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
#import "Field.h"

// Needed to obtain the Navigation Controller
#import "AppDelegate.h"

NSMutableArray *fortArray;
NSMutableArray *saplingArray;
NSMutableArray *fieldArray;
NSMutableArray *treeArray;

NSMutableArray *killList;
SimpleContactListener *_contactListener;
CCLabelTTF *toolLabel;
CGSize winSize;

bool skip = TRUE;
int currentToolTag = 0;
int dragCountdown = 0;
enum {
	kTagParentNode = 1,
};

enum toolTags{
    baseToolTag = 990,
    treeToolTag = 991,
    fieldToolTag = 992,
    deleteToolTag = 993
};

#pragma mark - HelloWorldLayer

@interface HelloWorldLayer()
-(void) initPhysics;
-(Soldier *) addNewSoldierAtLocation:(CGPoint)p;
-(void) createMenu;
@end

@implementation HelloWorldLayer

#pragma mark - INIT

+(CCScene *) scene
{
	CCScene *scene = [CCScene node];
	HelloWorldLayer *layer = [HelloWorldLayer node];
	[scene addChild: layer];
	return scene;
}

-(id) init
{
	if( (self=[super init])) {
		self.touchEnabled = YES;
		self.accelerometerEnabled = YES;
        fortArray = [NSMutableArray new];
        saplingArray = [NSMutableArray new];
        treeArray = [NSMutableArray new];
        fieldArray = [NSMutableArray new];
        killList = [NSMutableArray new];
        winSize = [[CCDirector sharedDirector] winSize];
        
		[self initPhysics];
        [self createMenu];
		[self scheduleUpdate];
	}
    
    [self createRandEntities];
    
	return self;
}

-(void) registerWithTouchDispatcher {
    [[[CCDirector sharedDirector] touchDispatcher] addTargetedDelegate:self priority:0 swallowsTouches:TRUE];
}

-(void) createMenu {
    
    toolLabel = [[CCLabelTTF labelWithString:@"Tool: " fontName:@"Helvetica" fontSize:32.0] retain];
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
    
    CCMenuItem *fieldMenuItem = [CCMenuItemImage itemWithNormalImage:@"field.png" selectedImage:@"field.png" disabledImage:@"field.png" target:self selector:@selector(toolSelected:)];
    fieldMenuItem.tag = fieldToolTag;
    fieldMenuItem.scale = .5;
    fieldMenuItem.position = ccp(32, winSize.height - 196);
    
    CCMenu *toolMenu = [CCMenu menuWithItems:baseMenuItem, treeMenuItem, fieldMenuItem, nil];
    toolMenu.position = ccp(0,0);
    toolMenu.zOrder = 999;
    [self addChild:toolMenu];
}

-(void)createRandEntities {
    for (int i=0; i<4; i++) {
        [self makeFortAtLocation:ccp(arc4random_uniform(winSize.width-100)+50, arc4random_uniform(winSize.height-50)+25)];
    }
    for (int i=0; i<50; i++) {
        [self makeTreeAtLocation:ccp(arc4random_uniform(winSize.width-100)+50, arc4random_uniform(winSize.height-50)+25)];
    }
}

-(void) initPhysics
{	
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
	
	groundBox.Set(b2Vec2(0,0), b2Vec2(winSize.width/PTM_RATIO,0));
	groundBody->CreateFixture(&groundBox,0);
    
	// top
	groundBox.Set(b2Vec2(0,winSize.height/PTM_RATIO), b2Vec2(winSize.width/PTM_RATIO,winSize.height/PTM_RATIO));
	groundBody->CreateFixture(&groundBox,0);
    
	// left
	groundBox.Set(b2Vec2(0,winSize.height/PTM_RATIO), b2Vec2(0,0));
	groundBody->CreateFixture(&groundBox,0);
    
	// right
	groundBox.Set(b2Vec2(winSize.width/PTM_RATIO,winSize.height/PTM_RATIO), b2Vec2(winSize.width/PTM_RATIO,0));
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

#pragma mark - Touches

-(BOOL) ccTouchBegan:(UITouch *)touch withEvent:(UIEvent *)event {
    [self createEntityWithToolAndTouch:touch];
    return YES;
}

-(void) ccTouchMoved:(UITouch *)touch withEvent:(UIEvent *)event {
    if (dragCountdown >0) {
        dragCountdown -= 1;
    }
    else {
        dragCountdown = 5;
        [self createEntityWithToolAndTouch:touch];
    }
}

-(void)ccTouchEnded:(UITouch *)touch withEvent:(UIEvent *)event
{
    
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
        case fieldToolTag: {
            toolType = @"Fields";
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

-(void) createEntityWithToolAndTouch:(UITouch *)touch {
    switch (currentToolTag) {
        case baseToolTag:
            [self touchToFortAction:touch];
            break;
            
        case treeToolTag:
            [self touchToTreeAction:touch];
            break;
        case fieldToolTag:
            [self touchToFieldAction:touch];
            break;
        case deleteToolTag:
            [self touchToDeleteAction:touch];
            break;
    }
}

-(void)touchToFortAction:(UITouch *)touch {
    [self makeFortAtLocation:[self convertTouchToNodeSpace:touch]];
}

-(void)touchToTreeAction:(UITouch *)touch {
    [self makeTreeAtLocation:[self convertTouchToNodeSpace:touch]];
}

-(void)touchToFieldAction:(UITouch *)touch {
    [self makeFieldAtLocation:[self convertTouchToNodeSpace:touch]];
}
#pragma mark - Constructors

-(void)makeFortAtLocation:(CGPoint)p {
    if ([fortArray count]> 4)
        return;
    
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
    
    if (p.x > winSize.width/2) {
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
    
    [self makeSpritesForFort:f];
    [fortArray addObject:f];
    [self addChild:f];
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
    Soldier *s = [Soldier makeSoldierAtPoint:p inWorld:world];
    return s;
}

-(void)makeFieldAtLocation:(CGPoint)p {
    Field *f = [Field makeFieldAtPoint:p inWorld:world];
    [fieldArray addObject:f];
    [self addChild:f];
}

-(void)makeTreeAtLocation:(CGPoint)p {
    if ([treeArray count]> 175) {
        return;
    }
    b2BodyDef bodyDef;
	bodyDef.type = b2_staticBody;
	bodyDef.position.Set(p.x/PTM_RATIO, p.y/PTM_RATIO);
	b2Body *body = world->CreateBody(&bodyDef);
    
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

    [treeArray addObject:t];
    [self addChild:t];
}

#pragma mark - COLLISIONS
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
    else if (([dA isKindOfClass:[Soldier class]] && [dB isKindOfClass:[Fort class]]) || ([dA isKindOfClass:[Fort class]] && [dB isKindOfClass:[Soldier class]])){
        if ([dA class] == [Fort class]) {
            [self collideSoldier:dB andFort:dA];
        }
        else {
            [self collideSoldier:dA andFort:dB];
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
    if (s.sleep > 0) {
        s.sleep -= 1;
        return;
    }
    
    if (s.currState == gathering) {
        s.inventoryCount += (MIN(t.wood, s.power));
        s.inventoryType = wood;
        t.wood -= s.power;
        t.scale = (float)t.wood/treeMaxWood;
        [t resetGrowthCounter];
        
        if (t.wood <= 0) {
            [treeArray removeObject:t];
            if (![killList containsObject:t]) {
                [killList addObject:t];
            }
        }
        
        if (s.inventoryCount >= 10) {
            s.currState = fullInventory;
        }
        
        s.sleep = 20;
    }
}

-(void)collideSoldier:(Soldier *)s andFort:(Fort *)f {
    
    [f takeSuppliesFromSoldier:s];
    
}

-(void)killCollidedSprites {
    for (CCPhysicsSprite *s in killList) {
    world->DestroyBody(s.b2Body);
    [s removeFromParentAndCleanup:YES];
    s = nil;
    }
    [killList removeAllObjects];
}

-(void)plantSaplings {
    for (int i=0; i < [saplingArray count]; i++) {
        CGPoint p = [[saplingArray objectAtIndex:0] CGPointValue];
        [self makeTreeAtLocation:p];
    }
    [saplingArray removeAllObjects];
}

#pragma mark - UPDATES

-(void) update: (ccTime) dt {
	//http://gafferongames.com/game-physics/fix-your-timestep/
	
	int32 velocityIterations = 8;
	int32 positionIterations = 3;

    float maximumStep = 0.08;
    float progress = 0.0;
    while (progress < dt)
    {
        float step = min((dt-progress), maximumStep);
        world->Step(dt, velocityIterations, positionIterations);
        progress += step;
    }
    
    [self updateSoldiers];
    [self updateTrees];
    [self updateFields];
    if ([killList count]) { [self killCollidedSprites]; }
    if ([saplingArray count]) { [self plantSaplings]; }
	
}

-(void)updateSoldiers {
    skip = !skip;
    if (skip)
        return;
    for (Fort *f in fortArray) {
        [self updateSoldiersForFort:f];
    }
}

-(void)updateSoldiersForFort:(Fort *)f {
    
    for (Soldier *sD in f.soldierArray) {
        
//        [sD showCurrState];
        if (sD.countdown > 0) {
            sD.countdown -= 1;
        }
        else {
            sD.countdown = arc4random_uniform(600);
            if (sD.currState != gathering) {
                sD.currState = gathering;
            }
            else {
                sD.currState = passive;
            }
        }
        
        CGPoint destination;
        if (sD.currState == passive || sD.currState == fullInventory) {
            destination = f.position;
        }
        else {
            destination = [self nearestTreeToPos:sD.position];
        }
        
//        destination.x += arc4random_uniform(30)/10.-1.5;
//        destination.y += arc4random_uniform(30)/10.-1.5;
        

        CGPoint sP = sD.position;

        CGFloat angle = [self pointPairToBearingDegreesStart:sP end:destination];
        
        b2Vec2 vel = sD.b2Body->GetLinearVelocity();
        vel.x = sD.speed*cosf(angle);
        vel.y = sD.speed*sinf(angle);
        
        float newDist;
        newDist = ccpDistance(sD.position, destination);

        if (newDist < 32) {
            CGPoint sP = sD.position;
            CGPoint tP = destination;
            
            sP.x += (sP.x < tP.x ? -.1 : .1);
            sP.y += (sP.y < tP.y ? -.1 : .1);

            [sD setPosition:sP];
        }
        
//        if (sD.currState == passive) {
        
            sD.momX = sP.x > destination.x ? -.1 : +.1;
            sD.momY = sP.y > destination.y ? -.1 : +.1;
            
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
            
//        }
        
        sD.b2Body->SetLinearVelocity(vel);
        float bodyAngle = atan2f(vel.y, vel.x);
        sD.b2Body->SetTransform( sD.b2Body->GetWorldCenter(), bodyAngle);
        
        sD.momX = vel.x;
        sD.momY = vel.y;
        sD.oldDistToFort = newDist;
    }
}

-(void)updateTrees {
    for (Tree *t in treeArray) {
        if (t.wood < t.thresholdWood) {
            //This tree cannot be fixed - too much damage :(
            return;
        }
        if (t.growthCounter > 0) {
            t.growthCounter -=1;
        }
        else {
            [t resetGrowthCounter];
            if (t.wood < treeMaxWood) {
                t.wood = MIN(t.wood+3, treeMaxWood);
                t.scale = (float)t.wood/treeMaxWood;
                t.thresholdWood = t.wood *.6;
            }
            else {
                if (t.saplingGrowthCounter >0) {
                    t.saplingGrowthCounter -=1;
                }
                else {
                    [self createSaplingForTree:t];
                    t.saplingGrowthCounter = 100+arc4random_uniform(100);
                }
            }
        }
        
    }
}

-(void)updateFields {
    for (Field *f in fieldArray) {
        if (f.growthCountdown > 0) {
            f.growthCountdown -= 1;
        }
        else {
            [f resetGrowthCounter];
            if (f.tended == TRUE) {
                f.tended = false;
                f.fieldState += 1;
                f.fieldState = MIN(f.fieldState, 4);
            }
            else {
                f.tended = TRUE;
            }
            [f updateSprite];
        }
    }
}

-(void)createSaplingForTree:(Tree *)t {
    CGPoint fCOM = [self forestCenterOfMassForPoint:t.position];
    CGFloat newAngle = [self pointPairToBearingDegreesStart:fCOM end:t.position];
    newAngle += arc4random_uniform(162)/100.-.81;
//    CGFloat fDist = ccpDistance(fCOM, t.position);
    CGPoint newTreePoint = t.position;
    newTreePoint.x += 32*cos(newAngle);
    newTreePoint.y += 32*sin(newAngle);
    newTreePoint.x = MAX(0, MIN(newTreePoint.x, winSize.width) );
    newTreePoint.y = MAX(0, MIN(newTreePoint.y, winSize.height) );
    [saplingArray addObject:[NSValue valueWithCGPoint:newTreePoint]];
    
}

#pragma mark - HELPERS

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

-(CGPoint)forestCenterOfMassForPoint:(CGPoint)p {
    CGFloat pointsRecorded = 0.0;
    CGPoint cOM = ccp(0,0);
    for (Tree *t in treeArray) {
        CGPoint tP = t.position;
//        if (ccpDistance(p, tP) > 600) {
//            continue;
//        }
//        else {
            pointsRecorded +=1;
            cOM.x += tP.x;
            cOM.y += tP.y;
//        }
    }
    cOM.x /= pointsRecorded;
    cOM.y /= pointsRecorded;
    
    return cOM;
}

-(float) pointPairToBearingDegreesStart:(CGPoint)startingPoint end:(CGPoint)endingPoint
{
    CGPoint originPoint = CGPointMake(endingPoint.x - startingPoint.x, endingPoint.y - startingPoint.y); // get origin point to origin by subtracting end from start
    float bearingRadians = atan2f(originPoint.y, originPoint.x); // get bearing in radians
    float bearingDegrees = bearingRadians * (180.0 / M_PI); // convert to degrees
    bearingDegrees = (bearingDegrees > 0.0 ? bearingDegrees : (360.0 + bearingDegrees)); // correct discontinuity
    return bearingDegrees * M_PI/180;
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
