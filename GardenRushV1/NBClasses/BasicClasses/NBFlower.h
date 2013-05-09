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
} FlowerType;

@interface NBFlower : NSObject

+(id)createNewFlower:(FlowerType)flowertype onGridPosition:(CGPoint)gridPosition;
+(void)assignFieldLayer:(CCLayer*)layer;

@property (nonatomic, retain) CCSprite* flowerImage;
@property (nonatomic, assign) FlowerType flowerType;
@property (nonatomic, assign) CGPoint gridPosition;

@end
