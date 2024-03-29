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
    bool isGameJustStarted;
    bool isReturningFlower; //use to detect whether after the move need to check match
    bool isRearranging;
    bool isCheckingCombo;
    bool needToCheckCombo;
    bool needtocheckPossibleMove;
    bool userHasMakeAMoveSinceHistDisplayed;
    UISwipeGestureRecognizerDirection lastGestureDirection;
    ccTime timeRemainingBeforeComboCheck;
    ccTime timeRemainingBeforePossibleMoveCheck;
    ccTime timeRemainingBeforeDisplayingHintMove;
    CGPoint currentlyShownHintMoveGridPosition;
    NBFieldRandomArray* virtualRandomNumberArray;
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
        isFlowerFieldExpanded = true;
        
        if (isFlowerFieldExpanded)
        {
            self.horizontalTileCount = FIELD_HORIZONTAL_UNIT_COUNT_EXPANDED;
            self.verticalTileCount = FIELD_VERTICAL_UNIT_COUNT_EXPANDED;
            self.fieldBackground = [CCSprite spriteWithFile:@"nb_flowerBoard_b_640x713-hd.png"];
            [NBFlower assignStartingPosition:CGPointMake((FIELD_FLOWER_GAP_WIDTH * 2) + 1, (FIELD_FLOWER_GAP_WIDTH * 2) + 1)];
        }
        else
        {
            self.horizontalTileCount = FIELD_HORIZONTAL_UNIT_COUNT;
            self.verticalTileCount = FIELD_VERTICAL_UNIT_COUNT;
            self.fieldBackground = [CCSprite spriteWithFile:@"nb_flowerBoard_b_640x725-hd.png"];
            [NBFlower assignStartingPosition:CGPointMake((FIELD_FLOWER_GAP_WIDTH * 3) + (FLOWERSIZE_WIDTH / 2) - 1, (FIELD_FLOWER_GAP_WIDTH * 3) + (FLOWERSIZE_HEIGHT / 2) - 1)];
        }
        
        [self setContentSize:CGSizeMake((((FLOWERSIZE_WIDTH + FIELD_FLOWER_GAP_WIDTH) * self.horizontalTileCount) + FIELD_FLOWER_GAP_WIDTH), (((FLOWERSIZE_HEIGHT + FIELD_FLOWER_GAP_WIDTH) * self.verticalTileCount) + FIELD_FLOWER_GAP_WIDTH))];
        self.anchorPoint = ccp(0, 0);
        self.position = ccp(winSize.width / 2 - (self.contentSize.width / 2), FIELD_POSITION_ADJUSTMENT);
        self.position = ccp(0, 0);
        DLog(@"%f", winSize.width / 2 - (self.contentSize.width / 2));
        DLog(@"customer width = %f", winSize.width / 3);
        DLog(@"customer height = %f", winSize.height - ((713/2) + winSize.height * 0.1));
        
        //self.fieldBackground = [CCSprite spriteWithSpriteFrameName:@"staticbox_white.png"];
        //self.fieldBackground.scaleX = self.contentSize.width / self.fieldBackground.contentSize.width;
        //self.fieldBackground.scaleY = self.contentSize.height / self.fieldBackground.contentSize.height;
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
        self.currentRoundPossibleMoves = [NSMutableArray array];
        virtualRandomNumberArray = [NBFieldRandomArray arrayWithFieldHorizontalCount:self.horizontalTileCount andVerticalCount:self.verticalTileCount];
        
        for (int i = 0; i < self.horizontalTileCount; i++)
        {
            NSMutableArray* verticalFlowerArray = [NSMutableArray array];
            
            [self.flowerArrays addObject:verticalFlowerArray];
        }
        
        [NBFlower assignFieldLayer:self];
        [NBFlower assignFlowerField:self.flowerArrays];
        [NBFlower assignFieldContentSize:self.contentSize];
        [NBFlower assignDifficultyLevel:[NBDataManager getDifficultyValueOnKey:@"flowerTypeLevel"]];
        
        [self generateLevel];
        [self showAllFlower];
        [self unlockField];
        needToCheckCombo = false;
        needtocheckPossibleMove = false;
        isGameJustStarted = true;
        userHasMakeAMoveSinceHistDisplayed = true;
        
        [self addSwipeGestureRecognizers];
        [self scheduleUpdate];
        
        timeRemainingBeforeComboCheck = DURATION_TO_CHECK_EMPTY_SLOT;
        timeRemainingBeforePossibleMoveCheck = DURATION_TO_CHECK_EMPTY_SLOT;
        
        NBDataManager* dataManager = [NBDataManager sharedDataManager];
        CCArray* itemList = [NBDataManager getItemList];
        NBItemData* itemData = (NBItemData*)[itemList objectAtIndex:0];
        self.timeBooster = [NBActiveItem createNewItemWithItemData:itemData withTypeOf:itCustomerWaitTimeCharger withStockAmount:[dataManager getItem0Quantity]];
        itemData = [[NBDataManager getItemList] objectAtIndex:1];
        self.lifeBooster = [NBActiveItem createNewItemWithItemData:itemData withTypeOf:itLifeCharger withStockAmount:[dataManager getItem1Quantity]];
        itemData = [[NBDataManager getItemList] objectAtIndex:2];
        self.scoreBooster = [NBActiveItem createNewItemWithItemData:itemData withTypeOf:itScoreMultiplier withStockAmount:[dataManager getItem2Quantity]];
        self.activeItemsMenu = [CCMenu menuWithItems:self.timeBooster.itemImage, self.lifeBooster.itemImage, self.scoreBooster.itemImage, nil];
        self.activeItemsMenu.anchorPoint = ccp(0, 0);
        self.activeItemsMenu.position = ccp(2, self.fieldBackground.contentSize.height - self.timeBooster.itemImage.contentSize.height - 4);
        [self addChild:self.activeItemsMenu z:self.fieldBackground.zOrder + 1];
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

-(bool)generateLevel
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
    
    return [self detectPossibleMove];
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
        if (localFlower.flowerType == nextFlower.flowerType || nextFlower.flowerType == ftSpecialWildFlower)
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
        if (localFlower.flowerType == nextFlower.flowerType || nextFlower.flowerType == ftSpecialWildFlower)
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
        if (localFlower.flowerType == nextFlower.flowerType || nextFlower.flowerType == ftSpecialWildFlower)
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
        if (localFlower.flowerType == nextFlower.flowerType || nextFlower.flowerType == ftSpecialWildFlower)
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
        if (thisFlower.flowerType == nextFlower.flowerType || nextFlower.flowerType == ftSpecialWildFlower)
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
        if (thisFlower.flowerType == nextFlower.flowerType || nextFlower.flowerType == ftSpecialWildFlower)
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
        if (thisFlower.flowerType == nextFlower.flowerType || nextFlower.flowerType == ftSpecialWildFlower)
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
        if (thisFlower.flowerType == nextFlower.flowerType || nextFlower.flowerType == ftSpecialWildFlower)
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
        if (localFlower.flowerType == nextFlower.flowerType || nextFlower.flowerType == ftSpecialWildFlower)
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
        if (localFlower.flowerType == nextFlower.flowerType || nextFlower.flowerType == ftSpecialWildFlower)
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
        if (localFlower.flowerType == nextFlower.flowerType || nextFlower.flowerType == ftSpecialWildFlower)
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
        if (localFlower.flowerType == nextFlower.flowerType || nextFlower.flowerType == ftSpecialWildFlower)
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
        //[self processRemoveMatchedFlowerOnArray:array];
        
        return array;
    }
    else
    {
        //Otherwise
        [array removeAllObjects];
        return nil;
    }
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
    else
        [self lockField];
    
    CGSize winSize = [[CCDirector sharedDirector] winSize];
    
    CGPoint touchLocation = [swipeGestureRecognizer locationInView:[CCDirector sharedDirector].view];
    
    //need to flip because the coordinate systems are flipped
    touchLocation.y = [[CCDirector sharedDirector] winSize].height - touchLocation.y;
    
    touchLocation = ccp(touchLocation.x - (winSize.width / 2 - (self.contentSize.width / 2)) - FIELD_POSITION_ADJUSTMENT, touchLocation.y - [NBFlower getStartingPosition].y + FIELD_POSITION_ADJUSTMENT);
    
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
    
    //This is an indicator to remove the display of hint move.
    userHasMakeAMoveSinceHistDisplayed = true;
    [self removeHintMoveDisplay];
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
    bool selectedFlowerIsWildFlower = false;
    NSMutableArray* arrayOfMatchedFlowers = nil;
    
    DLog("Move completed.");
    
    NBFlower* selectedflower = (NBFlower*)[[self.flowerArrays objectAtIndex:self.selectedFlowerGrid.x] objectAtIndex:self.selectedFlowerGrid.y];
    if (selectedflower.flowerType == ftSpecialWildFlower) selectedFlowerIsWildFlower = true;

    [self swapFlowerOnGrid:self.selectedFlowerGrid withFlowerOnGrid:self.swappedFlowerGrid];

    if (!isReturningFlower)
    {
        //If It is Wild flower, change the type to follow the flower it is swapped with
        if (selectedFlowerIsWildFlower)
        {
            for (int iteration = 0; iteration < 4; iteration++)
            {
                switch (iteration)
                {
                    case 0:
                    {
                        if ((self.selectedFlowerGrid.x + 1) >= self.horizontalTileCount) continue;
                        
                        NBFlower* selectedflower = (NBFlower*)[[self.flowerArrays objectAtIndex:self.selectedFlowerGrid.x] objectAtIndex:self.selectedFlowerGrid.y];
                        NBFlower* swappedflower = (NBFlower*)[[self.flowerArrays objectAtIndex:self.selectedFlowerGrid.x + 1] objectAtIndex:self.selectedFlowerGrid.y];
                        
                        selectedflower.flowerType = swappedflower.flowerType;
                    }
                        break;
                        
                    case 1:
                    {
                        if ((self.selectedFlowerGrid.y - 1) < 0) continue;
                        
                        NBFlower* selectedflower = (NBFlower*)[[self.flowerArrays objectAtIndex:self.selectedFlowerGrid.x] objectAtIndex:self.selectedFlowerGrid.y];
                        NBFlower* swappedflower = (NBFlower*)[[self.flowerArrays objectAtIndex:self.selectedFlowerGrid.x] objectAtIndex:self.selectedFlowerGrid.y - 1];
                        
                        selectedflower.flowerType = swappedflower.flowerType;
                    }
                        break;
                    
                    case 2:
                    {
                        if ((self.selectedFlowerGrid.x - 1) < 0) continue;
                        
                        NBFlower* selectedflower = (NBFlower*)[[self.flowerArrays objectAtIndex:self.selectedFlowerGrid.x] objectAtIndex:self.selectedFlowerGrid.y];
                        NBFlower* swappedflower = (NBFlower*)[[self.flowerArrays objectAtIndex:self.selectedFlowerGrid.x - 1] objectAtIndex:self.selectedFlowerGrid.y];
                        
                        selectedflower.flowerType = swappedflower.flowerType;
                    }
                        break;
                        
                    case 3:
                    {
                        if ((self.selectedFlowerGrid.y + 1) >= self.verticalTileCount) continue;
                        
                        NBFlower* selectedflower = (NBFlower*)[[self.flowerArrays objectAtIndex:self.selectedFlowerGrid.x] objectAtIndex:self.selectedFlowerGrid.y];
                        NBFlower* swappedflower = (NBFlower*)[[self.flowerArrays objectAtIndex:self.selectedFlowerGrid.x] objectAtIndex:self.selectedFlowerGrid.y + 1];
                        
                        selectedflower.flowerType = swappedflower.flowerType;
                    }
                        break;
                }
                
                arrayOfMatchedFlowers = [self checkLocalMatchFlowersAndAddToMatchSlots:self.selectedFlowerGrid];
                if ([arrayOfMatchedFlowers count] > 0)
                {
                    break;
                }
            }
            
            
        }
        else
        {
            arrayOfMatchedFlowers = [self checkLocalMatchFlowersAndAddToMatchSlots:self.selectedFlowerGrid];
        }
        
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
                
                //revert back the Wild flower
                if (selectedFlowerIsWildFlower)
                {
                    NBFlower* selectedflower = (NBFlower*)[[self.flowerArrays objectAtIndex:self.swappedFlowerGrid.x] objectAtIndex:self.swappedFlowerGrid.y];
                    selectedflower.flowerType = ftSpecialWildFlower;
                }
                
                break;
            case btThreeOfAKind:
                DLog(@"found three of a kind on selected flower");
                hasMatch = true;
                break;
            case btFourOfAKind:
                DLog(@"found four of a kind on selected flower");
                hasMatch = true;
                
                [self performSpecialMoveFourMatch:arrayOfMatchedFlowers withOriginalGridPosition:self.selectedFlowerGrid];
                
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
                
                [self performSpecialMoveSevenMatch:arrayOfMatchedFlowers withOriginalGridPosition:self.selectedFlowerGrid];
                
                break;
            default:
                break;
        }
        
        [self produceBouquet:self.currentBouquetMatchType onGrid:self.selectedFlowerGrid];
        [self processRemoveMatchedFlowerOnArray:arrayOfMatchedFlowers];
        
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
        [self processRemoveMatchedFlowerOnArray:arrayOfMatchedFlowers];
        
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
        [matchingFlower moveToGrid:originalFlower.gridPosition withDuration:0.25f informSelector:nil];
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
    
    if (isGameJustStarted)
    {
        timeRemainingBeforeDisplayingHintMove = DURATION_BEFORE_DISPLAYING_HINT_MOVE;
        isGameJustStarted = false;
    }
    
    if (!self.isProcessingMove && !self.isProcessingMatching)
    {
        if (userHasMakeAMoveSinceHistDisplayed)
        {
            timeRemainingBeforeDisplayingHintMove -= delta;
            
            if (timeRemainingBeforeDisplayingHintMove <= 0)
            {
                userHasMakeAMoveSinceHistDisplayed = false;
                [self displayRandomHintMove];
            }
        }
        else
            timeRemainingBeforeDisplayingHintMove = DURATION_BEFORE_DISPLAYING_HINT_MOVE;
    }
    else
        timeRemainingBeforeDisplayingHintMove = DURATION_BEFORE_DISPLAYING_HINT_MOVE;
    
    [self checkItemStatus:delta];
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
                [self rearrangeEmptyGridPosition:CGPointMake(x, y)];
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
        [self processRemoveMatchedFlowerOnArray:arrayOfMatchedFlowers];
        
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

-(void)rearrangeEmptyGridPosition:(CGPoint)gridPosition
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
                [newFlowerAbove moveToGrid:gridPosition withDuration:(FLOWER_MOVE_DURATION * (1 + (emptyCount / 2))) informSelector:nil];
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
    
    if ([gameGUI.customersArray count] > 0)
    {
        for (NBCustomer* customer in gameGUI.customersArray)
        {
    //        if (customer.flowerRequest.bouquetType == bouquetType)
    //        {
    //            return customer;
    //        }
            
            
            NBBouquet* req = customer.flowerRequest;
                if (req.bouquetType == bouquetType) {
                    return customer;
                }
//            CCArray* req = customer.request;
//            for (NBBouquet* flower in req) {
//                if (flower.bouquetType == bouquetType) {
//                    return customer;
//                }
//            }
        }
    }
    
    return nil;
}

-(void)produceBouquet:(NBBouquetType)bouquetType onGrid:(CGPoint)gridPosition
{
    if (bouquetType == btNoMatch)
        return;
    
    CGSize winsize = [[CCDirector sharedDirector] winSize];
    
    NBBouquet* bouquet = [NBBouquet bloomBouquetWithType:bouquetType withPosition:[NBFlower convertFieldGridPositionToActualPixel:gridPosition] addToNode:[self parent]];
    [[self parent] reorderChild:bouquet z:50];
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
        
        CGPoint position = ccp((index * (winsize.width / 3)) + (winsize.width / 3), winsize.height * 0.75);
        position = ccp((winsize.width / 3), winsize.height * 0.75);
        
        [bouquet performCustomerFulfillingScoringAtCustomerPosition:position andIndex:index andInformLayer:self withSelector:@selector(onBouquetReachedCustomer:bouquet:)];
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
//    [gameGUI doFulfillCustomer:[customerIndex intValue] flowerScore:0];
    //To Romy pls change flowerIndex
    [gameGUI doFulfillCustomer:[customerIndex intValue] flowerIndex:0 flowerScore:0];
    
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
    
    if ([self.currentRoundPossibleMoves count] > 0)
        [self.currentRoundPossibleMoves removeAllObjects];
    else
        self.currentRoundPossibleMoves = [NSMutableArray array];
    
    for (int x = 0; x < [self.flowerArrays count]; x++)
    {
        for (int y = 0; y < [self.flowerArrays count]; y++)
        {
            for (int j = 0; j < fmtMaxMoveType; j++)
            {
                if ([self checkPossibleMatchIfGrid:ccp(x, y) moveTo:(NBFlowerMoveType)j])
                {
                    hasMatch = true;
                    
                    //Add the position to the possible moves list for later use to hint user.
                    NSValue* value = [NSValue valueWithCGPoint:ccp(x, y)];
                    [self.currentRoundPossibleMoves addObject:value];
                }
            }
        }
    }
    
    [self unlockField];
    
    if (hasMatch)
        DLog(@"found possible move");
    else
    {
        DLog(@"No possible move found");
        [self invokeRearrangeFieldDueToNPossibleMove];
    }
    
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

-(void)invokeRearrangeFieldDueToNPossibleMove
{
    CGSize winSize = [[CCDirector sharedDirector] winSize];
    
    CCLabelTTF* noMovesLabel = [CCLabelTTF labelWithString:@"Rearranging Shop..." dimensions:CGSizeZero hAlignment:kCCTextAlignmentCenter fontName:@"Marker Felt" fontSize:24];
    noMovesLabel.position = ccp(0, (self.contentSize.height / 2));
    noMovesLabel.opacity = 0;
    
    [self.parent addChild:noMovesLabel z:self.zOrder + 1];

    CCFadeIn* fadeIn = [CCFadeIn actionWithDuration:.75f];
    CCDelayTime* delay1 = [CCDelayTime actionWithDuration:3.50f];
    CCFadeOut* fadeOut = [CCFadeOut actionWithDuration:.75f];
    CCSequence* sequence = [CCSequence actions:fadeIn, delay1, fadeOut, nil];
    [noMovesLabel runAction:sequence];
    
    CCMoveTo* moveTo1 = [CCMoveTo actionWithDuration:1.0f position:ccp((winSize.width / 2), (self.contentSize.height / 2))];
    CCEaseIn* easeIn = [CCEaseIn actionWithAction:moveTo1 rate:0.75];
    CCDelayTime* delay2 = [CCDelayTime actionWithDuration:2.25f];
    CCMoveTo* moveTo2 = [CCMoveTo actionWithDuration:1.25f position:ccp(winSize.width + (noMovesLabel.contentSize.width / 2), (self.contentSize.height / 2))];
    CCEaseIn* easeOut = [CCEaseIn actionWithAction:moveTo2 rate:0.75];
    CCSequence* sequence2 = [CCSequence actions:easeIn, delay2, easeOut, nil];
    [noMovesLabel runAction:sequence2];
    
    [self debloomAllFlowers];
    [self randomizeNewPositionForAllFlower];
    
    CCDelayTime* delay3 = [CCDelayTime actionWithDuration:1.0f];
    CCCallFunc* callback = [CCCallFunc actionWithTarget:self selector:@selector(rearrangingStep1)];
    CCSequence* sequence3 = [CCSequence actions:delay3, callback, nil];
    [self runAction:sequence3];
}

-(void)rearrangingStep1
{
    [self bloomAllFlowers];
    [self unlockField];
    [self checkMatchCombo];
}

-(void)debloomAllFlowers
{
    for (int x = 0; x < [self.flowerArrays count]; x++)
    {
        NSMutableArray* flowerArrayOnGridX = [self.flowerArrays objectAtIndex:x];
        
        for (int y = 0; y < [flowerArrayOnGridX count]; y++)
        {
            NBFlower* flower = (NBFlower*)[flowerArrayOnGridX objectAtIndex:y];
            [flower debloomToHide];
        }
    }
}

-(void)bloomAllFlowers
{
    for (int x = 0; x < [self.flowerArrays count]; x++)
    {
        NSMutableArray* flowerArrayOnGridX = [self.flowerArrays objectAtIndex:x];
        
        for (int y = 0; y < [flowerArrayOnGridX count]; y++)
        {
            NBFlower* flower = (NBFlower*)[flowerArrayOnGridX objectAtIndex:y];
            [flower bloomToShow];
        }
    }
}

-(void)randomizeNewPositionForAllFlower
{
    virtualRandomNumberArray = [NBFieldRandomArray arrayWithFieldHorizontalCount:self.horizontalTileCount andVerticalCount:self.verticalTileCount];
    
    //Prepare virtual array to store new position
    NSMutableArray* virtualArrayX = [NSMutableArray arrayWithCapacity:self.horizontalTileCount];
    
    for (int x = 0; x < self.horizontalTileCount; x++)
    {
        NSMutableArray* virtualArrayY = [NSMutableArray arrayWithCapacity:self.verticalTileCount];
        [virtualArrayX addObject:virtualArrayY];
    }
    
    //Start randomizing
    for (int x = 0; x < [self.flowerArrays count]; x++)
    {
        NSMutableArray* flowerArrayOnGridX = [self.flowerArrays objectAtIndex:x];
        
        for (int y = 0; y < [flowerArrayOnGridX count]; y++)
        {
            NBFlower* flower = (NBFlower*)[flowerArrayOnGridX objectAtIndex:y];
            CGPoint newPosition = CGPointZero;
            
            if (flower.isMovableDuringRearrangingShop)
            {
                newPosition = [virtualRandomNumberArray getNewRandomLocation];
                
                if (newPosition.x == -1 && newPosition.y == -1)
                {
                    //No more remaining slot
                    break;
                }
                
                [flower changeToGrid:newPosition];
                
                NSMutableArray* verticalArray = [virtualArrayX objectAtIndex:newPosition.x];
                
                if ([verticalArray count] == 0)
                    [verticalArray addObject:flower];
                else
                {
                    bool useAdd = false;
                    int i;
                    
                    for (i = 0; i < [verticalArray count]; i++)
                    {
                        NBFlower* otherFlower = (NBFlower*)[verticalArray objectAtIndex:i];
                        if (newPosition.y < otherFlower.gridPosition.y)
                        {
                            useAdd = false;
                            break;
                        }
                        else
                            useAdd = true;
                    }
                    
                    if (useAdd)
                        [verticalArray addObject:flower];
                    else
                        [verticalArray insertObject:flower atIndex:i];
                }
            }
        
            [virtualRandomNumberArray utilizeGrid:newPosition];
        }
    }
    
    self.flowerArrays = virtualArrayX;
    [NBFlower assignFlowerField:self.flowerArrays];
}

-(void)rearrangeGridPosition
{
    [self lockField];
    
    
    
    [self unlockField];
}

-(void)displayRandomHintMove
{
    if ([self.currentRoundPossibleMoves count] == 0) return;
    
    int randomIndex = arc4random_uniform([self.currentRoundPossibleMoves count]);
    NSValue* value = [self.currentRoundPossibleMoves objectAtIndex:randomIndex];
    currentlyShownHintMoveGridPosition = [value CGPointValue];
    NBFlower* flower = (NBFlower*)[[self.flowerArrays objectAtIndex:currentlyShownHintMoveGridPosition.x] objectAtIndex:currentlyShownHintMoveGridPosition.y];
    [flower toggleBlink:true];
}

-(void)removeHintMoveDisplay
{
    NBFlower* flower = (NBFlower*)[[self.flowerArrays objectAtIndex:currentlyShownHintMoveGridPosition.x] objectAtIndex:currentlyShownHintMoveGridPosition.y];
    [flower toggleBlink:false];
    currentlyShownHintMoveGridPosition = CGPointZero;
}

-(void)performSpecialMoveFourMatch:(NSMutableArray*)arrayOfMatchedFlowers withOriginalGridPosition:(CGPoint)originalGridPosition
{
    for (NSValue* value in arrayOfMatchedFlowers)
    {
        CGPoint flowerPosition = [value CGPointValue];
        NBFlower* flower = (NBFlower*)[[self.flowerArrays objectAtIndex:flowerPosition.x] objectAtIndex:flowerPosition.y];
        
        if (flower.gridPosition.x == originalGridPosition.x && flower.gridPosition.y == originalGridPosition.y)
        {
            [arrayOfMatchedFlowers removeObject:value];
            break;
        }
    }
    
    NBFlower* originalFlower = (NBFlower*)[[self.flowerArrays objectAtIndex:originalGridPosition.x] objectAtIndex:originalGridPosition.y];
    NBFlower* wildCardFlower = [NBFlower bloomFlower:ftSpecialWildFlower OnGridPosition:originalGridPosition];
    [[self.flowerArrays objectAtIndex:originalGridPosition.x] setObject:wildCardFlower atIndex:originalGridPosition.y];
    [self removeChild:originalFlower cleanup:YES];
    [originalFlower release];
}

-(void)performSpecialMoveSevenMatch:(NSMutableArray*)arrayOfMatchedFlowers withOriginalGridPosition:(CGPoint)originalGridPosition
{
    NBFlower* originalFlower = (NBFlower*)[[self.flowerArrays objectAtIndex:originalGridPosition.x] objectAtIndex:originalGridPosition.y];
    
    for (int x = 0; x < self.horizontalTileCount; x++)
    {
        for (int y = 0; y < self.verticalTileCount; y++)
        {
            bool isExcluded = false;
            
            for (NSValue* value in arrayOfMatchedFlowers)
            {
                CGPoint flowerPosition = [value CGPointValue];
                if (x == flowerPosition.x && y == flowerPosition.y)
                {
                    isExcluded = true;
                    break;
                }
            }
            
            if (!isExcluded)
            {
                NBFlower* flower = (NBFlower*)[[self.flowerArrays objectAtIndex:x] objectAtIndex:y];
                
                if (flower.flowerType == originalFlower.flowerType)
                {
                    NBFlower* flower = (NBFlower*)[[self.flowerArrays objectAtIndex:x] objectAtIndex:y];
                    [flower debloomToHide];
                    NBFlower* wildCardFlower = [NBFlower bloomFlower:ftSpecialWildFlower OnGridPosition:ccp(x, y)];
                    [[self.flowerArrays objectAtIndex:x] setObject:wildCardFlower atIndex:y];
                    [self removeChild:flower cleanup:YES];
                    [flower release];
                }
            }
        }
    }
}

-(void)checkItemStatus:(ccTime)delta
{
    if (self.timeBooster.isActivated)
    {
        [self.timeBooster update:delta];
    }
    
    if (self.lifeBooster.isActivated)
    {
        [self.lifeBooster update:delta];
    }
    
    if (self.timeBooster.isActivated)
    {
        [self.timeBooster update:delta];
    }
}
@end
