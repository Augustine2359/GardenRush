//
//  NBFlowerFieldGameGrid.m
//  GardenRushV1
//
//  Created by Romy Irawaty on 9/5/13.
//
//

#import "NBFlowerFieldGameGrid.h"

@interface NBFlowerFieldGameGrid()
{
    bool isProcessingMove;
    bool isProcessingMatching;
    bool isReturningFlower; //use to detect whether after the move need to check match
    bool isRearranging;
    UISwipeGestureRecognizerDirection lastGestureDirection;
}

@property (nonatomic, strong) NSArray *gestureRecognizers;

@end

@implementation NBFlowerFieldGameGrid

-(id)init
{
    CGSize winSize = [[CCDirector sharedDirector] winSize];
    
    if (self = [super init])
    {
        //CGSize fieldSize = CGSizeMake(10, 10);
        
        [self setContentSize:CGSizeMake((((FLOWERSIZE_WIDTH + FIELD_FLOWER_GAP_WIDTH) * FIELD_HORIZONTAL_UNIT_COUNT) + FIELD_FLOWER_GAP_WIDTH), (((FLOWERSIZE_HEIGHT + FIELD_FLOWER_GAP_WIDTH) * FIELD_VERTICAL_UNIT_COUNT) + FIELD_FLOWER_GAP_WIDTH))];
        self.anchorPoint = ccp(0, 0);
        self.position = ccp(winSize.width / 2 - (self.contentSize.width / 2), 10);
        
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
        
        for (int i = 0; i < FIELD_HORIZONTAL_UNIT_COUNT; i++)
        {
            NSMutableArray* verticalFlowerArray = [NSMutableArray array];
            
            [self.flowerArrays addObject:verticalFlowerArray];
        }
        
        [NBFlower assignFieldLayer:self];
        [NBFlower assignStartingPosition:CGPointMake(FIELD_FLOWER_GAP_WIDTH, FIELD_FLOWER_GAP_WIDTH)];
        [NBFlower assignFlowerField:self.flowerArrays];
        
        [self fillFlower];
        isProcessingMove = false;
        
        [self addSwipeGestureRecognizers];
        [self scheduleUpdate];
    }
    
    return self;
}

-(void)fillFlower
{
    for (int i = 0; i < FIELD_HORIZONTAL_UNIT_COUNT; i++)
    {
        for (int j = 0; j < FIELD_VERTICAL_UNIT_COUNT; j++)
        {
            if ([[self.flowerArrays objectAtIndex:i] count] < 10)
            {
                NBFlower* flower = [NBFlower createRandomFlowerOnGridPosition:CGPointMake(i, j)];
                //NBFlower* flower = [NBFlower createNewFlower:ftRedFlower onGridPosition:CGPointMake(i, j)];
                [[self.flowerArrays objectAtIndex:i] addObject:flower];
            }
            else
            {
                NBFlower* flower = [NBFlower createRandomFlowerOnGridPosition:CGPointMake(i, j)];
                //NBFlower* flower = [NBFlower createNewFlower:ftRedFlower onGridPosition:CGPointMake(i, j)];
                [[self.flowerArrays objectAtIndex:i] setObject:flower atIndex:j];
            }
        }
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
    if (isProcessingMove || isProcessingMatching) return;
    
    isProcessingMove = true;
    
    CGPoint touchLocation = [swipeGestureRecognizer locationInView:[CCDirector sharedDirector].view];
    
    //need to flip because the coordinate systems are flipped
    touchLocation.y = [[CCDirector sharedDirector] winSize].height - touchLocation.y;
    
    touchLocation = ccp(touchLocation.x - 10, touchLocation.y - 10);
    
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
    if ((newGridPosition.x < 0) || (newGridPosition.x > (FIELD_HORIZONTAL_UNIT_COUNT - 1)) || (newGridPosition.y < 0) || (newGridPosition.y > (FIELD_VERTICAL_UNIT_COUNT - 1)))
    {
        isProcessingMove = false;
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
    isProcessingMove = true;
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

-(NBFlowerMatchType)checkLocalMatchFlowersAndAddToMatchSlots:(CGPoint)gridPoint
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
        if (gridX >= FIELD_HORIZONTAL_UNIT_COUNT) break;
        
        NBFlower* nextFlower = (NBFlower*)[[self.flowerArrays objectAtIndex:gridX] objectAtIndex:gridPoint.y];
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
        if (gridY >= FIELD_VERTICAL_UNIT_COUNT) break;
        
        NBFlower* nextFlower = (NBFlower*)[[self.flowerArrays objectAtIndex:gridPoint.x] objectAtIndex:gridY];
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
        NBFlowerMatchType matchType = mtNoMatch;
        
        if (matchCount == 3) matchType = mtThreeOfAKind;
        if (matchCount == 4) matchType = mtFourOfAKind;
        if ((matchCount == 5) && (matchDetectedOnHorizontal && matchDetectedOnVertical)) matchType = mtCornerFiveOfAKind;
        if (matchCount == 5) matchType = mtFiveOfAKind;
        if (matchCount == 6) matchType = mtSixOfAKind;
        if (matchCount >= 7) matchType = mtSevenOfAKind;
    
        for (int i = 0; i < [array count]; i++)
        {
            NSValue* value = [array objectAtIndex:0];
            CGPoint flowerPosition = [value CGPointValue];
            NBFlower* flower = (NBFlower*)[[self.flowerArrays objectAtIndex:flowerPosition.x] objectAtIndex:flowerPosition.y];
            flower.matchType = matchType;
        }
        
        [self.arrayOfMatchedFlowerSlots addObject:array];
        [self processRemoveMatchedFlowerOnArray:array];
        
        return matchType;
    }
    else
    {
        //Otherwise
        [array removeAllObjects];
        return mtNoMatch;
    }
}

-(void)swapFlowerOnGrid:(CGPoint)flowerAGrid withFlowerOnGrid:(CGPoint)flowerBGrid
{
    NBFlower* swappingFlower = (NBFlower*)[[self.flowerArrays objectAtIndex:flowerAGrid.x] objectAtIndex:flowerAGrid.y];
    NBFlower* toBeSwappedFlower = (NBFlower*)[[self.flowerArrays objectAtIndex:flowerBGrid.x] objectAtIndex:flowerBGrid.y];
    
    NBFlower* newSwappingFlower = [NBFlower createNewFlower:swappingFlower.flowerType onGridPosition:swappingFlower.gridPosition];
    NBFlower* newToBeSwappedFlower = [NBFlower createNewFlower:toBeSwappedFlower.flowerType onGridPosition:toBeSwappedFlower.gridPosition];
    
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
    
    isProcessingMove = false;
    
    DLog("Move completed.");

    [self swapFlowerOnGrid:self.selectedFlowerGrid withFlowerOnGrid:self.swappedFlowerGrid];

    if (!isReturningFlower)
    {
        self.currentMatchType = [self checkLocalMatchFlowersAndAddToMatchSlots:self.selectedFlowerGrid];
        
        switch (self.currentMatchType)
        {
            case mtNoMatch:
                DLog(@"no match on selected flower");
                break;
            case mtThreeOfAKind:
                DLog(@"found three of a kind on selected flower");
                hasMatch = true;
                break;
            case mtFourOfAKind:
                DLog(@"found four of a kind on selected flower");
                hasMatch = true;
                break;
            case mtFiveOfAKind:
                DLog(@"found five of a kind on selected flower");
                hasMatch = true;
                break;
            case mtCornerFiveOfAKind:
                DLog(@"found corner type five of a kind on selected flower");
                hasMatch = true;
                break;
            case mtSixOfAKind:
                DLog(@"found six of a kind on selected flower");
                hasMatch = true;
                break;
            case mtSevenOfAKind:
                DLog(@"found seven of a kind on selected flower");
                hasMatch = true;
                break;
            default:
                break;
        }
        
        switch ([self checkLocalMatchFlowersAndAddToMatchSlots:self.swappedFlowerGrid])
        {
            case mtNoMatch:
                DLog(@"no match on swapped flower");
                break;
            case mtThreeOfAKind:
                DLog(@"found three of a kind on swapped flower");
                hasMatch = true;
                break;
            case mtFourOfAKind:
                DLog(@"found four of a kind on swapped flower");
                hasMatch = true;
                break;
            case mtFiveOfAKind:
                DLog(@"found five of a kind on swapped flower");
                hasMatch = true;
                break;
            case mtCornerFiveOfAKind:
                DLog(@"found corner type five of a kind on swapped flower");
                hasMatch = true;
                break;
            case mtSixOfAKind:
                DLog(@"found six of a kind on swapped flower");
                hasMatch = true;
                break;
            case mtSevenOfAKind:
                DLog(@"found seven of a kind on swapped flower");
                hasMatch = true;
                break;
            default:
                break;
        }
        
        if (!hasMatch)
            [self returnFlower];
    }
    else
        isReturningFlower = false;
}

-(void)processRemoveMatchedFlowerOnArray:(NSMutableArray*)flowerArray
{
    if ([flowerArray count] == 0) return;
    
    isProcessingMove = true;
    
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
    
    isProcessingMatching = true;
}

-(void)update:(ccTime)delta
{
    if ([self.arrayOfMatchedFlowerSlots count] > 0)
    {
        isProcessingMatching = true;
        
        //for (NSMutableArray* arrayOfMatchedFlowers in self.arrayOfMatchedFlowerSlots)
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
            }
        }
    }
    else
    {
        isProcessingMatching = false;
        isProcessingMove = false;
    }
    
    if (!isRearranging)
    {
        [self checkEmptySlots];
    }
}

-(void)removeFlowerFromField:(NSArray*)arrayOfToBeRemovedFlowers
{
    for (int i = 0; i < [arrayOfToBeRemovedFlowers count]; i++)
    {
        NSValue* value = [arrayOfToBeRemovedFlowers objectAtIndex:i];
        CGPoint matchingFlowerPosition = [value CGPointValue];
        NBFlower* matchingFlower = (NBFlower*)[[self.flowerArrays objectAtIndex:matchingFlowerPosition.x] objectAtIndex:matchingFlowerPosition.y];
        NBFlower* emptyFlower = [NBFlower createNewFlower:ftNoFlower onGridPosition:matchingFlowerPosition];
        
        [[self.flowerArrays objectAtIndex:matchingFlowerPosition.x] setObject:emptyFlower atIndex:matchingFlowerPosition.y];
        [self removeChild:matchingFlower cleanup:YES];
        [matchingFlower release];
    }
}

-(void)checkEmptySlots
{
    if (isProcessingMatching) return;
    
    for (int x = 0; x < FIELD_HORIZONTAL_UNIT_COUNT; x++)
    {
        for (int y = 0; y < FIELD_VERTICAL_UNIT_COUNT; y++)
        {
            NBFlower* flower = (NBFlower*)[[self.flowerArrays objectAtIndex:x] objectAtIndex:y];
            if (flower.flowerType == ftNoFlower)
            {
                [self rearrangeGridPosition:CGPointMake(x, y)];
            }
        }
    }
}

-(void)rearrangeGridPosition:(CGPoint)gridPosition
{
    isRearranging = true;
    int emptyCount = 1;

    while (true)
    {
        CGPoint gridAbove = CGPointMake(gridPosition.x, gridPosition.y + 1);
        if (gridAbove.y >= FIELD_VERTICAL_UNIT_COUNT)
        {
            [self generateRandomFlowerAndFallOnGridPosition:gridPosition];
            break;
        }
        
        NBFlower* flowerAbove = (NBFlower*)[[self.flowerArrays objectAtIndex:gridAbove.x] objectAtIndex:gridAbove.y];
        NBFlower* flowerInThisGrid = (NBFlower*)[[self.flowerArrays objectAtIndex:gridPosition.x] objectAtIndex:gridPosition.y];
        NBFlower* emptyFlower = [NBFlower createNewFlower:ftNoFlower onGridPosition:gridAbove];
        
        if (flowerAbove.flowerType == ftNoFlower)
            emptyCount++;
        
        NBFlower* newFlowerAbove = [NBFlower createNewFlower:flowerAbove.flowerType onGridPosition:flowerAbove.gridPosition];
        [[self.flowerArrays objectAtIndex:gridPosition.x] setObject:newFlowerAbove atIndex:gridPosition.y];
        [[self.flowerArrays objectAtIndex:gridAbove.x] setObject:emptyFlower atIndex:gridAbove.y];
        [newFlowerAbove moveToGrid:gridPosition withDuration:0.3f informSelector:nil];
        
        [flowerAbove removeFromParentAndCleanup:YES];
        [flowerAbove release];
        [flowerInThisGrid removeFromParentAndCleanup:YES];
        [flowerInThisGrid release];
        
        gridPosition = CGPointMake(gridPosition.x, gridPosition.y + 1);
    }
    
    isRearranging = false;
}

-(void)processFillFlowerOnGrid:(CGPoint)gridPosition
{
    CGPoint gridAbove = CGPointMake(gridPosition.x, gridPosition.y + 1);
    if (gridAbove.y >= FIELD_VERTICAL_UNIT_COUNT)
    {
        [self generateRandomFlowerAndFallOnGridPosition:gridAbove];
    }
    else
    {
        while (true)
        {
            NBFlower* flowerAbove = (NBFlower*)[[self.flowerArrays objectAtIndex:gridAbove.x] objectAtIndex:gridAbove.y];
            if (flowerAbove.flowerType == ftNoFlower)
            {
                gridAbove = CGPointMake(gridAbove.x, gridAbove.y + 1);
                
                if (gridAbove.y >= FIELD_VERTICAL_UNIT_COUNT)
                {
                    [self generateRandomFlowerAndFallOnGridPosition:gridAbove];
                }
                
                continue;
            }
            else
            {
                [self dropFlowersOnGridPosition:gridPosition];
                break;
            }
        }
    }
}

-(void)dropFlowersOnGridPosition:(CGPoint)gridPosition
{
    for (int i = ((int)gridPosition.y + 1); i < FIELD_VERTICAL_UNIT_COUNT; i++)
    {
        NBFlower* flowerAbove = (NBFlower*)[[self.flowerArrays objectAtIndex:gridPosition.x] objectAtIndex:i];
        [flowerAbove fallByOneGrid:@selector(onFlowerDropped:)];
    }
}

-(void)onFlowerDropped:(NBFlower*)flower
{
    [self swapFlowerOnGrid:flower.gridPosition withFlowerOnGrid:CGPointMake(flower.gridPosition.x, (flower.gridPosition.y + 1))];
}

-(void)onFlowerGetNewGridPosition:(CGPoint)newPosition fromPosition:(CGPoint)oldPosition
{
    NBFlower* flowerThatGetsNewPosition = (NBFlower*)[[self.flowerArrays objectAtIndex:oldPosition.x] objectAtIndex:oldPosition.y];
    NBFlower* flowerThatWillBeReplaced = (NBFlower*)[[self.flowerArrays objectAtIndex:newPosition.x] objectAtIndex:newPosition.y];
    NBFlower* newFlower = [NBFlower createNewFlower:flowerThatGetsNewPosition.flowerType onGridPosition:newPosition];
    [[self.flowerArrays objectAtIndex:newPosition.x] setObject:newFlower atIndex:newPosition.y];
    
    [flowerThatWillBeReplaced removeFromParentAndCleanup:YES];
    [flowerThatWillBeReplaced release];
}

-(void)generateRandomFlowerAndFallOnGridPosition:(CGPoint)gridPosition
{
    NBFlower* flowerToBeReplaced = (NBFlower*)[[self.flowerArrays objectAtIndex:gridPosition.x] objectAtIndex:gridPosition.y];
    flowerToBeReplaced.visible = NO;
    NBFlower* randomNewFlower = [NBFlower bloomRandomFlowerOnGridPosition:gridPosition];
    [[self.flowerArrays objectAtIndex:gridPosition.x] setObject:randomNewFlower atIndex:gridPosition.y];
    
    [flowerToBeReplaced removeFromParentAndCleanup:YES];
    [flowerToBeReplaced release];
}

@end
