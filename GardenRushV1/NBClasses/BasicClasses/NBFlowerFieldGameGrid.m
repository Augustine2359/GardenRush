//
//  NBFlowerFieldGameGrid.m
//  GardenRushV1
//
//  Created by Romy Irawaty on 9/5/13.
//
//

#import "NBFlowerFieldGameGrid.h"
#import "NBDataManager.h"

@interface NBFlowerFieldGameGrid()
{
    bool isReturningFlower; //use to detect whether after the move need to check match
    bool isRearranging;
    bool isCheckingCombo;
    bool needToCheckCombo;
    bool needtocheckPossibleMove;
    UISwipeGestureRecognizerDirection lastGestureDirection;
    ccTime timeRemainingBeforeComboCheck;
    ccTime timeRemainingBeforePossibleMoveCheck;
}

@property (nonatomic, strong) NSArray *gestureRecognizers;
@property (nonatomic) CGFloat horizontalTileCount;
@property (nonatomic) CGFloat verticalTileCount;

@end

@implementation NBFlowerFieldGameGrid

-(id)initWithExpandedFlowerField:(BOOL)isFlowerFieldExpanded
{
    CGSize winSize = [[CCDirector sharedDirector] winSize];
    
    if (self = [super init])
    {
        if (isFlowerFieldExpanded) {
            self.horizontalTileCount = FIELD_HORIZONTAL_UNIT_COUNT_EXPANDED;
            self.verticalTileCount = FIELD_VERTICAL_UNIT_COUNT_EXPANDED;
        }
        else {
            self.horizontalTileCount = FIELD_HORIZONTAL_UNIT_COUNT;
            self.verticalTileCount = FIELD_VERTICAL_UNIT_COUNT;
        }
      
        //CGSize fieldSize = CGSizeMake(10, 10);
        
        [self setContentSize:CGSizeMake((((FLOWERSIZE_WIDTH + FIELD_FLOWER_GAP_WIDTH) * self.horizontalTileCount) + FIELD_FLOWER_GAP_WIDTH), (((FLOWERSIZE_HEIGHT + FIELD_FLOWER_GAP_WIDTH) * self.verticalTileCount) + FIELD_FLOWER_GAP_WIDTH))];
        self.anchorPoint = ccp(0, 0);
        self.position = ccp(winSize.width / 2 - (self.contentSize.width / 2), FIELD_Y_POSITION);
        DLog(@"%f", winSize.width / 2 - (self.contentSize.width / 2));
        
        self.fieldBackground = [CCSprite spriteWithSpriteFrameName:@"staticbox_white.png"];
        self.fieldBackground.scaleX = self.contentSize.width / self.fieldBackground.contentSize.width;
        self.fieldBackground.scaleY = self.contentSize.height / self.fieldBackground.contentSize.height;
        self.fieldBackground.anchorPoint = ccp(0, 0);
        self.fieldBackground.position = ccp(0, 0);
        self.fieldBackground.color = ccc3(139, 119, 101);
        [self addChild:self.fieldBackground];
        
        self.flowerArrays = [NSMutableArray array];
        self.arrayOfMatchedFlower = [NSMutableArray array];
        self.arrayOfMatchedFlowerSlot1 = [NSMutableArray array];
        self.arrayOfMatchedFlowerSlot2 = [NSMutableArray array];
        self.arrayOfMatchedFlowerSlots = [NSMutableArray array];
        self.potentialComboGrids = [NSMutableArray array];
        self.potentialNextMoveHasMatchGrids = [NSMutableArray array];
        
        for (int i = 0; i < self.horizontalTileCount; i++)
        {
            NSMutableArray* verticalFlowerArray = [NSMutableArray array];
            
            [self.flowerArrays addObject:verticalFlowerArray];
        }
        
        [NBFlower assignFieldLayer:self];
        [NBFlower assignStartingPosition:CGPointMake(FIELD_FLOWER_GAP_WIDTH, FIELD_FLOWER_GAP_WIDTH)];
        [NBFlower assignFlowerField:self.flowerArrays];
        [NBFlower assignFieldContentSize:self.contentSize];
        [NBFlower assignDifficultyLevel:[NBDataManager getDifficultyValueOnKey:@"flowerTypeLevel"]];
        
        [self generateLevel];
        [self showAllFlower];
        [self unlockField];
        needToCheckCombo = false;
        needtocheckPossibleMove = false;
        
        [self addSwipeGestureRecognizers];
        [self scheduleUpdate];
        
        timeRemainingBeforeComboCheck = DURATION_TO_CHECK_EMPTY_SLOT;
        timeRemainingBeforePossibleMoveCheck = DURATION_TO_CHECK_EMPTY_SLOT;
    }
    
    return self;
}

-(void)fillFlower
{
    for (int i = 0; i < self.horizontalTileCount; i++)
    {
        for (int j = 0; j < self.verticalTileCount; j++)
        {
            if ([[self.flowerArrays objectAtIndex:i] count] < 10)
            {
                NBFlower* flower = [NBFlower createRandomFlowerOnGridPosition:CGPointMake(i, j) show:true];
                [[self.flowerArrays objectAtIndex:i] addObject:flower];
            }
            else
            {
                NBFlower* flower = [NBFlower createRandomFlowerOnGridPosition:CGPointMake(i, j) show:true];
                [flower show];
                [[self.flowerArrays objectAtIndex:i] setObject:flower atIndex:j];
            }
        }
    }
}

-(void)generateLevel
{
    for (int x = 0; x < self.horizontalTileCount; x++)
    {
        for (int y = 0; y < self.verticalTileCount; y++)
        {
            NBFlower* newFlower = [NBFlower createRandomFlowerOnGridPosition:ccp(x, y) show:false];
            [[self.flowerArrays objectAtIndex:x] addObject:newFlower];
            if ([self checkMatchOnGrid:ccp(x, y)])
            {
                [[self.flowerArrays objectAtIndex:x] removeLastObject];
                [self removeChild:newFlower cleanup:YES];
                [newFlower release];
                y--;
            }
        }
    }
}

-(void)showAllFlower
{
    for (int x = 0; x < self.horizontalTileCount; x++)
    {
        for (int y = 0; y < self.verticalTileCount; y++)
        {
            NBFlower* flower = (NBFlower*)[[self.flowerArrays objectAtIndex:x] objectAtIndex:y];
            [flower show];
        }
    }
}

-(bool)checkMatchOnGrid:(CGPoint)gridPosition
{
    int matchCount = 1; //include the flower itself
    int matchCountHorizontal = 1;
    int matchCountVertical = 1;
    bool matchDetectedOnHorizontal = false;
    bool matchDetectedOnVertical = false;
    
    NBFlower* localFlower = (NBFlower*)[[self.flowerArrays objectAtIndex:gridPosition.x] objectAtIndex:gridPosition.y];
    
    //check to the right
    for (int i = 1; i < 5; i++)
    {
        int gridX = gridPosition.x + i;
        if (gridX >= self.horizontalTileCount) break;
        if (gridX >= [[self.flowerArrays objectAtIndex:gridX] count]) break;
        
        NBFlower* nextFlower = (NBFlower*)[[self.flowerArrays objectAtIndex:gridX] objectAtIndex:gridPosition.y];
        if (nextFlower.isMarkedMatched) break;
        if (localFlower.flowerType == nextFlower.flowerType)
            matchCountHorizontal++;
        else
            break;
    }
    
    //check to the left
    for (int i = 1; i < 5; i++)
    {
        int gridX = gridPosition.x - i;
        if (gridX < 0) break;
        
        NBFlower* nextFlower = (NBFlower*)[[self.flowerArrays objectAtIndex:gridX] objectAtIndex:gridPosition.y];
        if (nextFlower.isMarkedMatched) break;
        if (localFlower.flowerType == nextFlower.flowerType)
            matchCountHorizontal++;
        else
            break;
    }
    
    if (matchCountHorizontal < 3)
        matchCountHorizontal = 1; //If match count is not even three, dont add to the total match count and make 1
    else
        matchDetectedOnHorizontal = true; //if have 3 or more, mark as match found horizontally
    
    //check to the above
    for (int i = 1; i < 5; i++)
    {
        int gridY = gridPosition.y + i;
        if (gridY >= self.verticalTileCount) break;
        if (gridY >= [[self.flowerArrays objectAtIndex:gridPosition.x] count]) break;
        
        NBFlower* nextFlower = (NBFlower*)[[self.flowerArrays objectAtIndex:gridPosition.x] objectAtIndex:gridY];
        if (nextFlower.isMarkedMatched) break;
        if (localFlower.flowerType == nextFlower.flowerType)
            matchCountVertical++;
        else
            break;
    }
    
    //check to the bottom
    for (int i = 1; i < 5; i++)
    {
        int gridY = gridPosition.y - i;
        if (gridY < 0) break;
        
        NBFlower* nextFlower = (NBFlower*)[[self.flowerArrays objectAtIndex:gridPosition.x] objectAtIndex:gridY];
        if (nextFlower.isMarkedMatched) break;
        if (localFlower.flowerType == nextFlower.flowerType)
            matchCountVertical++;
        else
            break;
    }
    
    if (matchCountVertical < 3)
        matchCountVertical = 1; //If match count is not even three, dont add to the total match count and make 1
    else
        matchDetectedOnVertical = true; //if have 3 or more, mark as match found vertically as well
    
    matchCount = matchCountHorizontal + matchCountVertical - 1; //minus 1 to remove duplicate match with self when matching vertically
    
    if (matchCount >= 3)
        return true;
    else
        return false;
}

-(bool)checkMatchOnGrid:(CGPoint)gridPositionOfThisFlower usingSpecificFlower:(NBFlower*)thisFlower andModifyFlowerOnGrid:(CGPoint)modifiedFlowerGridPosition usingFlower:(NBFlower*)modifiedFlower
{
    int matchCount = 1; //include the flower itself
    int matchCountHorizontal = 1;
    int matchCountVertical = 1;
    bool matchDetectedOnHorizontal = false;
    bool matchDetectedOnVertical = false;
    
    //check to the right
    for (int i = 1; i < 5; i++)
    {
        int gridX = gridPositionOfThisFlower.x + i;
        if (gridX >= self.horizontalTileCount) break;
        if (gridX >= [[self.flowerArrays objectAtIndex:gridX] count]) break;
        
        NBFlower* nextFlower = nil;
        if ((modifiedFlowerGridPosition.x == gridX) && (modifiedFlowerGridPosition.y == gridPositionOfThisFlower.y))
        {
            nextFlower = modifiedFlower;
        }
        else
        {
            nextFlower = (NBFlower*)[[self.flowerArrays objectAtIndex:gridX] objectAtIndex:gridPositionOfThisFlower.y];
        }
        
        if (nextFlower.isMarkedMatched) break;
        if (thisFlower.flowerType == nextFlower.flowerType)
            matchCountHorizontal++;
        else
            break;
    }
    
    //check to the left
    for (int i = 1; i < 5; i++)
    {
        int gridX = gridPositionOfThisFlower.x - i;
        if (gridX < 0) break;
        
        NBFlower* nextFlower = nil;
        if ((modifiedFlowerGridPosition.x == gridX) && (modifiedFlowerGridPosition.y == gridPositionOfThisFlower.y))
        {
            nextFlower = modifiedFlower;
        }
        else
        {
            nextFlower = (NBFlower*)[[self.flowerArrays objectAtIndex:gridX] objectAtIndex:gridPositionOfThisFlower.y];
        }
        
        if (nextFlower.isMarkedMatched) break;
        if (thisFlower.flowerType == nextFlower.flowerType)
            matchCountHorizontal++;
        else
            break;
    }
    
    if (matchCountHorizontal < 3)
        matchCountHorizontal = 1; //If match count is not even three, dont add to the total match count and make 1
    else
        matchDetectedOnHorizontal = true; //if have 3 or more, mark as match found horizontally
    
    //check to the above
    for (int i = 1; i < 5; i++)
    {
        int gridY = gridPositionOfThisFlower.y + i;
        if (gridY >= self.verticalTileCount) break;
        if (gridY >= [[self.flowerArrays objectAtIndex:gridPositionOfThisFlower.x] count]) break;
        
        NBFlower* nextFlower = nil;
        if ((modifiedFlowerGridPosition.x == gridPositionOfThisFlower.x) && (modifiedFlowerGridPosition.y == gridY))
        {
            nextFlower = modifiedFlower;
        }
        else
        {
            nextFlower = (NBFlower*)[[self.flowerArrays objectAtIndex:gridPositionOfThisFlower.x] objectAtIndex:gridY];
        }
        
        if (nextFlower.isMarkedMatched) break;
        if (thisFlower.flowerType == nextFlower.flowerType)
            matchCountVertical++;
        else
            break;
    }
    
    //check to the bottom
    for (int i = 1; i < 5; i++)
    {
        int gridY = gridPositionOfThisFlower.y - i;
        if (gridY < 0) break;
        
        NBFlower* nextFlower = nil;
        if ((modifiedFlowerGridPosition.x == gridPositionOfThisFlower.x) && (modifiedFlowerGridPosition.y == gridY))
        {
            nextFlower = modifiedFlower;
        }
        else
        {
            nextFlower = (NBFlower*)[[self.flowerArrays objectAtIndex:gridPositionOfThisFlower.x] objectAtIndex:gridY];
        }
        
        if (nextFlower.isMarkedMatched) break;
        if (thisFlower.flowerType == nextFlower.flowerType)
            matchCountVertical++;
        else
            break;
    }
    
    if (matchCountVertical < 3)
        matchCountVertical = 1; //If match count is not even three, dont add to the total match count and make 1
    else
        matchDetectedOnVertical = true; //if have 3 or more, mark as match found vertically as well
    
    matchCount = matchCountHorizontal + matchCountVertical - 1; //minus 1 to remove duplicate match with self when matching vertically
    
    if (matchCount >= 3)
        return true;
    else
        return false;
}

-(CGPoint)isTouchingWhichGrid:(CGPoint)touchLocation
{
    int x = touchLocation.x / (FLOWERSIZE_WIDTH + FIELD_FLOWER_GAP_WIDTH);
    int y = touchLocation.y / (FLOWERSIZE_HEIGHT + FIELD_FLOWER_GAP_WIDTH);
    
    self.selectedFlowerGrid = ccp(x, y);
    
    return self.selectedFlowerGrid;
}

- (void)addSwipeGestureRecognizers
{
    if ((self.gestureRecognizers != nil) || ([self.gestureRecognizers count] > 0))
        return;
    
    UISwipeGestureRecognizer *downSwipeGestureRecognizer = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(onSwipe:)];
    downSwipeGestureRecognizer.direction = UISwipeGestureRecognizerDirectionDown;
    [[[CCDirector sharedDirector] view] addGestureRecognizer:downSwipeGestureRecognizer];
    
    UISwipeGestureRecognizer *leftSwipeGestureRecognizer = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(onSwipe:)];
    leftSwipeGestureRecognizer.direction = UISwipeGestureRecognizerDirectionLeft;
    [[[CCDirector sharedDirector] view] addGestureRecognizer:leftSwipeGestureRecognizer];
    
    UISwipeGestureRecognizer *rightSwipeGestureRecognizer = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(onSwipe:)];
    rightSwipeGestureRecognizer.direction = UISwipeGestureRecognizerDirectionRight;
    [[[CCDirector sharedDirector] view] addGestureRecognizer:rightSwipeGestureRecognizer];
    
    UISwipeGestureRecognizer *upSwipeGestureRecognizer = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(onSwipe:)];
    upSwipeGestureRecognizer.direction = UISwipeGestureRecognizerDirectionUp;
    [[[CCDirector sharedDirector] view] addGestureRecognizer:upSwipeGestureRecognizer];
    
    self.gestureRecognizers = [NSArray arrayWithObjects:downSwipeGestureRecognizer, leftSwipeGestureRecognizer, rightSwipeGestureRecognizer, upSwipeGestureRecognizer, nil];
}

-(void)onSwipe:(UISwipeGestureRecognizer*)swipeGestureRecognizer
{
    if (self.isProcessingMove || self.isProcessingMatching/* || isRearranging*/)
        return;
    
    CGSize winSize = [[CCDirector sharedDirector] winSize];
    
    self.isProcessingMove = true;
    
    CGPoint touchLocation = [swipeGestureRecognizer locationInView:[CCDirector sharedDirector].view];
    
    //need to flip because the coordinate systems are flipped
    touchLocation.y = [[CCDirector sharedDirector] winSize].height - touchLocation.y;
    
    touchLocation = ccp(touchLocation.x - (winSize.width / 2 - (self.contentSize.width / 2)), touchLocation.y - FIELD_Y_POSITION);
    
    CGPoint gridPositionBeingTouch = [self isTouchingWhichGrid:touchLocation];
    DLog(@"Flower Index (%f, %f) is touched.", gridPositionBeingTouch.x, gridPositionBeingTouch.y);
    
    [self sendSwipe:swipeGestureRecognizer];
}

-(void)sendSwipe:(UISwipeGestureRecognizer*)swipeGestureRecognizer
{
    lastGestureDirection = swipeGestureRecognizer.direction;
    
    switch (swipeGestureRecognizer.direction)
    {
        case UISwipeGestureRecognizerDirectionDown:
            self.swappedFlowerGrid = ccp(self.selectedFlowerGrid.x, self.selectedFlowerGrid.y - 1);
            break;
        case UISwipeGestureRecognizerDirectionLeft:
            self.swappedFlowerGrid = ccp(self.selectedFlowerGrid.x - 1, self.selectedFlowerGrid.y);
            break;
        case UISwipeGestureRecognizerDirectionRight:
            self.swappedFlowerGrid = ccp(self.selectedFlowerGrid.x + 1, self.selectedFlowerGrid.y);
            break;
        case UISwipeGestureRecognizerDirectionUp:
            self.swappedFlowerGrid = ccp(self.selectedFlowerGrid.x, self.selectedFlowerGrid.y + 1);
            break;
        default:
            break;
    }
    
    [self moveFlower:self.selectedFlowerGrid toGridPosition:self.swappedFlowerGrid swipe:swipeGestureRecognizer];
}

-(void)moveFlower:(CGPoint)originalGridPosition toGridPosition:(CGPoint)newGridPosition swipe:(UISwipeGestureRecognizer*)swipeGestureRecognizer
{
    //Check if at the border
    if ((newGridPosition.x < 0) || (newGridPosition.x > (self.horizontalTileCount - 1)) || (newGridPosition.y < 0) || (newGridPosition.y > (self.verticalTileCount - 1)))
    {
        [self unlockField];
        return;
    }
    
    NBFlower* originalFlower = (NBFlower*)[[self.flowerArrays objectAtIndex:self.selectedFlowerGrid.x] objectAtIndex:self.selectedFlowerGrid.y];
    NBFlower* flowerToBeSwapped = (NBFlower*)[[self.flowerArrays objectAtIndex:self.swappedFlowerGrid.x] objectAtIndex:self.swappedFlowerGrid.y];
    
    [originalFlower setZOrder:(flowerToBeSwapped.zOrder + 1)];
    
    switch (swipeGestureRecognizer.direction)
    {
        case UISwipeGestureRecognizerDirectionDown:
            [originalFlower move:fmtDown informLayerSelector:nil];
            [flowerToBeSwapped move:fmtUp informLayerSelector:@selector(onFlowerMoveCompleted)];
            break;
        case UISwipeGestureRecognizerDirectionLeft:
            [originalFlower move:fmtLeft informLayerSelector:nil];
            [flowerToBeSwapped move:fmtRight informLayerSelector:@selector(onFlowerMoveCompleted)];
            break;
        case UISwipeGestureRecognizerDirectionRight:
            [originalFlower move:fmtRight informLayerSelector:nil];
            [flowerToBeSwapped move:fmtLeft informLayerSelector:@selector(onFlowerMoveCompleted)];
            break;
        case UISwipeGestureRecognizerDirectionUp:
            [originalFlower move:fmtUp informLayerSelector:nil];
            [flowerToBeSwapped move:fmtDown informLayerSelector:@selector(onFlowerMoveCompleted)];
            break;
        default:
            break;
    }
    
    flowerToBeSwapped.gridPosition = originalFlower.gridPosition;
    originalFlower.gridPosition = newGridPosition;
}

-(void)returnFlower
{
    [self lockField];
    isReturningFlower = true;
    
    NBFlower* originalFlower = (NBFlower*)[[self.flowerArrays objectAtIndex:self.selectedFlowerGrid.x] objectAtIndex:self.selectedFlowerGrid.y];
    NBFlower* flowerToBeSwapped = (NBFlower*)[[self.flowerArrays objectAtIndex:self.swappedFlowerGrid.x] objectAtIndex:self.swappedFlowerGrid.y];
    
    [originalFlower setZOrder:(flowerToBeSwapped.zOrder + 1)];
    
    switch (lastGestureDirection)
    {
        case UISwipeGestureRecognizerDirectionDown:
            [originalFlower move:fmtUp informLayerSelector:nil];
            [flowerToBeSwapped move:fmtDown informLayerSelector:@selector(onFlowerMoveCompleted)];
            break;
        case UISwipeGestureRecognizerDirectionLeft:
            [originalFlower move:fmtRight informLayerSelector:nil];
            [flowerToBeSwapped move:fmtLeft informLayerSelector:@selector(onFlowerMoveCompleted)];
            break;
        case UISwipeGestureRecognizerDirectionRight:
            [originalFlower move:fmtLeft informLayerSelector:nil];
            [flowerToBeSwapped move:fmtRight informLayerSelector:@selector(onFlowerMoveCompleted)];
            break;
        case UISwipeGestureRecognizerDirectionUp:
            [originalFlower move:fmtDown informLayerSelector:nil];
            [flowerToBeSwapped move:fmtUp informLayerSelector:@selector(onFlowerMoveCompleted)];
            break;
        default:
            break;
    }
    
    CGPoint newGridPosition = flowerToBeSwapped.gridPosition;
    flowerToBeSwapped.gridPosition = originalFlower.gridPosition;
    originalFlower.gridPosition = newGridPosition;
}

-(NSMutableArray*)checkLocalMatchFlowersAndAddToMatchSlots:(CGPoint)gridPoint
{
    NSMutableArray* array = [NSMutableArray array];
    
    int matchCount = 1; //include the flower itself
    int matchCountHorizontal = 1;
    int matchCountVertical = 1;
    bool matchDetectedOnHorizontal = false;
    bool matchDetectedOnVertical = false;
    
    NBFlower* localFlower = (NBFlower*)[[self.flowerArrays objectAtIndex:gridPoint.x] objectAtIndex:gridPoint.y];
    //Add the original flower at the first position. Later on if any match, all other flowers move to this flower's position
    NSValue* matchedPosition = [NSValue valueWithCGPoint:localFlower.gridPosition];
    [array addObject:matchedPosition];
    
    //check to the right
    for (int i = 1; i < 5; i++)
    {
        int gridX = gridPoint.x + i;
        if (gridX >= self.horizontalTileCount) break;
        
        NBFlower* nextFlower = (NBFlower*)[[self.flowerArrays objectAtIndex:gridX] objectAtIndex:gridPoint.y];
        if (nextFlower.isMarkedMatched) break;
        if (localFlower.flowerType == nextFlower.flowerType)
        {
            NSValue* matchedPosition = [NSValue valueWithCGPoint:nextFlower.gridPosition];
            [array addObject:matchedPosition];
            matchCountHorizontal++;
        }
        else
            break;
    }
    
    //check to the left
    for (int i = 1; i < 5; i++)
    {
        int gridX = gridPoint.x - i;
        if (gridX < 0) break;
        
        NBFlower* nextFlower = (NBFlower*)[[self.flowerArrays objectAtIndex:gridX] objectAtIndex:gridPoint.y];
        if (nextFlower.isMarkedMatched) break;
        if (localFlower.flowerType == nextFlower.flowerType)
        {
            NSValue* matchedPosition = [NSValue valueWithCGPoint:nextFlower.gridPosition];
            [array addObject:matchedPosition];
            matchCountHorizontal++;
        }
        else
            break;
    }
    
    if (matchCountHorizontal < 3)
    {
        for (int i = 0; i < matchCountHorizontal - 1; i++)
        {
            [array removeLastObject];
        }
        
        matchCountHorizontal = 1; //If match count is not even three, dont add to the total match count and make 1
    }
    else
        matchDetectedOnHorizontal = true; //if have 3 or more, mark as match found horizontally
    
    //check to the above
    for (int i = 1; i < 5; i++)
    {
        int gridY = gridPoint.y + i;
        if (gridY >= self.verticalTileCount) break;
        
        NBFlower* nextFlower = (NBFlower*)[[self.flowerArrays objectAtIndex:gridPoint.x] objectAtIndex:gridY];
        if (nextFlower.isMarkedMatched) break;
        if (localFlower.flowerType == nextFlower.flowerType)
        {
            NSValue* matchedPosition = [NSValue valueWithCGPoint:nextFlower.gridPosition];
            [array addObject:matchedPosition];
            matchCountVertical++;
        }
        else
            break;
    }
    
    //check to the bottom
    for (int i = 1; i < 5; i++)
    {
        int gridY = gridPoint.y - i;
        if (gridY < 0) break;
        
        NBFlower* nextFlower = (NBFlower*)[[self.flowerArrays objectAtIndex:gridPoint.x] objectAtIndex:gridY];
        if (nextFlower.isMarkedMatched) break;
        if (localFlower.flowerType == nextFlower.flowerType)
        {
            NSValue* matchedPosition = [NSValue valueWithCGPoint:nextFlower.gridPosition];
            [array addObject:matchedPosition];
            matchCountVertical++;
        }
        else
            break;
    }
    
    if (matchCountVertical < 3)
    {
        for (int i = 0; i < matchCountVertical - 1; i++)
        {
            [array removeLastObject];
        }
        
        matchCountVertical = 1; //If match count is not even three, dont add to the total match count and make 1
    }
    else
        matchDetectedOnVertical = true; //if have 3 or more, mark as match found vertically as well
    
    matchCount = matchCountHorizontal + matchCountVertical - 1; //minus 1 to remove duplicate match with self when matching vertically
    
    if (matchCount >= 3)
    {
        NBBouquetType bouquetType = btNoMatch;
        
        if (matchCount == 3) bouquetType = btThreeOfAKind;
        if (matchCount == 4) bouquetType = btFourOfAKind;
        if ((matchCount == 5) && (matchDetectedOnHorizontal && matchDetectedOnVertical)) bouquetType = btCornerFiveOfAKind;
        if (matchCount == 5) bouquetType = btFiveOfAKind;
        if (matchCount == 6) bouquetType = btSixOfAKind;
        if (matchCount >= 7) bouquetType = btSevenOfAKind;
    
        for (int i = 0; i < [array count]; i++)
        {
            NSValue* value = [array objectAtIndex:i];
            CGPoint flowerPosition = [value CGPointValue];
            NBFlower* flower = (NBFlower*)[[self.flowerArrays objectAtIndex:flowerPosition.x] objectAtIndex:flowerPosition.y];
            flower.bouquetType = bouquetType;
            flower.isMarkedMatched = true;
        }
        
        [self.arrayOfMatchedFlowerSlots addObject:array];
        [self processRemoveMatchedFlowerOnArray:array];
        
        return array;
    }
    else
    {
        //Otherwise
        [array removeAllObjects];
        return nil;
    }
}

-(void)swapFlowerOnGrid:(CGPoint)flowerAGrid withFlowerOnGrid:(CGPoint)flowerBGrid
{
    NBFlower* swappingFlower = (NBFlower*)[[self.flowerArrays objectAtIndex:flowerAGrid.x] objectAtIndex:flowerAGrid.y];
    NBFlower* toBeSwappedFlower = (NBFlower*)[[self.flowerArrays objectAtIndex:flowerBGrid.x] objectAtIndex:flowerBGrid.y];
    
    NBFlower* newSwappingFlower = [NBFlower createNewFlower:swappingFlower.flowerType onGridPosition:swappingFlower.gridPosition show:true];
    NBFlower* newToBeSwappedFlower = [NBFlower createNewFlower:toBeSwappedFlower.flowerType onGridPosition:toBeSwappedFlower.gridPosition show:true];
    
    [[self.flowerArrays objectAtIndex:flowerAGrid.x] setObject:newToBeSwappedFlower atIndex:flowerAGrid.y];
    [[self.flowerArrays objectAtIndex:flowerBGrid.x] setObject:newSwappingFlower atIndex:flowerBGrid.y];
    
    swappingFlower.visible = NO;
    toBeSwappedFlower.visible = NO;
    [self removeChild:swappingFlower cleanup:YES];
    [self removeChild:toBeSwappedFlower cleanup:YES];
    [swappingFlower release];
    [toBeSwappedFlower release];
    
    CGPoint tempGridPoint = self.selectedFlowerGrid;
    self.selectedFlowerGrid = self.swappedFlowerGrid;
    self.swappedFlowerGrid = tempGridPoint;
}

-(void)onFlowerMoveCompleted
{
    bool hasMatch = false;
    
    DLog("Move completed.");

    [self swapFlowerOnGrid:self.selectedFlowerGrid withFlowerOnGrid:self.swappedFlowerGrid];

    if (!isReturningFlower)
    {
        NSMutableArray* arrayOfMatchedFlowers = [self checkLocalMatchFlowersAndAddToMatchSlots:self.selectedFlowerGrid];
        if ([arrayOfMatchedFlowers count] > 0)
        {
            NSValue* value = (NSValue*)[arrayOfMatchedFlowers objectAtIndex:0];
            CGPoint flowerPosition = [value CGPointValue];
            NBFlower* flower = (NBFlower*)[[self.flowerArrays objectAtIndex:flowerPosition.x] objectAtIndex:flowerPosition.y];
            self.currentBouquetMatchType = flower.bouquetType;
        }
        else
            self.currentBouquetMatchType = btNoMatch;
        
        switch (self.currentBouquetMatchType)
        {
            case btNoMatch:
                DLog(@"no match on selected flower");
                hasMatch = false;
                break;
            case btThreeOfAKind:
                DLog(@"found three of a kind on selected flower");
                hasMatch = true;
                break;
            case btFourOfAKind:
                DLog(@"found four of a kind on selected flower");
                hasMatch = true;
                break;
            case btFiveOfAKind:
                DLog(@"found five of a kind on selected flower");
                hasMatch = true;
                break;
            case btCornerFiveOfAKind:
                DLog(@"found corner type five of a kind on selected flower");
                hasMatch = true;
                break;
            case btSixOfAKind:
                DLog(@"found six of a kind on selected flower");
                hasMatch = true;
                break;
            case btSevenOfAKind:
                DLog(@"found seven of a kind on selected flower");
                hasMatch = true;
                break;
            default:
                break;
        }
        
        [self produceBouquet:self.currentBouquetMatchType onGrid:self.selectedFlowerGrid];
        
        arrayOfMatchedFlowers = [self checkLocalMatchFlowersAndAddToMatchSlots:self.swappedFlowerGrid];
        if ([arrayOfMatchedFlowers count] > 0)
        {
            NSValue* value = (NSValue*)[arrayOfMatchedFlowers objectAtIndex:0];
            CGPoint flowerPosition = [value CGPointValue];
            NBFlower* flower = (NBFlower*)[[self.flowerArrays objectAtIndex:flowerPosition.x] objectAtIndex:flowerPosition.y];
            self.currentBouquetMatchType = flower.bouquetType;
        }
        else
            self.currentBouquetMatchType = btNoMatch;
        
        switch (self.currentBouquetMatchType)
        {
            case btNoMatch:
                DLog(@"no match on swapped flower");
                break;
            case btThreeOfAKind:
                DLog(@"found three of a kind on swapped flower");
                hasMatch = true;
                break;
            case btFourOfAKind:
                DLog(@"found four of a kind on swapped flower");
                hasMatch = true;
                break;
            case btFiveOfAKind:
                DLog(@"found five of a kind on swapped flower");
                hasMatch = true;
                break;
            case btCornerFiveOfAKind:
                DLog(@"found corner type five of a kind on swapped flower");
                hasMatch = true;
                break;
            case btSixOfAKind:
                DLog(@"found six of a kind on swapped flower");
                hasMatch = true;
                break;
            case btSevenOfAKind:
                DLog(@"found seven of a kind on swapped flower");
                hasMatch = true;
                break;
            default:
                break;
        }
        
        [self produceBouquet:self.currentBouquetMatchType onGrid:self.swappedFlowerGrid];
        
        if (!hasMatch)
            [self returnFlower];
        else
            [self lockField];
    }
    else
    {
        isReturningFlower = false;
        [self unlockField];
    }
}

-(void)processRemoveMatchedFlowerOnArray:(NSMutableArray*)flowerArray
{
    if ([flowerArray count] == 0) return;
    
    [self lockField];
    
    NSValue* value = [flowerArray objectAtIndex:0];
    CGPoint originalFlowerPosition = [value CGPointValue];
    NBFlower* originalFlower = (NBFlower*)[[self.flowerArrays objectAtIndex:originalFlowerPosition.x] objectAtIndex:originalFlowerPosition.y];
    
    for (int i = 1; i < [flowerArray count]; i++)
    {
        NSValue* value = [flowerArray objectAtIndex:i];
        CGPoint matchingFlowerPosition = [value CGPointValue];
        NBFlower* matchingFlower = (NBFlower*)[[self.flowerArrays objectAtIndex:matchingFlowerPosition.x] objectAtIndex:matchingFlowerPosition.y];
        matchingFlower.isMoveCompleted = false;
        [matchingFlower moveToGrid:originalFlower.gridPosition withDuration:0.45f informSelector:nil];
    }
}

-(void)update:(ccTime)delta
{
    if ([self.arrayOfMatchedFlowerSlots count] > 0)
    {
        [self lockField];
        
        for (int i = 0; i < [self.arrayOfMatchedFlowerSlots count]; i++)
        {
            bool allMatchingFlowerCombined = true;
            
            NSMutableArray* arrayOfMatchedFlowers = [self.arrayOfMatchedFlowerSlots objectAtIndex:i];
            
            for (int i = 1; i < [arrayOfMatchedFlowers count]; i++)
            {
                NSValue* value = [arrayOfMatchedFlowers objectAtIndex:i];
                CGPoint matchingFlowerPosition = [value CGPointValue];
                NBFlower* matchingFlower = (NBFlower*)[[self.flowerArrays objectAtIndex:matchingFlowerPosition.x] objectAtIndex:matchingFlowerPosition.y];
                
                if (!matchingFlower.isMoveCompleted)
                {
                    allMatchingFlowerCombined = false;
                    break;
                }
            }
            
            if (allMatchingFlowerCombined)
            {
                DLog(@"remove flower from field");
                [self removeFlowerFromField:arrayOfMatchedFlowers];
                [self.arrayOfMatchedFlowerSlots removeObject:arrayOfMatchedFlowers];
                
                if ([self.arrayOfMatchedFlowerSlots count] == 0)
                {
                    [self checkEmptySlots];
                }
            }
        }
    }
    
    if (needToCheckCombo)
    {
        timeRemainingBeforeComboCheck -= delta;
        if (timeRemainingBeforeComboCheck <= 0)
        {
            [self unlockField];
            timeRemainingBeforeComboCheck = DURATION_TO_CHECK_EMPTY_SLOT;
            needToCheckCombo = false;
            [self checkMatchCombo];
        }
    }
    
    if (needtocheckPossibleMove)
    {
        timeRemainingBeforePossibleMoveCheck -= delta;
        if (timeRemainingBeforePossibleMoveCheck <= 0)
        {
            [self unlockField];
            timeRemainingBeforePossibleMoveCheck = DURATION_TO_CHECK_EMPTY_SLOT;
            needtocheckPossibleMove = false;
            if (![self detectPossibleMove])
            {
                //invoke random rearranging
            }
        }
    }
}

-(void)removeFlowerFromField:(NSArray*)arrayOfToBeRemovedFlowers
{
    for (int i = 0; i < [arrayOfToBeRemovedFlowers count]; i++)
    {
        NSValue* value = [arrayOfToBeRemovedFlowers objectAtIndex:i];
        CGPoint matchingFlowerPosition = [value CGPointValue];
        NBFlower* matchingFlower = (NBFlower*)[[self.flowerArrays objectAtIndex:matchingFlowerPosition.x] objectAtIndex:matchingFlowerPosition.y];
        NBFlower* emptyFlower = [NBFlower createNewFlower:ftNoFlower onGridPosition:matchingFlowerPosition show:true];
        
        [[self.flowerArrays objectAtIndex:matchingFlowerPosition.x] setObject:emptyFlower atIndex:matchingFlowerPosition.y];
        [self removeChild:matchingFlower cleanup:YES];
        [matchingFlower release];
    }
}

-(void)checkEmptySlots
{
    bool hasEmpty = false;
    
    for (int x = 0; x < self.horizontalTileCount; x++)
    {
        for (int y = 0; y < self.verticalTileCount; y++)
        {
            NBFlower* flower = (NBFlower*)[[self.flowerArrays objectAtIndex:x] objectAtIndex:y];
            if (flower.flowerType == ftNoFlower)
            {
                hasEmpty = true;
                [self rearrangeGridPosition:CGPointMake(x, y)];
            }
        }
    }
    
    if (!hasEmpty)
    {
        self.isProcessingMatching = false;
    }
    else
    {
        needToCheckCombo = true;
    }
}

-(void)checkMatchCombo
{
    isCheckingCombo = true;
    bool hasMatch = false;
    bool hasAtLeast1Match = false;
    
    for (int i = 0; i < [self.potentialComboGrids count]; i++)
    {
        NSValue* value = [self.potentialComboGrids objectAtIndex:i];
        CGPoint flowerPosition = [value CGPointValue];
        
        NSMutableArray* arrayOfMatchedFlowers = [self checkLocalMatchFlowersAndAddToMatchSlots:flowerPosition];
        if ([arrayOfMatchedFlowers count] > 0)
        {
            NSValue* value = (NSValue*)[arrayOfMatchedFlowers objectAtIndex:0];
            CGPoint flowerPosition = [value CGPointValue];
            NBFlower* flower = (NBFlower*)[[self.flowerArrays objectAtIndex:flowerPosition.x] objectAtIndex:flowerPosition.y];
            self.currentBouquetMatchType = flower.bouquetType;
        }
        else
            self.currentBouquetMatchType = btNoMatch;

        switch (self.currentBouquetMatchType)
        {
            case btNoMatch:
                //DLog(@"no match on swapped flower");
                hasMatch = false;
                break;
            case btThreeOfAKind:
                DLog(@"found three of a kind on swapped flower");
                hasMatch = true;
                break;
            case btFourOfAKind:
                DLog(@"found four of a kind on swapped flower");
                hasMatch = true;
                break;
            case btFiveOfAKind:
                DLog(@"found five of a kind on swapped flower");
                hasMatch = true;
                break;
            case btCornerFiveOfAKind:
                DLog(@"found corner type five of a kind on swapped flower");
                hasMatch = true;
                break;
            case btSixOfAKind:
                DLog(@"found six of a kind on swapped flower");
                hasMatch = true;
                break;
            case btSevenOfAKind:
                DLog(@"found seven of a kind on swapped flower");
                hasMatch = true;
                break;
            default:
                break;
        }
        
        [self produceBouquet:self.currentBouquetMatchType onGrid:flowerPosition];
        
        if (hasMatch)
        {
            hasAtLeast1Match = true;
            [self lockField];
            
            for (int i = 0; i < [arrayOfMatchedFlowers count]; i++)
            {
                NSValue* valueOfMatched = (NSValue*)[arrayOfMatchedFlowers objectAtIndex:i];
                CGPoint matchedFlowerPosition = [valueOfMatched CGPointValue];
                
                for (int j = 0; j < [self.potentialComboGrids count]; j++)
                {
                    NSValue* valueOfPotentialCombo = (NSValue*)[self.potentialComboGrids objectAtIndex:j];
                    CGPoint potentialComboFlowerPosition = [valueOfPotentialCombo CGPointValue];
                    
                    if (matchedFlowerPosition.x == potentialComboFlowerPosition.x && matchedFlowerPosition.y == potentialComboFlowerPosition.y)
                    {
                        [self.potentialComboGrids removeObjectAtIndex:j];
                        j--;
                        break;
                    }
                }
            }
        }
    }
    
    if (!hasAtLeast1Match)
        needtocheckPossibleMove = true;
    
    isCheckingCombo = false;
}

-(void)rearrangeGridPosition:(CGPoint)gridPosition
{
    isRearranging = true;
    int emptyCount = 0;
    timeRemainingBeforeComboCheck = DURATION_TO_CHECK_EMPTY_SLOT;

    while (true)
    {
        CGPoint gridAbove = CGPointMake(gridPosition.x, gridPosition.y + 1 + emptyCount);
        if (gridAbove.y >= self.verticalTileCount)
        {
            [self generateRandomFlowerAndBloomOnGridPosition:gridPosition];
            NSValue* gridPositionObject = [NSValue valueWithCGPoint:gridPosition];
            [self.potentialComboGrids addObject:gridPositionObject];
            [self.potentialNextMoveHasMatchGrids addObject:gridPositionObject];
            break;
        }
        else
        {
            NBFlower* flowerAbove = (NBFlower*)[[self.flowerArrays objectAtIndex:gridAbove.x] objectAtIndex:gridAbove.y];
            if (flowerAbove.flowerType == ftNoFlower)
            {
                emptyCount++;
            }
            else
            {
                NBFlower* flowerInThisGrid = (NBFlower*)[[self.flowerArrays objectAtIndex:gridPosition.x] objectAtIndex:gridPosition.y];
                NBFlower* emptyFlower = [NBFlower createNewFlower:ftNoFlower onGridPosition:gridAbove show:true];
                NBFlower* newFlowerAbove = [NBFlower createNewFlower:flowerAbove.flowerType onGridPosition:flowerAbove.gridPosition show:true];
                
                [[self.flowerArrays objectAtIndex:gridPosition.x] setObject:newFlowerAbove atIndex:gridPosition.y];
                [[self.flowerArrays objectAtIndex:gridAbove.x] setObject:emptyFlower atIndex:gridAbove.y];
                [newFlowerAbove moveToGrid:gridPosition withDuration:(0.3f * (1 + (emptyCount / 2))) informSelector:nil];
                newFlowerAbove.gridPosition = gridPosition;
                NSValue* gridPositionObject = [NSValue valueWithCGPoint:newFlowerAbove.gridPosition];
                [self.potentialComboGrids addObject:gridPositionObject];
                [self.potentialNextMoveHasMatchGrids addObject:gridPositionObject];
                
                [flowerAbove removeFromParentAndCleanup:YES];
                [flowerAbove release];
                [flowerInThisGrid removeFromParentAndCleanup:YES];
                [flowerInThisGrid release];
                
                emptyCount = 0;
                gridPosition = CGPointMake(gridPosition.x, gridPosition.y + 1);
            }
        }
    }
    
    isRearranging = false;
}

-(void)generateRandomFlowerAndBloomOnGridPosition:(CGPoint)gridPosition
{
    NBFlower* flowerToBeReplaced = (NBFlower*)[[self.flowerArrays objectAtIndex:gridPosition.x] objectAtIndex:gridPosition.y];
    flowerToBeReplaced.visible = NO;
    NBFlower* randomNewFlower = [NBFlower bloomRandomFlowerOnGridPosition:gridPosition];
    [[self.flowerArrays objectAtIndex:gridPosition.x] setObject:randomNewFlower atIndex:gridPosition.y];
    
    [flowerToBeReplaced removeFromParentAndCleanup:YES];
    [flowerToBeReplaced release];
}

-(NBCustomer*)checkMatchedFlowerWithCustomerRequirement:(NBBouquetType)bouquetType
{
    NBGameGUI* gameGUI = [NBGameGUI sharedGameGUI];
    
    for (NBCustomer* customer in gameGUI.customersArray)
    {
        if (customer.flowerRequest.bouquetType == bouquetType)
        {
            return customer;
        }
    }
    
    return nil;
}

-(void)produceBouquet:(NBBouquetType)bouquetType onGrid:(CGPoint)gridPosition
{
    if (bouquetType == btNoMatch)
        return;
    
    NBBouquet* bouquet = [NBBouquet bloomBouquetWithType:bouquetType withPosition:[NBFlower convertFieldGridPositionToActualPixel:gridPosition] addToNode:self];
    NBCustomer* fulfilledCustomer = [self checkMatchedFlowerWithCustomerRequirement:bouquet.bouquetType];
    
    if (fulfilledCustomer)
    {
        NBGameGUI* gameGUI = [NBGameGUI sharedGameGUI];
        int index = 0;
        
        for (NBCustomer* customer in gameGUI.customersArray)
        {
            if (customer == fulfilledCustomer)
                break;
            
            index++;
        }
        
        [bouquet performCustomerFulfillingScoringAtCustomerPosition:fulfilledCustomer.flowerRequest.position andIndex:index andInformLayer:self withSelector:@selector(onBouquetReachedCustomer:bouquet:)];
    }
    else
    {
        [bouquet performStandardScoringAndInformLayer:self withSelector:@selector(onBouquetReachedScore:)];
    }
}

-(void)onBouquetReachedScore:(NBBouquet*)bouquet
{
    NBGameGUI* gameGUI = [NBGameGUI sharedGameGUI];
    [gameGUI doAddScore:bouquet.value];
    
    [self removeChild:bouquet cleanup:YES];
}

-(void)onBouquetReachedCustomer:(NSNumber*)customerIndex bouquet:(NBBouquet*)bouquet
{
    NBGameGUI* gameGUI = [NBGameGUI sharedGameGUI];
    [gameGUI doFulfillCustomer:[customerIndex intValue] flowerScore:0];
    
    [self removeChild:bouquet cleanup:YES];
}

-(void)lockField
{
    if (self.isProcessingMove) return;
    
    DLog(@"locking...");
    self.isProcessingMove = true;
}

-(void)unlockField
{
    if (!self.isProcessingMove) return;
    
    DLog(@"unlocking...");
    self.isProcessingMove = false;
}

-(bool)detectPossibleMove
{
    [self lockField];
    
    bool hasMatch = false;
    
    for (int x = 0; x < [self.flowerArrays count]; x++)
    {
        for (int y = 0; y < [self.flowerArrays count]; y++)
        {
            //NSValue* value = (NSValue*)[self.flowerArrays objectAtIndex:x];
            //CGPoint possibleMoveFlowerGridPosition = [value CGPointValue];
            
            for (int j = 0; j < fmtMaxMoveType; j++)
            {
                if ([self checkPossibleMatchIfGrid:ccp(x, y) moveTo:(NBFlowerMoveType)j])
                {
                    hasMatch = true;
                    break;
                }
            }
            
            if (hasMatch) break;
        }
        
        if (hasMatch) break;
        //[self.potentialNextMoveHasMatchGrids removeObjectAtIndex:i--];
    }
    
    [self unlockField];
    
    if (hasMatch)
        DLog(@"found possible move");
    else
        DLog(@"No possible move found");
    
    return hasMatch;
}

-(bool)checkPossibleMatchIfGrid:(CGPoint)gridPosition moveTo:(NBFlowerMoveType)moveType
{
    bool hasMatch = false;
    NBFlower* thisFlower = (NBFlower*)[[self.flowerArrays objectAtIndex:gridPosition.x] objectAtIndex:gridPosition.y];
    
    switch (moveType)
    {
        case fmtUp:
        {
            if ((thisFlower.gridPosition.y + 1) >= self.verticalTileCount) break;
            NBFlower* neighboringFlower = (NBFlower*)[[self.flowerArrays objectAtIndex:thisFlower.gridPosition.x] objectAtIndex:(thisFlower.gridPosition.y + 1)];
            hasMatch = [self checkMatchOnGrid:ccp(gridPosition.x, gridPosition.y + 1) usingSpecificFlower:thisFlower andModifyFlowerOnGrid:gridPosition usingFlower:neighboringFlower];
        }
            break;
        case fmtDown:
        {
            if ((thisFlower.gridPosition.y - 1) < 0) break;
            NBFlower* neighboringFlower = (NBFlower*)[[self.flowerArrays objectAtIndex:thisFlower.gridPosition.x] objectAtIndex:(thisFlower.gridPosition.y - 1)];
            hasMatch = [self checkMatchOnGrid:ccp(gridPosition.x, gridPosition.y - 1) usingSpecificFlower:thisFlower andModifyFlowerOnGrid:gridPosition usingFlower:neighboringFlower];
        }
            break;
        case fmtRight:
        {
            if ((thisFlower.gridPosition.x + 1) >= self.horizontalTileCount) break;
            NBFlower* neighboringFlower = (NBFlower*)[[self.flowerArrays objectAtIndex:(thisFlower.gridPosition.x + 1)] objectAtIndex:thisFlower.gridPosition.y];
            hasMatch = [self checkMatchOnGrid:ccp(gridPosition.x + 1, gridPosition.y) usingSpecificFlower:thisFlower andModifyFlowerOnGrid:gridPosition usingFlower:neighboringFlower];
        }
            break;
        case fmtLeft:
        {
            if ((thisFlower.gridPosition.x - 1) < 0) break;
            NBFlower* neighboringFlower = (NBFlower*)[[self.flowerArrays objectAtIndex:(thisFlower.gridPosition.x - 1)] objectAtIndex:thisFlower.gridPosition.y];
            hasMatch = [self checkMatchOnGrid:ccp(gridPosition.x - 1, gridPosition.y) usingSpecificFlower:thisFlower andModifyFlowerOnGrid:gridPosition usingFlower:neighboringFlower];
        }
            break;
        default:
            break;
    }
    
    return hasMatch;
}

@end
