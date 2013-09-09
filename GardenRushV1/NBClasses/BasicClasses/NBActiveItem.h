//
//  NBActiveItem.h
//  GardenRushV1
//
//  Created by Romy Irawaty on 28/7/13.
//
//

#import <Foundation/Foundation.h>
#import "cocos2d.h"
#import "NBItemData.h"

#define SUPPORTED_ITEM_COUNT 3
#define DEFAULT_ITEM_DURATION 10

typedef enum
{
	itNone = 0,
    itLifeCharger,
    itCustomerWaitTimeCharger,
    itScoreMultiplier,
} NBItemType;

@interface NBActiveItem : CCNode

+(id)createNewItemWithItemData:(NBItemData*)itemData withTypeOf:(NBItemType)itemType withStockAmount:(int)amount;
-(void)activateItem;
-(void)deactivateItem;
-(void)assignName:(NSString*)name;
-(void)addStock:(int)amount;
-(void)removeStock:(int)amount;
-(void)updateLabel;
-(void)update:(ccTime)delta;

@property (nonatomic, retain) NBItemData* itemData;
@property (nonatomic, retain) CCMenuItemSprite* itemImage;
@property (nonatomic, retain) CCSprite* itemDurationBar;
@property (nonatomic, retain) CCLabelAtlas* itemAvailableCountLabel;
@property (nonatomic, assign) int currentStock;
@property (nonatomic, assign) NBItemType itemType;
@property (nonatomic, assign) BOOL isActivated;

@end
