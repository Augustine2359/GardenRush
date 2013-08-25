//
//  NBItemData.h
//  GardenRushV1
//
//  Created by Romy Irawaty on 25/8/13.
//
//

#import <Foundation/Foundation.h>

@interface NBItemData : NSObject

@property (nonatomic, retain) NSString* itemName;
@property (nonatomic, assign) float duration;
@property (nonatomic, retain) NSString* itemImageName;
@property (nonatomic, assign) int startingQuantity;

@end
