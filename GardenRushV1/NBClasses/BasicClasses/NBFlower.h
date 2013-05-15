//
//  NBFlower.h
//  GardenRushV1
//
//  Created by Romy Irawaty on 9/5/13.
//
//

#import <Foundation/Foundation.h>
#import "cocos2d.h"

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
-(void)move:(NBFlowerMoveType)moveType informLayerSelector:(SEL)selector;

@property (nonatomic, retain) CCSprite* flowerImage;
@property (nonatomic, assign) NBFlowerType flowerType;
@property (nonatomic, assign) CGPoint gridPosition;

@end
