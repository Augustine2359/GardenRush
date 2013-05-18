//
//  NBFlower.m
//  GardenRushV1
//
//  Created by Romy Irawaty on 9/5/13.
//
//

#import "NBFlower.h"

static CCNode* flowerFieldLayer = nil;
static CGPoint startingPosition = {0, 0};

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

+(void)assignStartingPosition:(CGPoint)position
{
    startingPosition = position;
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
        self.flowerImage.anchorPoint = ccp(0, 0);
        self.position = ccp((gridPosition.x * (FLOWERSIZE_WIDTH + 4)) + startingPosition.x, (gridPosition.y * (FLOWERSIZE_HEIGHT + 4)) + startingPosition.y);
        //self.flowerImage.position = ccp((gridPosition.x * (FLOWERSIZE_WIDTH + 4)) + startingPosition.x, (gridPosition.y * (FLOWERSIZE_HEIGHT + 4)) + startingPosition.y);
        self.flowerImage.scaleX = FLOWERSIZE_WIDTH / self.flowerImage.contentSize.width;
        self.flowerImage.scaleY = FLOWERSIZE_HEIGHT / self.flowerImage.contentSize.height;
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
    CGFloat moveDistance = FLOWERSIZE_HEIGHT + FIELD_FLOWER_GAP_WIDTH;
    
    switch (moveType)
    {
        case fmtUp:
            moveBy = [CCMoveBy actionWithDuration:moveDuration position:ccp(0, moveDistance)];
            break;
        case fmtDown:
            moveBy = [CCMoveBy actionWithDuration:moveDuration position:ccp(0, -moveDistance)];
            break;
        case fmtLeft:
            moveBy = [CCMoveBy actionWithDuration:moveDuration position:ccp(-moveDistance, 0)];
            break;
        case fmtRight:
            moveBy = [CCMoveBy actionWithDuration:moveDuration position:ccp(moveDistance, 0)];
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

-(void)moveToGrid:(CGPoint)destinationGrid
{
    self.isMovingForMatchingRemovalCompleted = false;
    
    CGPoint destination = CGPointMake(destinationGrid.x * (FLOWERSIZE_WIDTH + FIELD_FLOWER_GAP_WIDTH), destinationGrid.y * (FLOWERSIZE_HEIGHT + FIELD_FLOWER_GAP_WIDTH));
    destination = ccpAdd(destination, CGPointMake(FIELD_FLOWER_GAP_WIDTH, FIELD_FLOWER_GAP_WIDTH));
    
    CCMoveTo* moveTo = [CCMoveTo actionWithDuration:0.5f position:destination];
    CCCallFunc* moveCompleted = [CCCallFunc actionWithTarget:self selector:@selector(onMoveForRemovalCompleted)];
    CCSequence* sequence = [CCSequence actions:moveTo, moveCompleted, nil];
    [self runAction:sequence];
}

-(void)onMoveForRemovalCompleted
{
    self.isMovingForMatchingRemovalCompleted = true;
}

@end
