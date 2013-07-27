//
//  NBFlower.h
//  GardenRushV1
//
//  Created by Romy Irawaty on 9/5/13.
//
//

#import <Foundation/Foundation.h>
#import "cocos2d.h"
#import "NBBouquet.h"

/*Parameter*/
#define FLOWERSIZE_WIDTH 30
#define FLOWERSIZE_HEIGHT 30
#define FIELD_FLOWER_GAP_WIDTH 4
#define FLOWER_MOVE_DURATION 0.2f
#define MAX_DIFFICULTY_LEVEL 10

#define TAG_ID_BLINK 1

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

typedef enum
{
    ftNoFlower = 0,
    ftVirtualFlower,
	ftRedFlower,
    ftYellowFlower,
    ftGreenFlower,
    ftBlueFlower,
    ftBlackFlower,
    ftWhiteFlower,
    ftPurpleFlower,
    ftCyanFlower,
    ftBisqueFlower,
    ftAquamarineFlower,
    ftMaxFlower,
    ftSpecialWildFlower
} NBFlowerType;

typedef enum
{
    fstNormalFlower = 0,
    fstSpecialFlower
} NBFlowerSubType;

typedef enum
{
	fmtUp = 0,
    fmtDown,
    fmtLeft,
    fmtRight,
    fmtMaxMoveType
} NBFlowerMoveType;

@interface NBFlower : CCNode <CCTargetedTouchDelegate>
{
    SEL callSelectorAfterMove;
}

+(id)createNewFlower:(NBFlowerType)flowertype onGridPosition:(CGPoint)gridPosition show:(bool)show;
+(id)createRandomFlowerOnGridPosition:(CGPoint)gridPosition show:(bool)show;
+(id)createVirtualFlower;
+(id)bloomRandomFlowerOnGridPosition:(CGPoint)gridPosition;
+(id)bloomFlower:(NBFlowerType)flowerType OnGridPosition:(CGPoint)gridPosition;
+(void)assignFieldLayer:(CCNode*)layer;
+(void)assignStartingPosition:(CGPoint)position;
+(void)assignFieldContentSize:(CGSize)contentSize;
+(void)assignFlowerField:(NSMutableArray*)fieldFlowerArray;
+(void)assignDifficultyLevel:(int)level;
+(int)getFlowerCount;
+(CGPoint)convertFieldGridPositionToActualPixel:(CGPoint)gridPosition;
+(NBFlower*)randomFlower;
-(void)move:(NBFlowerMoveType)moveType informLayerSelector:(SEL)selector;
-(void)changeToGrid:(CGPoint)destinationGrid;
-(void)moveToGrid:(CGPoint)destinationGrid withDuration:(float)duration informSelector:(SEL)selector;
-(void)fallByOneGrid:(SEL)selector;
-(void)show;
-(void)toggleBlink:(bool)enable;
-(void)debloomToHide;
-(void)bloomToShow;

@property (nonatomic, retain) CCSprite* flowerImage;
@property (nonatomic, assign) NBFlowerType flowerType;
@property (nonatomic, assign) NBFlowerSubType flowerSubType;
@property (nonatomic, assign) CGPoint gridPosition;
@property (nonatomic, assign) bool isMarkedMatched;
@property (nonatomic, assign) bool isMoveCompleted;
@property (nonatomic, assign) NBFlowerMatchType matchType;
@property (nonatomic, assign) NBBouquetType bouquetType;
@property (nonatomic, assign) BOOL isMovableDuringRearrangingShop;
@property (nonatomic, assign) BOOL isSpecialFlower;

@end
