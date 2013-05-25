//
//  NBFlower.m
//  GardenRushV1
//
//  Created by Romy Irawaty on 9/5/13.
//
//

#import "NBFlower.h"

static int flowerCount = 0;
static CCNode* flowerFieldLayer = nil;
static CGPoint startingPosition = {0, 0};
static NSMutableArray* flowerField = nil;

@implementation NBFlower

+(id)bloomRandomFlowerOnGridPosition:(CGPoint)gridPosition
{
    NBFlowerType randomFlowerType = (NBFlowerType)(arc4random() % (ftMaxFlower - 1)) + 1;
    NBFlower* flower = [[NBFlower alloc] initWithFlowerType:randomFlowerType onGridPosition:gridPosition];
    flower.flowerImage.scale = 0;
    CCScaleTo* scaleTo = [CCScaleTo actionWithDuration:0.75f scaleX:FLOWERSIZE_WIDTH / flower.flowerImage.contentSize.width scaleY:FLOWERSIZE_HEIGHT / flower.flowerImage.contentSize.height];
    [flower.flowerImage runAction:scaleTo];
    
    return flower;
}

+(id)createNewFlower:(NBFlowerType)flowertype onGridPosition:(CGPoint)gridPosition
{
    NBFlower* flower = [[NBFlower alloc] initWithFlowerType:flowertype onGridPosition:gridPosition];
    
    return flower;
}

+(id)createRandomFlowerOnGridPosition:(CGPoint)gridPosition
{
    NBFlowerType randomFlowerType = (NBFlowerType)(arc4random() % (ftMaxFlower - 1)) + 1;
    
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

+(int)getFlowerCount
{
    return flowerCount;
}

+(void)assignFlowerField:(NSMutableArray*)fieldFlowerArray
{
    flowerField = fieldFlowerArray;
}

+(CGPoint)convertFieldGridPositionToActualPixel:(CGPoint)gridPosition
{
    return ccp((gridPosition.x * (FLOWERSIZE_WIDTH + FIELD_FLOWER_GAP_WIDTH) + (FLOWERSIZE_WIDTH / 2)) + startingPosition.x, (gridPosition.y * (FLOWERSIZE_HEIGHT + FIELD_FLOWER_GAP_WIDTH) + (FLOWERSIZE_HEIGHT / 2)) + startingPosition.y);
}

+(NBFlower*)randomFlower{
    int random = arc4random() % (int)ftMaxFlower;
    NBFlower* flower = [NBFlower createNewFlower:(NBFlowerType)random onGridPosition:ccp(0, 0)];
    return flower;
}

-(id)initWithFlowerType:(NBFlowerType)flowerType onGridPosition:(CGPoint)gridPosition
{
    if (!flowerFieldLayer)
    {
        DLog(@"No Field Flower defined...exiting");
        return nil;
    }
        
    if ((self = [super init]))
    {
        self.flowerImage = [CCSprite spriteWithSpriteFrameName:@"staticbox_white.png"];;
        
        switch (flowerType)
        {
            case ftNoFlower:
                //self.flowerImage.opacity = 0;
                self.flowerImage.color = ccWHITE;
                break;
                
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
        self.flowerImage.anchorPoint = ccp(0.5, 0.5);
        self.position = [NBFlower convertFieldGridPositionToActualPixel:gridPosition];
        //self.position = ccp((gridPosition.x * (FLOWERSIZE_WIDTH + 4) + (FLOWERSIZE_WIDTH / 2)) + startingPosition.x, (gridPosition.y * (FLOWERSIZE_HEIGHT + 4) + (FLOWERSIZE_HEIGHT / 2)) + startingPosition.y);
        //self.flowerImage.position = ccp((gridPosition.x * (FLOWERSIZE_WIDTH + 4)) + startingPosition.x, (gridPosition.y * (FLOWERSIZE_HEIGHT + 4)) + startingPosition.y);
        self.flowerImage.scaleX = FLOWERSIZE_WIDTH / self.flowerImage.contentSize.width;
        self.flowerImage.scaleY = FLOWERSIZE_HEIGHT / self.flowerImage.contentSize.height;
        [self setContentSize:CGSizeMake(FLOWERSIZE_WIDTH, FLOWERSIZE_HEIGHT)];
        [self addChild:self.flowerImage];
        [flowerFieldLayer addChild:self];
        
        flowerCount++;
        
        //[[[CCDirector sharedDirector] touchDispatcher] addTargetedDelegate:self priority:0 swallowsTouches:YES];
    }
    
    return self;
}

-(void)dealloc
{
    [super dealloc];
    //[self removeAllChildrenWithCleanup:YES];
    //[self removeChild:self.flowerImage cleanup:YES];
    flowerCount--;
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

-(void)moveToGrid:(CGPoint)destinationGrid withDuration:(float)duration informSelector:(SEL)selector
{
    self.isMoveCompleted = false;
    
    callSelectorAfterMove = selector;
    
    CGPoint destination = [NBFlower convertFieldGridPositionToActualPixel:destinationGrid];
    //CGPoint destination = ccp((destinationGrid.x * (FLOWERSIZE_WIDTH + FIELD_FLOWER_GAP_WIDTH) + (FLOWERSIZE_WIDTH / 2)) + startingPosition.x, (destinationGrid.y * (FLOWERSIZE_HEIGHT + FIELD_FLOWER_GAP_WIDTH) + (FLOWERSIZE_HEIGHT / 2)) + startingPosition.y);
    
    CCMoveTo* moveTo = [CCMoveTo actionWithDuration:duration position:destination];
    CCCallFunc* moveCompleted = [CCCallFunc actionWithTarget:self selector:@selector(onMoveCompleted)];
    CCSequence* sequence = [CCSequence actions:moveTo, moveCompleted, nil];
    [self runAction:sequence];
}

-(void)onMoveCompleted
{
    self.isMoveCompleted = true;
    
    if (callSelectorAfterMove)
    {
        [flowerFieldLayer performSelector:callSelectorAfterMove withObject:self];
    }
}

-(BOOL)ccTouchBegan:(UITouch *)touch withEvent:(UIEvent *)event
{
    CGPoint touchLocation = [touch locationInView:[CCDirector sharedDirector].view];
    touchLocation.y = [[CCDirector sharedDirector] winSize].height - touchLocation.y;
    touchLocation = ccp(touchLocation.x - 10, touchLocation.y - 10);
    int x = touchLocation.x / (FLOWERSIZE_WIDTH + FIELD_FLOWER_GAP_WIDTH);
    int y = touchLocation.y / (FLOWERSIZE_HEIGHT + FIELD_FLOWER_GAP_WIDTH);
    
    DLog(@"flower at position %i, %i type is %i", x, y, self.flowerType);
    
    return YES;
}

-(void)fallByOneGrid:(SEL)selector
{
    [self moveToGrid:CGPointMake(self.gridPosition.x, self.gridPosition.y - 1) withDuration:0.3f informSelector:selector];
}

@end
