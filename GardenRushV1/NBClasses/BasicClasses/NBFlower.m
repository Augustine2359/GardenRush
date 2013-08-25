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
static CGSize fieldContentSize = {0, 0};
static int difficultyLevel = 1;

@interface NBFlower()
{
    bool isBloomed;
}

@end

@implementation NBFlower

+(id)bloomRandomFlowerOnGridPosition:(CGPoint)gridPosition
{
    NBFlowerType randomFlowerType = (NBFlowerType)(arc4random_uniform(ftMaxFlower - ftRedFlower - (MAX_DIFFICULTY_LEVEL - difficultyLevel)) + ftRedFlower);
    //NBFlowerType randomFlowerType = (NBFlowerType)(arc4random() % (ftMaxFlower - 1)) + ftRedFlower;
    NBFlower* flower = [[NBFlower alloc] initWithFlowerType:randomFlowerType onGridPosition:gridPosition show:true];
    flower.flowerImage.scale = 0;
    CCScaleTo* scaleTo = [CCScaleTo actionWithDuration:0.75f scaleX:FLOWERSIZE_WIDTH / flower.flowerImage.contentSize.width scaleY:FLOWERSIZE_HEIGHT / flower.flowerImage.contentSize.height];
    [flower.flowerImage runAction:scaleTo];
    
    CCRotateBy* rotateBy = [CCRotateBy actionWithDuration:0.75f angle:360];
    [flower.flowerImage runAction:rotateBy];
    
    return flower;
}

+(id)bloomFlower:(NBFlowerType)flowerType OnGridPosition:(CGPoint)gridPosition
{
    NBFlower* flower = [[NBFlower alloc] initWithFlowerType:flowerType onGridPosition:gridPosition show:true];
    flower.flowerImage.scale = 0;
    CCScaleTo* scaleTo = [CCScaleTo actionWithDuration:0.75f scaleX:FLOWERSIZE_WIDTH / flower.flowerImage.contentSize.width scaleY:FLOWERSIZE_HEIGHT / flower.flowerImage.contentSize.height];
    [flower.flowerImage runAction:scaleTo];
    
    CCRotateBy* rotateBy = [CCRotateBy actionWithDuration:0.75f angle:360];
    [flower.flowerImage runAction:rotateBy];
    
    return flower;
}

+(id)createNewFlower:(NBFlowerType)flowertype onGridPosition:(CGPoint)gridPosition show:(bool)show
{
    NBFlower* flower = [[NBFlower alloc] initWithFlowerType:flowertype onGridPosition:gridPosition show:show];
    
    return flower;
}

+(id)createRandomFlowerOnGridPosition:(CGPoint)gridPosition show:(bool)show
{
    NBFlowerType randomFlowerType = (NBFlowerType)(arc4random_uniform(ftMaxFlower - ftRedFlower - (MAX_DIFFICULTY_LEVEL - difficultyLevel)) + ftRedFlower);
    //NBFlowerType randomFlowerType = (NBFlowerType)(arc4random() % (ftMaxFlower - 1)) + ftRedFlower;
    
    NBFlower* flower = [[NBFlower alloc] initWithFlowerType:randomFlowerType onGridPosition:gridPosition show:show];
    
    return flower;
}

+(id)createVirtualFlower
{
    return [[NBFlower alloc] initWithFlowerType:ftVirtualFlower onGridPosition:CGPointZero show:false];
}

+(void)assignFieldLayer:(CCNode*)layer
{
    flowerFieldLayer = layer;
}

+(void)assignFieldContentSize:(CGSize)contentSize

{
    fieldContentSize = contentSize;
}

+(void)assignStartingPosition:(CGPoint)position
{
    startingPosition = position;
}

+(CGPoint)getStartingPosition
{
    return startingPosition;
}

+(void)assignDifficultyLevel:(int)level
{
    difficultyLevel = level;
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

+(NBFlower*)randomFlower
{
    int random = arc4random() % (int)ftMaxFlower;
    NBFlower* flower = [NBFlower createNewFlower:(NBFlowerType)random onGridPosition:ccp(0, 0) show:YES];
    return flower;
}

-(id)initWithFlowerType:(NBFlowerType)flowerType onGridPosition:(CGPoint)gridPosition show:(bool)show
{
    if (!flowerFieldLayer)
    {
        DLog(@"No Field Flower defined...exiting");
        return nil;
    }
    
    if ((self = [[super init] autorelease]))
    {
        if (flowerType == ftVirtualFlower)
        {
            self.flowerType = ftVirtualFlower;
        }
        else
        {
            self.flowerImage = [CCSprite spriteWithSpriteFrameName:@"flower_sketch_sakura.png"];;
            
            switch (flowerType)
            {
                case ftNoFlower:
                    //self.flowerImage.opacity = 0;
                    self.flowerImage.color = ccWHITE;
                    self.isMovableDuringRearrangingShop = false;
                    self.flowerSubType = fstNormalFlower;
                    break;
                    
                case ftRedFlower:
                    self.flowerImage = [CCSprite spriteWithSpriteFrameName:@"NB_Flower1_60x60.png"];
                    //self.flowerImage.color = ccRED;
                    self.isMovableDuringRearrangingShop = true;
                    self.flowerSubType = fstNormalFlower;
                    break;
                
                case ftYellowFlower:
                    self.flowerImage = [CCSprite spriteWithSpriteFrameName:@"NB_Flower2_60x60.png"];
                    //self.flowerImage.color = ccYELLOW;
                    self.isMovableDuringRearrangingShop = true;
                    self.flowerSubType = fstNormalFlower;
                    break;
                
                case ftGreenFlower:
                    self.flowerImage = [CCSprite spriteWithSpriteFrameName:@"NB_Flower3_60x60.png"];
                    //self.flowerImage.color = ccGREEN;
                    self.isMovableDuringRearrangingShop = true;
                    self.flowerSubType = fstNormalFlower;
                    break;
                    
                case ftBlueFlower:
                    self.flowerImage = [CCSprite spriteWithSpriteFrameName:@"NB_Flower4_60x60.png"];
                    //self.flowerImage.color = ccBLUE;
                    self.isMovableDuringRearrangingShop = true;
                    self.flowerSubType = fstNormalFlower;
                    break;
                
                case ftBlackFlower:
                    self.flowerImage = [CCSprite spriteWithSpriteFrameName:@"NB_Flower5_60x60.png"];
                    //self.flowerImage.color = ccBLACK;
                    self.isMovableDuringRearrangingShop = true;
                    self.flowerSubType = fstNormalFlower;
                    break;
                    
                case ftWhiteFlower:
                    self.flowerImage = [CCSprite spriteWithSpriteFrameName:@"NB_Flower7_60x60.png"];
                    //self.flowerImage.color = ccWHITE;
                    self.isMovableDuringRearrangingShop = true;
                    self.flowerSubType = fstNormalFlower;
                    break;
                
                case ftPurpleFlower:
                    self.flowerImage.color = ccc3(106, 90, 205);
                    self.isMovableDuringRearrangingShop = true;
                    self.flowerSubType = fstNormalFlower;
                    break;
                    
                case ftCyanFlower:
                    self.flowerImage.color = ccc3(0, 255, 255);
                    self.isMovableDuringRearrangingShop = true;
                    self.flowerSubType = fstNormalFlower;
                    break;
                
                case ftBisqueFlower:
                    self.flowerImage.color = ccc3(139, 125, 107);
                    self.isMovableDuringRearrangingShop = true;
                    self.flowerSubType = fstNormalFlower;
                    break;
                    
                case ftAquamarineFlower:
                    self.flowerImage.color = ccc3(127, 255, 212);
                    self.isMovableDuringRearrangingShop = true;
                    self.flowerSubType = fstNormalFlower;
                    break;
               
                case ftSpecialWildFlower:
                    self.flowerImage.color = ccRED;
                    self.isMovableDuringRearrangingShop = true;
                    self.flowerSubType = fstSpecialFlower;
                    break;
                    
                default:
                    self.isMovableDuringRearrangingShop = false;
                    break;
            }
            
            if (!show)
            {
                self.flowerImage.visible = NO;
                isBloomed = false;
            }
            else
                isBloomed = true;
            
            self.flowerType = flowerType;
            self.isSpecialFlower = NO;
            [self initializeOnGridPosition:gridPosition];
        }
    }
    
    return self;
}

-(void)initializeOnGridPosition:(CGPoint)gridPosition
{
    self.gridPosition = gridPosition;
    self.flowerImage.anchorPoint = ccp(0.5, 0.5);
    self.position = [NBFlower convertFieldGridPositionToActualPixel:gridPosition];
    self.flowerImage.scaleX = FLOWERSIZE_WIDTH / self.flowerImage.contentSize.width;
    self.flowerImage.scaleY = FLOWERSIZE_HEIGHT / self.flowerImage.contentSize.height;
    [self setContentSize:CGSizeMake(FLOWERSIZE_WIDTH, FLOWERSIZE_HEIGHT)];
    [self addChild:self.flowerImage];
    [flowerFieldLayer addChild:self];
    
    flowerCount++;
    
    [[[CCDirector sharedDirector] touchDispatcher] addTargetedDelegate:self priority:0 swallowsTouches:YES];
}

-(void)dealloc
{
    [[[CCDirector sharedDirector] touchDispatcher] removeDelegate:self];
    [super dealloc];
    //[self removeAllChildrenWithCleanup:YES];
    //[self removeChild:self.flowerImage cleanup:YES];
    flowerCount--;
}


-(void)move:(NBFlowerMoveType)moveType informLayerSelector:(SEL)selector
{
    CCMoveBy* moveBy = nil;
    float moveDuration = FLOWER_MOVE_DURATION;
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
    CCMoveTo* moveTo = [CCMoveTo actionWithDuration:duration position:destination];
    CCCallFunc* moveCompleted = [CCCallFunc actionWithTarget:self selector:@selector(onMoveCompleted)];
    CCSequence* sequence = [CCSequence actions:moveTo, moveCompleted, nil];
    [self runAction:sequence];
}

-(void)changeToGrid:(CGPoint)destinationGrid
{
    CGPoint destination = [NBFlower convertFieldGridPositionToActualPixel:destinationGrid];
    self.position = destination;
    self.gridPosition = destinationGrid;
}

-(void)onMoveCompleted
{
    self.isMoveCompleted = true;
    //self.gridPosition = ccp(self.position.x / (FLOWERSIZE_WIDTH + FIELD_FLOWER_GAP_WIDTH), self.position.y / (FLOWERSIZE_HEIGHT + FIELD_FLOWER_GAP_WIDTH));
    
    if (callSelectorAfterMove)
    {
        [flowerFieldLayer performSelector:callSelectorAfterMove withObject:self];
    }
}

-(BOOL)ccTouchBegan:(UITouch *)touch withEvent:(UIEvent *)event
{
    CGSize winSize = [[CCDirector sharedDirector] winSize];
    CGPoint touchLocation = [touch locationInView:[CCDirector sharedDirector].view];
    touchLocation.y = [[CCDirector sharedDirector] winSize].height - touchLocation.y;
    touchLocation = ccp(touchLocation.x - (winSize.width / 2 - (fieldContentSize.width / 2)), touchLocation.y - 4);
    int x = touchLocation.x / (FLOWERSIZE_WIDTH + FIELD_FLOWER_GAP_WIDTH);
    int y = touchLocation.y / (FLOWERSIZE_HEIGHT + FIELD_FLOWER_GAP_WIDTH);

    if (x >= [flowerField count] || y >= [[flowerField objectAtIndex:0] count]) return FALSE;
    
    NBFlower* touchedFlower = (NBFlower*)[[flowerField objectAtIndex:x] objectAtIndex:y];
    NSString* flowerTypeInString = nil;
    switch (touchedFlower.flowerType)
    {
        case ftNoFlower:
            flowerTypeInString = @"No Flower";
            break;
        
        case ftRedFlower:
            flowerTypeInString = @"Kenneth's Flower";
            break;
            
        case ftYellowFlower:
            flowerTypeInString = @"Andrew's Flower";
            break;
            
        case ftGreenFlower:
            flowerTypeInString = @"Adam's Flower";
            break;
            
        case ftBlueFlower:
            flowerTypeInString = @"Frances' Flower";
            break;
        
        case ftBlackFlower:
            flowerTypeInString = @"Black Flower";
            break;
            
        case ftWhiteFlower:
            flowerTypeInString = @"White Flower";
            break;
            
        case ftPurpleFlower:
            flowerTypeInString = @"Purple Flower";
            break;
            
        case ftCyanFlower:
            flowerTypeInString = @"Cyan Flower";
            break;
            
        case ftBisqueFlower:
            flowerTypeInString = @"Bisque Flower";
            break;
            
        case ftAquamarineFlower:
            flowerTypeInString = @"Aquamarine Flower";
            break;
            
        default:
            break;
    }
    
    DLog(@"flower at position %i, %i type is %@", x, y, flowerTypeInString);
    
    return YES;
}

-(void)fallByOneGrid:(SEL)selector
{
    [self moveToGrid:CGPointMake(self.gridPosition.x, self.gridPosition.y - 1) withDuration:0.3f informSelector:selector];
}

-(void)show
{
    self.flowerImage.opacity = 0;
    self.flowerImage.visible = YES;
    CCFadeIn* fadeIn = [CCFadeIn actionWithDuration:0.2f];
    [self.flowerImage runAction:fadeIn];
    isBloomed = true;
}

-(void)toggleBlink:(bool)enable
{
    if (enable)
    {
        CCBlink* blink = [CCBlink actionWithDuration:10.0f blinks:10];
        blink.tag = TAG_ID_BLINK;
        [self runAction:blink];
    }
    else
    {
        [self stopActionByTag:TAG_ID_BLINK];
        self.visible = true;
    }
}

-(void)debloomToHide
{
    if (!isBloomed) return;
    
    CCScaleTo* scaleTo = [CCScaleTo actionWithDuration:0.75f scale:0];
    [self.flowerImage runAction:scaleTo];
    
    CCRotateBy* rotateBy = [CCRotateBy actionWithDuration:0.75f angle:-360];
    [self.flowerImage runAction:rotateBy];
    
    isBloomed = false;
}

-(void)bloomToShow
{
    if (isBloomed) return;
    
    CCScaleTo* scaleTo = [CCScaleTo actionWithDuration:0.75f scaleX:FLOWERSIZE_WIDTH / self.flowerImage.contentSize.width scaleY:FLOWERSIZE_HEIGHT / self.flowerImage.contentSize.height];
    [self.flowerImage runAction:scaleTo];
    
    CCRotateBy* rotateBy = [CCRotateBy actionWithDuration:0.75f angle:360];
    [self.flowerImage runAction:rotateBy];
    
    isBloomed = true;
}

@end
