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
