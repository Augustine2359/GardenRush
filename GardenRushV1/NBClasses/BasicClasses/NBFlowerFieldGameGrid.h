//
//  NBFlowerFieldGameGrid.h
//  GardenRushV1
//
//  Created by Romy Irawaty on 9/5/13.
//
//

#import <Foundation/Foundation.h>
#import "cocos2d.h"
#import "NBFlower.h"

#define FIELD_HORIZONTAL_UNIT_COUNT 9
#define FIELD_VERTICAL_UNIT_COUNT 9
#define FIELD_Y_POSITION 30
#define DURATION_TO_CHECK_EMPTY_SLOT 0.75f

@interface NBFlowerFieldGameGrid : CCNode

-(void)update:(ccTime)delta;

@property (nonatomic, retain) CCSprite* fieldBackground;
@property (nonatomic, retain) NSMutableArray* flowerArrays;
@property (nonatomic, assign) CGPoint selectedFlowerGrid;
@property (nonatomic, assign) CGPoint swappedFlowerGrid;
@property (nonatomic, retain) NSMutableArray* arrayOfMatchedFlower;
@property (nonatomic, retain) NSMutableArray* arrayOfMatchedFlowerSlot1;
@property (nonatomic, retain) NSMutableArray* arrayOfMatchedFlowerSlot2;
@property (nonatomic, retain) NSMutableArray* arrayOfMatchedFlowerSlots;
@property (nonatomic, retain) NSMutableArray* potentialComboGrids;
@property (nonatomic, assign) NBFlowerMatchType currentMatchType;

@end
