//
//  NBFlower.h
//  GardenRushV1
//
//  Created by Romy Irawaty on 9/5/13.
//
//

#import <Foundation/Foundation.h>
#import "cocos2d.h"

#define FLOWERSIZE_WIDTH 30
#define FLOWERSIZE_HEIGHT 30
#define FIELD_FLOWER_GAP_WIDTH 4

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

typedef enum {
	ftRedFlower = 0,
    ftYellowFlower,
    ftGreenFlower,
    ftBlueFlower,
    ftMaxFlower
} NBFlowerType;

typedef enum {
	fmtUp = 0,
    fmtDown,
    fmtLeft,
    fmtRight
} NBFlowerMoveType;

@interface NBFlower : CCNode /*<CCTargetedTouchDelegate>*/

+(id)createNewFlower:(NBFlowerType)flowertype onGridPosition:(CGPoint)gridPosition;
+(id)createRandomFlowerOnGridPosition:(CGPoint)gridPosition;
+(void)assignFieldLayer:(CCNode*)layer;
+(void)assignStartingPosition:(CGPoint)position;
-(void)move:(NBFlowerMoveType)moveType informLayerSelector:(SEL)selector;
-(void)moveToGrid:(CGPoint)destinationGrid;

@property (nonatomic, retain) CCSprite* flowerImage;
@property (nonatomic, assign) NBFlowerType flowerType;
@property (nonatomic, assign) CGPoint gridPosition;
@property (nonatomic, assign) bool isMarkedMatched;
@property (nonatomic, assign) bool isMovingForMatchingRemovalCompleted;
@property (nonatomic, assign) NBFlowerMatchType matchType;

@end
