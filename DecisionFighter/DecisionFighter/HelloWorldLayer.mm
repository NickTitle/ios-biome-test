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

// Needed to obtain the Navigation Controller
#import "AppDelegate.h"

NSMutableArray *gGArray;
NSMutableArray *killList;
SimpleContactListener *_contactListener;

int oldangle = 0;
NSMutableArray *touchArray;
CGPoint loc1 = ccp(200,300);
CGPoint loc2 = ccp (300, 100);

enum {
	kTagParentNode = 1,
};


#pragma mark - HelloWorldLayer

@interface HelloWorldLayer()
-(void) initPhysics;
-(CCPhysicsSprite *) addNewSpriteAtPosition:(CGPoint)p;
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
        touchArray = [NSMutableArray new];
        killList = [NSMutableArray new];
        
		
		// init physics
		[self initPhysics];
		
		// create reset button
		//[self createMenu];
		
		//Set up sprite
        gGArray = [NSMutableArray new];

        [self schedule:@selector(nextFrame:)];
		[self scheduleUpdate];
	}
	return self;
}

-(void) registerWithTouchDispatcher {
    [[[CCDirector sharedDirector] touchDispatcher] addTargetedDelegate:self priority:0 swallowsTouches:TRUE];
}

-(BOOL) ccTouchBegan:(UITouch *)touch withEvent:(UIEvent *)event {
    if (![touchArray containsObject:touch] && [touchArray count]< 4) {
        [touchArray addObject:touch];
        [self makeSpritesForTouch:touch];
    }
    
    return YES;
}

-(void) ccTouchMoved:(UITouch *)touch withEvent:(UIEvent *)event {
}

-(void)ccTouchEnded:(UITouch *)touch withEvent:(UIEvent *)event
{
    if ([touchArray containsObject:touch])
        [touchArray removeObject:touch];
        [self killSpritesForTouch:touch];
}

-(void) makeSpritesForTouch:(UITouch *)touch {
    CGPoint loc = [self convertTouchToNodeSpace:touch];
    NSString *team;
    if (loc.x < [[CCDirector sharedDirector] winSize].width/2) {
        team = @"blue";
    }
    else {
        team = @"pink";
    }
    
    for (int i = 0; i < 50; i++) {
        
        CCPhysicsSprite *gG = [self addNewSpriteAtPosition:loc];
        CGFloat newSpeed = MAX(arc4random_uniform(14)+5, 8);
        NSMutableDictionary *spriteStruct = [@{@"sprite":gG, @"momentumX":@0.0, @"momentumY":@5.0, @"speed":[NSNumber numberWithFloat:newSpeed], @"touch":touch, @"team":team} mutableCopy];
        [gGArray addObject:spriteStruct];
        gG.b2Body->SetUserData(spriteStruct);
        [self addChild:gG];
    }
}

-(void) killSpritesForTouch:(UITouch *)touch {
    NSMutableArray *killIndex = [NSMutableArray new];
    for (NSDictionary *d in gGArray) {
        if ([d[@"touch"] isEqual:touch]) {
            [killIndex addObject:d];
        }
    }
    for (NSDictionary *d in killIndex) {
        [gGArray removeObject:d];
        CCPhysicsSprite *s = d[@"sprite"];
        world->DestroyBody(s.b2Body);
        [s removeFromParentAndCleanup:YES];
        d = nil;
    }
}

-(void) nextFrame:(ccTime)dt {
//            for (NSMutableDictionary *sD in gGArray) {
//                CCSprite *s = sD[@"sprite"];
//                CGPoint sP = s.position;
//                CGFloat momentumX = [sD[@"momentumX"] floatValue];
//                CGFloat momentumY = [sD[@"momentumY"] floatValue];
//                CGFloat newSpeed = [sD[@"speed"] floatValue];
//                CGFloat dx1 = loc1.x-sP.x;
//                CGFloat dy1 = loc1.y-sP.y;
//                
//                CGFloat angle = atan2f(dy1, dx1);
//                
//                momentumX += cos(angle)/2;
//                momentumY += sin(angle)/2;
//                
//                CGFloat totalMomentum = momentumX+momentumY;
//                if (totalMomentum > newSpeed) {
//                    CGFloat scale = newSpeed/totalMomentum;
//                    momentumX *= scale;
//                    momentumY *= scale;
//                }
//                
//                CGFloat newx = sP.x + momentumX;
//                CGFloat newy = sP.y + momentumY;
//                
//                [s setPosition:ccp(newx, newy)];
//                s.rotation = angle;
//                [sD setObject:[NSNumber numberWithFloat:momentumX] forKey:@"momentumX"];
//                [sD setObject:[NSNumber numberWithFloat:momentumY] forKey:@"momentumY"];
//                
//            }
}

-(void) updateLocation:(ccTime)dt {
    
}

-(void) createMenu
{
	// Default font size will be 22 points.
	[CCMenuItemFont setFontSize:22];
	
	// Reset Button
	CCMenuItemLabel *reset = [CCMenuItemFont itemWithString:@"Reset" block:^(id sender){
		[[CCDirector sharedDirector] replaceScene: [HelloWorldLayer scene]];
	}];

	// to avoid a retain-cycle with the menuitem and blocks
	__block id copy_self = self;

	// Achievement Menu Item using blocks
	CCMenuItem *itemAchievement = [CCMenuItemFont itemWithString:@"Achievements" block:^(id sender) {
		
		
		GKAchievementViewController *achivementViewController = [[GKAchievementViewController alloc] init];
		achivementViewController.achievementDelegate = copy_self;
		
		AppController *app = (AppController*) [[UIApplication sharedApplication] delegate];
		
		[[app navController] presentModalViewController:achivementViewController animated:YES];
		
		[achivementViewController release];
	}];
	
	// Leaderboard Menu Item using blocks
	CCMenuItem *itemLeaderboard = [CCMenuItemFont itemWithString:@"Leaderboard" block:^(id sender) {
		
		
		GKLeaderboardViewController *leaderboardViewController = [[GKLeaderboardViewController alloc] init];
		leaderboardViewController.leaderboardDelegate = copy_self;
		
		AppController *app = (AppController*) [[UIApplication sharedApplication] delegate];
		
		[[app navController] presentModalViewController:leaderboardViewController animated:YES];
		
		[leaderboardViewController release];
	}];
	
	CCMenu *menu = [CCMenu menuWithItems:itemAchievement, itemLeaderboard, reset, nil];
	
	[menu alignItemsVertically];
	
	CGSize size = [[CCDirector sharedDirector] winSize];
	[menu setPosition:ccp( size.width/2, size.height/2)];
	
	
	[self addChild: menu z:-1];	
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
	
//	groundBox.Set(b2Vec2(0,0), b2Vec2(s.width/PTM_RATIO,0));
//	groundBody->CreateFixture(&groundBox,0);
	
	// top
//	groundBox.Set(b2Vec2(0,s.height/PTM_RATIO), b2Vec2(s.width/PTM_RATIO,s.height/PTM_RATIO));
//	groundBody->CreateFixture(&groundBox,0);
	
	// left
//	groundBox.Set(b2Vec2(0,s.height/PTM_RATIO), b2Vec2(0,0));
//	groundBody->CreateFixture(&groundBox,0);
	
	// right
//	groundBox.Set(b2Vec2(s.width/PTM_RATIO,s.height/PTM_RATIO), b2Vec2(s.width/PTM_RATIO,0));
//	groundBody->CreateFixture(&groundBox,0);
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

-(CCPhysicsSprite *)addNewSpriteAtPosition:(CGPoint)p
{

	b2BodyDef bodyDef;
	bodyDef.type = b2_dynamicBody;
	bodyDef.position.Set(p.x/PTM_RATIO, p.y/PTM_RATIO);
	b2Body *body = world->CreateBody(&bodyDef);
	
    b2PolygonShape dynamicHex;
    b2Vec2 vertices[6];
    for (int i=0; i<6; i++) {
        float angle = -i/6.0 * 360 * M_PI/180;
        vertices[i].Set(sinf(angle)/3,cosf(angle)/3);
    }
    dynamicHex.Set(vertices, 6);

	b2FixtureDef fixtureDef;
	fixtureDef.shape = &dynamicHex;
	fixtureDef.density = .7f;
	fixtureDef.friction = 0.1f;
	body->CreateFixture(&fixtureDef);
    CCNode *parent = [self getChildByTag:kTagParentNode];
    
    CCPhysicsSprite *sprite;
    
    if (p.x > [[CCDirector sharedDirector] winSize].width/2) {
        sprite = [CCPhysicsSprite spriteWithFile:@"pink.png" rect:CGRectMake(0, 0, 32, 32)];
        body->SetUserData(@"pink");
    }
    else {
        sprite = [CCPhysicsSprite spriteWithFile:@"blu.png" rect:CGRectMake(0, 0, 32, 32)];
        [sprite setUserData:@"blu.png"];
        body->SetUserData(@"blue");
    }
    
	[parent addChild:sprite];
	
	[sprite setPTMRatio:PTM_RATIO];
	[sprite setB2Body:body];
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
    
    [self updateMomentums];
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
    NSDictionary *dA = (NSDictionary *) bodyA->GetUserData();
    NSDictionary *dB = (NSDictionary *) bodyB->GetUserData();
    if (dA == nil || dB == nil) {
        return;
    }
    NSString *teamA = dA[@"team"];
    NSString *teamB = dB[@"team"];
    
    if ([teamA isEqualToString:teamB]) {
        return;
    }
    else {
        
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
        
        NSDictionary *killOb;
        if (abs(aA-aAB)<abs(aB-aBA)) {
            killOb = dB;
        }
        else {
            killOb = dA;
        }
        
        if (![killList containsObject:killOb]) {
            [killList addObject:killOb];
        }
    }
}

-(void)endContact:(b2Contact *)contact {
    
}

-(void)killCollidedSprites {
    for (NSDictionary *d in killList) {
    [gGArray removeObject:d];
    CCPhysicsSprite *s = d[@"sprite"];
    world->DestroyBody(s.b2Body);
    [s removeFromParentAndCleanup:YES];
    d = nil;
    }
    [killList removeAllObjects];
}

-(void)updateMomentums {
    for (NSMutableDictionary *sD in gGArray) {
        CCPhysicsSprite *s = sD[@"sprite"];
        CGPoint sP = s.position;
        CGFloat momentumX = [sD[@"momentumX"] floatValue];
        CGFloat momentumY = [sD[@"momentumY"] floatValue];
        CGFloat newSpeed = [sD[@"speed"] floatValue];
        UITouch *t = sD[@"touch"];
        CGPoint loc = [self convertTouchToNodeSpace:t];
        CGFloat dx1 = loc.x-sP.x;
        CGFloat dy1 = loc.y-sP.y;
        
        CGFloat angle = atan2f(dy1, dx1);
        
        momentumX += cos(angle);
        momentumY += sin(angle);

        b2Vec2 vel = s.b2Body->GetLinearVelocity();
        vel.x += momentumX*2;
        vel.y += momentumY*2;
        
        CGFloat totalMomentum = abs(vel.x)+abs(vel.y);
        if (totalMomentum > newSpeed) {
            CGFloat scale = newSpeed/totalMomentum;
            vel.x *= scale;
            vel.y *= scale;
        }
    
        s.b2Body->SetLinearVelocity(vel);
        float bodyAngle = atan2f(vel.y, vel.x);
        s.b2Body->SetTransform( s.b2Body->GetWorldCenter(), bodyAngle);
        
        [sD setObject:[NSNumber numberWithFloat:vel.x] forKey:@"momentumX"];
        [sD setObject:[NSNumber numberWithFloat:vel.y] forKey:@"momentumY"];
        
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
