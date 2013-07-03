//
//  NBFieldRandomArray.h
//  GardenRushV1
//
//  Created by Romy Irawaty on 16/6/13.
//
//

#import <Foundation/Foundation.h>

@interface NBFieldRandomArray : NSObject

@property (nonatomic, retain) NSMutableArray* mainHorizontalArray;
@property (nonatomic, assign) int remainingSlot;
@property (nonatomic, assign) int horizontalCount;
@property (nonatomic, assign) int verticalCount;

+(id)arrayWithFieldHorizontalCount:(int)horizontalTileCount andVerticalCount:(int)verticalTileCount;
-(CGPoint)getNewRandomLocation;

@end
