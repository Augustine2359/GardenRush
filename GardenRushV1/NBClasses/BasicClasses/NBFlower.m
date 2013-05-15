//
//  NBFlower.m
//  GardenRushV1
//
//  Created by Romy Irawaty on 9/5/13.
//
//

#import "NBFlower.h"

static CCNode* flowerFieldLayer = nil;

@implementation NBFlower

+(id)createNewFlower:(NBFlowerType)flowertype onGridPosition:(CGPoint)gridPosition
{
    NBFlower* flower = [[NBFlower alloc] initWithFlowerType:flowertype onGridPosition:gridPosition];
    
    return flower;
}

+(id)createRandomFlowerOnGridPosition:(CGPoint)gridPosition
{
    NBFlowerType randomFlowerType = (NBFlowerType)(arc4random() % ftMaxFlower);
    
    NBFlower* flower = [[NBFlower alloc] initWithFlowerType:randomFlowerType onGridPosition:gridPosition];
    
    return flower;
}

+(void)assignFieldLayer:(CCNode*)layer
{
    flowerFieldLayer = layer;
}

-(id)initWithFlowerType:(NBFlowerType)flowerType onGridPosition:(CGPoint)gridPosition
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
            
            case ftGreenFlower:
                self.flowerImage.color = ccGREEN;
                break;
                
            case ftBlueFlower:
                self.flowerImage.color = ccBLUE;
                break;
                
            default:
                break;
        }
        
        //self.flowerImage.visible = NO;
        self.flowerType = flowerType;
        self.gridPosition = gridPosition;
        self.flowerImage.anchorPoint = ccp(0.5f, 0.5f);
        self.flowerImage.position = ccp((gridPosition.x * 30) + 15, (gridPosition.y * 30) + 15);
        self.flowerImage.scaleX = 26 / self.flowerImage.contentSize.width;
        self.flowerImage.scaleY = 26 / self.flowerImage.contentSize.height;
        [self addChild:self.flowerImage];
        [flowerFieldLayer addChild:self];
        
        //[[[CCDirector sharedDirector] touchDispatcher] addTargetedDelegate:self priority:0 swallowsTouches:YES];
    }
    
    return self;
}

-(void)move:(NBFlowerMoveType)moveType informLayerSelector:(SEL)selector
{
    CCMoveBy* moveBy = nil;
    float moveDuration = 0.65f;
    
    switch (moveType)
    {
        case fmtUp:
            moveBy = [CCMoveBy actionWithDuration:moveDuration position:ccp(0, 30)];
            break;
        case fmtDown:
            moveBy = [CCMoveBy actionWithDuration:moveDuration position:ccp(0, -30)];
            break;
        case fmtLeft:
            moveBy = [CCMoveBy actionWithDuration:moveDuration position:ccp(-30, 0)];
            break;
        case fmtRight:
            moveBy = [CCMoveBy actionWithDuration:moveDuration position:ccp(30, 0)];
            break;
        default:
            break;
    }
    
    if (!selector)
    {
        [self runAction:moveBy];
    }
    else
    {
        CCCallFunc* moveCompleted = [CCCallFunc actionWithTarget:flowerFieldLayer selector:selector];
        CCSequence* sequence = [CCSequence actions:moveBy, moveCompleted, nil];
        [self runAction:sequence];
    }
}

@end
