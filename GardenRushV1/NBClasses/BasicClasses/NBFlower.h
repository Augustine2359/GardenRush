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
    ftNoFlower = 0,
	ftRedFlower,
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

@interface NBFlower : CCNode <CCTargetedTouchDelegate>
{
    SEL callSelectorAfterMove;
}

+(id)createNewFlower:(NBFlowerType)flowertype onGridPosition:(CGPoint)gridPosition;
+(id)createRandomFlowerOnGridPosition:(CGPoint)gridPosition;
+(id)bloomRandomFlowerOnGridPosition:(CGPoint)gridPosition;
+(void)assignFieldLayer:(CCNode*)layer;
+(void)assignStartingPosition:(CGPoint)position;
+(void)assignFlowerField:(NSMutableArray*)fieldFlowerArray;
+(int)getFlowerCount;
+(CGPoint)convertFieldGridPositionToActualPixel:(CGPoint)gridPosition;
+(NBFlower*)randomFlower;
-(void)move:(NBFlowerMoveType)moveType informLayerSelector:(SEL)selector;
-(void)moveToGrid:(CGPoint)destinationGrid withDuration:(float)duration informSelector:(SEL)selector;
-(void)fallByOneGrid:(SEL)selector;

@property (nonatomic, retain) CCSprite* flowerImage;
@property (nonatomic, assign) NBFlowerType flowerType;
@property (nonatomic, assign) CGPoint gridPosition;
@property (nonatomic, assign) bool isMarkedMatched;
@property (nonatomic, assign) bool isMoveCompleted;
@property (nonatomic, assign) NBFlowerMatchType matchType;

@end
