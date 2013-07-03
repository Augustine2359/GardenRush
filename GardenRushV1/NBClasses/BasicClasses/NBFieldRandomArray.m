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
        
        for (int j = 0; j < verticalTileCount; j++)
        {
            NSNumber* number = nil;
            
            if (i == horizontalTileCount)
                number = [NSNumber numberWithInt:verticalTileCount];
            else
                number = [NSNumber numberWithInt:j];
            
            [numberList addObject:number];
        }
        
        if (i == horizontalTileCount)
            [numberList addObject:[NSNumber numberWithInt:horizontalTileCount]]; //for count of remaining available slot horizontally
            
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
        NSArray* verticalArrayList = [self.mainHorizontalArray objectAtIndex:([self.mainHorizontalArray count] - 1)];
        int remainingHorizontalSlot = [[verticalArrayList objectAtIndex:(self.verticalCount - 1)] intValue];
        int randomHorizontalIndex = arc4random_uniform(remainingHorizontalSlot);
        
        int remainingVerticalSlot = [[[self.mainHorizontalArray objectAtIndex:([self.mainHorizontalArray count] - 1)] objectAtIndex:randomHorizontalIndex] intValue];
        int randomVerticalIndex = arc4random_uniform(remainingVerticalSlot);
        
        return ccp(randomHorizontalIndex, randomVerticalIndex);
    }
    
    return ccp(-1, -1);
}

@end
