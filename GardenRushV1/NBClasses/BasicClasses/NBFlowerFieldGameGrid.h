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

#define FIELD_HORIZONTAL_UNIT_COUNT 10
#define FIELD_VERTICAL_UNIT_COUNT 10

typedef enum
{
    mtNoMatch = 0,
    mtThreeOfAKind,
    mtFourOfAKind,
    mtFiveOfAKind,
    mtCornerFiveOfAKind,
    mtSixOfAKind,
    mtSevenOfAKind
} NBFlowerMatchType;

@interface NBFlowerFieldGameGrid : CCNode

@property (nonatomic, retain) CCSprite* fieldBackground;
@property (nonatomic, retain) NSMutableArray* flowerArrays;
@property (nonatomic, assign) CGPoint selectedFlowerGrid;
@property (nonatomic, assign) CGPoint swappedFlowerGrid;

@end
