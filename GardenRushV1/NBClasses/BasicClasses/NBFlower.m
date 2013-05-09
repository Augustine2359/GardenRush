//
//  NBFlower.m
//  GardenRushV1
//
//  Created by Romy Irawaty on 9/5/13.
//
//

#import "NBFlower.h"

static CCLayer* flowerFieldLayer = nil;

@implementation NBFlower

+(id)createNewFlower:(FlowerType)flowertype onGridPosition:(CGPoint)gridPosition
{
    NBFlower* flower = [[NBFlower alloc] initWithFlowerType:flowertype onGridPosition:gridPosition];
    
    return nil;
}

+(id)createRandomFlowerOnGridPosition:(CGPoint)gridPosition
{
    return nil;
}

+(void)assignFieldLayer:(CCLayer*)layer
{
    flowerFieldLayer = layer;
}

-(id)initWithFlowerType:(FlowerType)flowerType onGridPosition:(CGPoint)gridPosition
{
    if (!flowerFieldLayer)
    {
        DLog(@"No Field Flower defined...exiting");
        return nil;
    }
        
    if (self = [super init])
    {
        self.flowerImage = [CCSprite spriteWithSpriteFrameName:@"staticbox_white.png"];;
        
        switch (flowerType)
        {
            case ftRedFlower:
                self.flowerImage.color = ccRED;
                break;
            
            case ftYellowFlower:
                self.flowerImage.color = ccYELLOW;
                break;
                
            default:
                break;
        }
        
        self.flowerImage.visible = NO;
        self.flowerType = flowerType;
        self.gridPosition = gridPosition;
        self.flowerImage.position = ccp(gridPosition.x * 30, gridPosition.y * 30);
        [flowerFieldLayer addChild:self.flowerImage];
    }
    
    return self;
}

@end
