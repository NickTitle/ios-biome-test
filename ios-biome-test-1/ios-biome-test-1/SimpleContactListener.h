#import <Foundation/Foundation.h>
#import "cocos2d.h"
#import "Box2D.h"
#import "HelloWorldLayer.h"

class SimpleContactListener : public b2ContactListener {
public:
    HelloWorldLayer *_layer;
    
    SimpleContactListener(HelloWorldLayer *layer) : _layer(layer) {
    }
    
    void BeginContact(b2Contact* contact) {
        [_layer beginContact:contact];
    }
    
    void EndContact(b2Contact* contact) {
        [_layer endContact:contact];
    }
    
    void PreSolve(b2Contact* contact, const b2Manifold* oldManifold) {
    }
    
    void PostSolve(b2Contact* contact, const b2ContactImpulse* impulse) {
    }
    
};