//
//  NBFieldRandomArray.m
//  GardenRushV1
//
//  Created by Romy Irawaty on 16/6/13.
//
//

#import "NBFieldRandomArray.h"

@implementation NBFieldRandomArray

+(id)arrayWithFieldHorizontalCount:(int)horizontalTileCount andVerticalCount:(int)verticalTileCount
{
    NBFieldRandomArray* newRandomFieldArray = [[NBFieldRandomArray alloc] init];
    newRandomFieldArray.mainHorizontalArray = [NSMutableArray arrayWithCapacity:(horizontalTileCount + 1)];
    
    for (int i = 0; i < (horizontalTileCount + 1); i++)
    {
        NSMutableArray* numberList = [NSMutableArray array];
        
        for (int j = 0; j <= verticalTileCount; j++)
        {
            NSValue* number = nil;
            
            /*if (i == horizontalTileCount)
            {
                number = [NSValue value:&verticalTileCount withObjCType:@encode(int)];
            }
            else
            {*/
                number = [NSValue value:&j withObjCType:@encode(int)];
            //}
            
            [numberList addObject:number];
        }
        
        //if (i == horizontalTileCount)
        //    [numberList addObject:[NSValue value:&horizontalTileCount withObjCType:@encode(int)]]; //for count of remaining available slot horizontally
            
        [newRandomFieldArray.mainHorizontalArray addObject:numberList];
    }
    
    newRandomFieldArray.remainingSlot = horizontalTileCount * verticalTileCount;
    newRandomFieldArray.horizontalCount = horizontalTileCount;
    newRandomFieldArray.verticalCount = verticalTileCount;
    
    return newRandomFieldArray;
}

-(CGPoint)getNewRandomLocation
{
    if (self.remainingSlot > 0)
    {
        int remainingHorizontalSlot, remainingVerticalSlot;
        int valueOfX, valueOfY;
        
        NSArray* verticalArrayList = [self.mainHorizontalArray objectAtIndex:([self.mainHorizontalArray count] - 1)];
        NSValue* valueOfRemainingHorizontalSlot = [verticalArrayList objectAtIndex:self.verticalCount];
        [valueOfRemainingHorizontalSlot getValue:&remainingHorizontalSlot];
        int randomHorizontalIndex = arc4random_uniform(remainingHorizontalSlot - 1);
        NSValue* tempX = [[self.mainHorizontalArray objectAtIndex:([self.mainHorizontalArray count] - 1)] objectAtIndex:randomHorizontalIndex];
        [tempX getValue:&valueOfX];
        
        NSValue* valueOfRemainingVerticalSlot = [[self.mainHorizontalArray objectAtIndex:valueOfX] objectAtIndex:self.verticalCount];
        [valueOfRemainingVerticalSlot getValue:&remainingVerticalSlot];
        int randomVerticalIndex = arc4random_uniform(remainingVerticalSlot - 1);
        NSValue* tempY = [[self.mainHorizontalArray objectAtIndex:valueOfX] objectAtIndex:randomVerticalIndex];
        [tempY getValue:&valueOfY];
        
        return ccp(valueOfX, valueOfY);
    }
    
    return ccp(-1, -1);
}

-(void)utilizeGrid:(CGPoint)gridPosition
{
    int remainingVerticalSlot, remainingHorizontalSlot;
    int tempY = gridPosition.y;
    
    NSValue* number = [NSValue value:&tempY withObjCType:@encode(int)];
    NSMutableArray* verticalArray = (NSMutableArray*)[self.mainHorizontalArray objectAtIndex:gridPosition.x];
    [verticalArray insertObject:number atIndex:self.verticalCount];
    
    for (int i = 0; i < [verticalArray count]; i++)
    {
        int value;
        NSValue* tempValue = [verticalArray objectAtIndex:i];
        [tempValue getValue:&value];
        
        if (value == gridPosition.y)
        {
            [verticalArray removeObjectAtIndex:i];
            break;
        }
    }
    
    NSValue* valueOfRemainingVerticalSlot = [[self.mainHorizontalArray objectAtIndex:gridPosition.x] objectAtIndex:self.verticalCount];
    [valueOfRemainingVerticalSlot getValue:&remainingVerticalSlot];
    remainingVerticalSlot--;
    NSValue* remainingNumberCountObject = [NSValue value:&remainingVerticalSlot withObjCType:@encode(int)];
    [[self.mainHorizontalArray objectAtIndex:gridPosition.x] replaceObjectAtIndex:self.verticalCount withObject:remainingNumberCountObject];
    
    if (remainingVerticalSlot <= 0)
    {
        int tempX = gridPosition.x;
        NSValue* usedUpHorizontalGridIndex = [NSValue value:&tempX withObjCType:@encode(int)];
        [[self.mainHorizontalArray objectAtIndex:([self.mainHorizontalArray count] - 1)] insertObject:usedUpHorizontalGridIndex atIndex:self.verticalCount];
        
        for (int i = 0; i < [verticalArray count]; i++)
        {
            int value;
            NSValue* tempValue = [[self.mainHorizontalArray objectAtIndex:([self.mainHorizontalArray count] - 1)] objectAtIndex:i];
            [tempValue getValue:&value];
            
            if (value == gridPosition.x)
            {
                [[self.mainHorizontalArray objectAtIndex:([self.mainHorizontalArray count] - 1)] removeObjectAtIndex:i];
                break;
            }
        }
        
        NSValue* valueOfRemainingHorizontalSlot = [[self.mainHorizontalArray objectAtIndex:([self.mainHorizontalArray count] - 1)] objectAtIndex:self.verticalCount];
        [valueOfRemainingHorizontalSlot getValue:&remainingHorizontalSlot];
        remainingHorizontalSlot--;
        remainingNumberCountObject = [NSValue value:&remainingHorizontalSlot withObjCType:@encode(int)];
        [[self.mainHorizontalArray objectAtIndex:([self.mainHorizontalArray count] - 1)] replaceObjectAtIndex:self.verticalCount withObject:remainingNumberCountObject];
    }
    
    self.remainingSlot--;
    
    CCLOG(@"%f, %f", gridPosition.x, gridPosition.y);
    [self checkGridValues];
}

-(void)checkGridValues
{
    for (int i = 0; i < [self.mainHorizontalArray count]; i++)
    {
        NSString* testString = nil;
        
        for (int j = 0; j < [[self.mainHorizontalArray objectAtIndex:i] count]; j++)
        {
            int value = 0;
            NSValue* tempValue = [[self.mainHorizontalArray objectAtIndex:i] objectAtIndex:j];
            [tempValue getValue:&value];
            testString = [NSString stringWithFormat:@"%@, %i", testString, value];
        }
        
        CCLOG(@"%@", testString);
    }
}

@end
