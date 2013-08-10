//
//  NBActiveItem.h
//  GardenRushV1
//
//  Created by Romy Irawaty on 28/7/13.
//
//

#import <Foundation/Foundation.h>
#import "cocos2d.h"

#define SUPPORTED_ITEM_COUNT 3

typedef enum
{
	itNone = 0,
    itLifeCharger,
    itCustomerWaitTimeCharger,
    itScoreMultiplier,
} NBItemType;

@interface NBActiveItem : CCNode

+(id)createNewItem:(NSString*)frameName withTypeOf:(NBItemType)itemType withStockAmount:(int)amount;
-(void)activateItem;
-(void)assignName:(NSString*)name;
-(void)addStock:(int)amount;
-(void)removeStock:(int)amount;

@property (nonatomic, retain) CCMenuItemSprite* itemImage;
@property (nonatomic, assign) int currentStock;
@property (nonatomic, assign) NBItemType itemType;
@property (nonatomic, retain) NSString* itemName;

@end
