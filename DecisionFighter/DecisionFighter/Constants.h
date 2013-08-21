//
//  Constants.h
//  DecisionFighter
//
//  Created by Nicholas Esposito on 8/19/13.
//  Copyright (c) 2013 NickTitle. All rights reserved.
//

#ifndef DecisionFighter_Constants_h
#define DecisionFighter_Constants_h

#define teamA 0
#define teamB 1

//Pixel to metres ratio. Box2D uses metres as the unit for measurement.
//This ratio defines how many pixels correspond to 1 Box2D "metre"
//Box2D is optimized for objects of 1x1 metre therefore it makes sense
//to define the ratio so that your most common object type is 1x1 metre.
#define PTM_RATIO 32

#define treeZIndex 100
#define baseZIndex 99
#define soldierZIndex 98

#define treeMaxWood 100

#endif
